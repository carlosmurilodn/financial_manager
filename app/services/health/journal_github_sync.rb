require "digest"
require "timeout"

module Health
  class JournalGithubSync
    class DeadlineExceeded < StandardError; end
    Result = Struct.new(:success, :message, keyword_init: true)

    def initialize(entry, configuration: JournalGithubConfiguration.new)
      @entry = entry
      @configuration = configuration
    end

    def call
      return failed(@configuration.error_message) unless @configuration.configured?

      HealthJournalEntry.connection_pool.with_connection do |connection|
        key = connection.quote("journal_github_sync:#{@entry.user_id}")
        locked = connection.select_value("SELECT pg_try_advisory_lock(hashtextextended(#{key}, 0))")
        return Result.new(success: false, message: "Há outro envio do diário em andamento. Registro salvo; tente sincronizar novamente.") unless locked

        begin
          Timeout.timeout(40, DeadlineExceeded) { synchronize }
        ensure
          connection.select_value("SELECT pg_advisory_unlock(hashtextextended(#{key}, 0))")
        end
      end
    rescue Writing::GithubClient::Error => error
      failed(error.message)
    rescue DeadlineExceeded
      failed("Envio excedeu o tempo disponível. Tente novamente; conteúdo já enviado será reconhecido.")
    rescue StandardError => error
      Rails.logger.error("Journal GitHub sync failed: #{error.class}")
      failed("Não foi possível concluir o envio ao GitHub. Tente novamente.")
    end

    private

    def synchronize
      @entry.reload
      persist("status" => "processing", "last_attempt_at" => Time.current.iso8601, "error_message" => nil)
      export = JournalMarkdownExport.new(@entry)
      path = export.path
      content = export.content
      digest = Digest::SHA256.hexdigest(content)
      prefix = "usuarios/#{@entry.user_id}/"
      client = Writing::GithubClient.new(@configuration, @entry.user_id, prefix: prefix,
        commit_message: "Atualiza acompanhamento diário de #{@entry.entry_date.iso8601}")
      remote = client.remote_files
      ensure_regular_path!(path, remote)
      existing = remote[path]
      sha = existing&.fetch("sha")
      algorithm = sha&.length == 64 ? Digest::SHA256 : Digest::SHA1
      unchanged = sha && algorithm.hexdigest("blob #{content.bytesize}\0".b + content.b) == sha
      client.publish(path, content, sha: sha) unless unchanged

      synchronized = @entry.with_lock do
        current = JournalMarkdownExport.new(@entry)
        latest = current.path == path && Digest::SHA256.hexdigest(current.content) == digest
        persist("status" => latest ? "succeeded" : "pending", "last_success_at" => Time.current.iso8601,
          "content_digest" => digest, "repository" => @configuration.repository, "branch" => @configuration.branch,
          "path" => prefix + path, "error_message" => nil)
        latest
      end
      Result.new(success: synchronized, message: synchronized ? (unchanged ? "Diário já está atualizado no GitHub." : "Diário enviado ao GitHub.") : "Diário foi alterado durante o envio. Sincronize novamente para enviar a versão mais recente.")
    end

    def ensure_regular_path!(path, remote)
      parts = path.split("/")
      parts.each_index do |index|
        entry = remote[parts.take(index + 1).join("/")]
        next unless entry

        regular = index == parts.length - 1 ? entry["type"] == "blob" && entry["mode"].in?(%w[100644 100755]) : entry["type"] == "tree" && entry["mode"] == "040000"
        raise Writing::GithubClient::Error, "Caminho do diário contém arquivo, link ou submódulo incompatível. Nenhum arquivo foi sobrescrito." unless regular
      end
    end

    def persist(attributes)
      @entry.update_columns(github_sync: @entry.github_sync.merge(attributes))
    end

    def failed(message)
      persist("status" => "failed", "last_attempt_at" => Time.current.iso8601, "error_message" => message)
      Result.new(success: false, message: message)
    rescue StandardError => error
      Rails.logger.error("Journal GitHub status failed: #{error.class}")
      Result.new(success: false, message: "Registro salvo, mas envio ao GitHub não foi confirmado. Tente sincronizar novamente.")
    end
  end
end
