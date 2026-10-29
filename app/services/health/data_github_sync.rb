require "digest"
require "timeout"

module Health
  class DataGithubSync
    class Busy < StandardError; end
    class DeadlineExceeded < StandardError; end
    BATCH_SIZE = 10

    def initialize(user, configuration: DataGithubConfiguration.new)
      @user = user
      @configuration = configuration
    end

    def call
      records = @user.health_data_github_syncs.outstanding.order(:occurred_on).limit(BATCH_SIZE)
      return unless records.exists?

      HealthDataGithubSync.connection_pool.with_connection do |connection|
        key = connection.quote("health_data_github_sync:#{@user.id}")
        locked = connection.select_value("SELECT pg_try_advisory_lock(hashtextextended(#{key}, 0))")
        raise Busy, "Outro envio está em andamento." unless locked

        begin
          records.each { |record| synchronize(record) }
        ensure
          connection.select_value("SELECT pg_advisory_unlock(hashtextextended(#{key}, 0))")
        end
      end
    end

    private

    def synchronize(record)
      revision = record.reload.revision
      return if revision == record.synced_revision

      record.update_columns(last_attempt_at: Time.current)
      Timeout.timeout(40, DeadlineExceeded) do
        raise Writing::GithubClient::Error, @configuration.error_message unless @configuration.configured?

        export = DailyDataMarkdownExport.new(@user, record.occurred_on)
        content = export.content
        client = github_client
        remote = client.remote_files
        ensure_regular_path!(export.path, remote)
        sha = remote.dig(export.path, "sha")
        algorithm = sha&.length == 64 ? Digest::SHA256 : Digest::SHA1
        unchanged = sha && algorithm.hexdigest("blob #{content.bytesize}\0".b + content.b) == sha
        client.publish(export.path, content, sha: sha) unless unchanged
      end
      record.with_lock do
        record.update!(synced_revision: revision, last_success_at: Time.current, error_message: nil,
          status: record.revision == revision ? "succeeded" : "pending")
      end
    rescue Writing::GithubClient::Error, DeadlineExceeded => error
      message = error.is_a?(DeadlineExceeded) ? "Envio excedeu o tempo disponível. Tente novamente." : error.message
      if error.is_a?(Writing::GithubClient::RepositoryUnavailable)
        @user.health_data_github_syncs.outstanding.update_all(status: "failed", error_message: message)
      else
        record.update_columns(status: "failed", error_message: message)
      end
      raise(error.is_a?(Writing::GithubClient::Error) ? error : Writing::GithubClient::Error.new(message))
    end

    def github_client
      # The shared client accepts a document owner with id and title.
      @client ||= Writing::GithubClient.new(@configuration, Struct.new(:id, :title).new(@user.id, "Peso e alimentação"),
        prefix: "usuarios/#{@user.id}/", commit_message: "Atualiza registros de peso e alimentação")
    end

    def ensure_regular_path!(path, remote)
      parts = path.split("/")
      parts.each_index do |index|
        entry = remote[parts.take(index + 1).join("/")]
        next unless entry

        regular = if index == parts.length - 1
          entry["type"] == "blob" && entry["mode"].in?(%w[100644 100755])
        else
          entry["type"] == "tree" && entry["mode"] == "040000"
        end
        raise Writing::GithubClient::Error, "Caminho remoto contém arquivo, link ou submódulo incompatível." unless regular
      end
    end
  end
end
