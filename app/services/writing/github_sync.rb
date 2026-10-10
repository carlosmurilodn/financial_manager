require "digest"
require "tmpdir"
require "timeout"

module Writing
  class GithubSync
    class Busy < StandardError; end
    class DeadlineExceeded < StandardError; end
    MAX_DURATION = 90.seconds
    Result = Struct.new(:state, :message, :success, keyword_init: true)

    def initialize(book, configuration: GithubConfiguration.new)
      @book = book
      @configuration = configuration
      @counts = { created_count: 0, updated_count: 0, unchanged_count: 0 }
      @obsolete_files = []
    end

    def call
      # Session advisory lock spans HTTP calls without holding a DB transaction.
      # Released automatically by PostgreSQL if the application process dies.
      WritingGithubSync.connection_pool.with_connection do |connection|
        key = connection.quote("writing_github_sync:#{@book.id}")
        acquired = connection.select_value("SELECT pg_try_advisory_lock(hashtextextended(#{key}, 0))")
        raise Busy, "Este livro já está sendo sincronizado. Aguarde a conclusão." unless acquired

        begin
          @state = WritingGithubSync.find_or_create_by!(writing_book: @book)
          @state.update!(@counts.merge(status: "processing", last_attempt_at: Time.current, error_message: nil,
            obsolete_files: [], repository: @configuration.configured? ? @configuration.repository : nil,
            branch: @configuration.configured? ? @configuration.branch : nil))
          synchronize
        ensure
          connection.select_value("SELECT pg_advisory_unlock(hashtextextended(#{key}, 0))")
        end
      end
    end

    private

    def synchronize
      Timeout.timeout(MAX_DURATION, DeadlineExceeded) { publish_documents }
      @state.update!(@counts.merge(status: "succeeded", last_success_at: Time.current, error_message: nil, obsolete_files: @obsolete_files))
      Result.new(state: @state, success: true, message: summary)
    rescue GithubClient::Error, ContextExport::Error => error
      failed(error.message)
    rescue DeadlineExceeded
      failed("Sincronização excedeu o tempo disponível. Tente novamente; arquivos já enviados serão reconhecidos pela próxima tentativa.")
    rescue StandardError => error
      # Never log exception messages, request objects, credentials or document bodies.
      Rails.logger.error("Writing GitHub sync failed: #{error.class}")
      failed("Não foi possível concluir a sincronização. Tente novamente.")
    end

    def publish_documents
      client = GithubClient.new(@configuration, @book.id)
      remote = client.remote_files
      Dir.mktmpdir("writing-github-") do |directory|
        archive_path = File.join(directory, "book.zip")
        @book.reload
        # Reuse the ZIP exporter verbatim; omit only the volatile export timestamp.
        ContextExport.new(@book, ContextExportOptions.new, exported_at: nil).generate(archive_path)
        Zip::File.open(archive_path) do |archive|
          documents = archive.entries.reject(&:directory?).sort_by(&:name)
          @obsolete_files = (remote.keys.select { |path| path.end_with?(".md") && remote[path]["type"] != "tree" } - documents.map(&:name)).sort
          documents.each { |entry| ensure_regular_path!(entry.name, remote) }
          documents.each do |entry|
            raise GithubClient::Error, "Documento excede o limite de 100 MB do GitHub." if entry.size > 100.megabytes

            content = entry.get_input_stream(&:read)
            existing = remote[entry.name]
            if existing && blob_sha(content, existing.fetch("sha")) == existing.fetch("sha")
              @counts[:unchanged_count] += 1
              next
            end
            client.publish(entry.name, content, sha: existing&.fetch("sha"))
            @counts[existing ? :updated_count : :created_count] += 1
          end
        end
      end
    end

    def ensure_regular_path!(path, remote)
      segments = path.split("/")
      segments.each_index do |index|
        entry = remote[segments.take(index + 1).join("/")]
        next unless entry

        regular = if index == segments.length - 1
          entry["type"] == "blob" && entry["mode"].in?(%w[100644 100755])
        else
          entry["type"] == "tree" && entry["mode"] == "040000"
        end
        raise GithubClient::Error, "Um caminho do livro contém link, submódulo ou tipo incompatível. Corrija a pasta remota antes de sincronizar." unless regular
      end
    end

    def blob_sha(content, sha)
      algorithm = sha.length == 64 ? Digest::SHA256 : Digest::SHA1
      algorithm.hexdigest("blob #{content.bytesize}\0".b + content.b)
    end

    def failed(message)
      message = "#{message} Alguns arquivos podem ter sido publicados; o manuscrito original foi preservado."
      @state.update!(@counts.merge(status: "failed", error_message: message, obsolete_files: @obsolete_files))
      Result.new(state: @state, success: false, message: message)
    end

    def summary
      "Sincronização concluída: #{@counts[:created_count]} criados, #{@counts[:updated_count]} atualizados e #{@counts[:unchanged_count]} sem alterações. #{@obsolete_files.size} arquivos obsoletos preservados."
    end
  end
end
