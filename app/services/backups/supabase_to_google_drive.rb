require "json"
require "open3"
require "stringio"
require "tmpdir"
require "uri"
require "zlib"

require "google/apis/drive_v3"
require "googleauth"

module Backups
  class SupabaseToGoogleDrive
    Result = Data.define(:filename, :drive_file_id, :drive_web_view_link)

    class Error < StandardError; end
    class ConfigurationError < Error; end

    SCOPE = "https://www.googleapis.com/auth/drive"

    def self.call(...)
      new(...).call
    end

    def initialize(
      database_url: ENV["BACKUP_DATABASE_URL"].presence || ENV["DATABASE_URL_FINANCIAL_MANAGER"],
      folder_id: ENV["GOOGLE_DRIVE_FOLDER_ID"],
      service_account_json: ENV["GOOGLE_SERVICE_ACCOUNT_JSON"]
    )
      @database_url = database_url
      @folder_id = folder_id
      @service_account_json = service_account_json
    end

    def call
      validate_configuration!

      Dir.mktmpdir("financial-manager-backup") do |dir|
        sql_path = File.join(dir, "#{filename_base}.sql")
        gzip_path = "#{sql_path}.gz"

        Rails.logger.info("Backup started: database=#{database_log_label}, target_folder=#{folder_id}")
        dump_database(sql_path)
        gzip_file(sql_path, gzip_path)
        validate_drive_folder_access!
        upload_file(gzip_path)
      end
    end

    private

    attr_reader :database_url, :folder_id, :service_account_json

    def validate_configuration!
      raise ConfigurationError, "BACKUP_DATABASE_URL ou DATABASE_URL_FINANCIAL_MANAGER nao configurada" if database_url.blank?
      raise ConfigurationError, "GOOGLE_DRIVE_FOLDER_ID nao configurado" if folder_id.blank?
      raise ConfigurationError, "GOOGLE_SERVICE_ACCOUNT_JSON nao configurado" if service_account_json.blank?
      raise ConfigurationError, "URL do banco de backup sem usuario" if database_uri.user.blank?
      raise ConfigurationError, "URL do banco de backup sem senha" if database_uri.password.blank?
    end

    def dump_database(sql_path)
      stdout, stderr, status = Open3.capture3(pg_environment, *pg_dump_command(sql_path))

      if status.success?
        Rails.logger.info("Backup pg_dump finished: size=#{File.size(sql_path)} bytes")
        return
      end

      Rails.logger.error("Backup pg_dump failed: #{sanitize(stderr.presence || stdout)}")
      raise Error, "pg_dump falhou. Verifique conexao com Supabase e credenciais do banco."
    end

    def pg_dump_command(sql_path)
      [
        "pg_dump",
        "-h", database_uri.host,
        "-p", database_uri.port.to_s,
        "-U", URI.decode_www_form_component(database_uri.user),
        "-d", database_name,
        "--schema=public",
        "--no-owner",
        "--no-privileges",
        "--file=#{sql_path}"
      ]
    end

    def pg_environment
      {
        "PGPASSWORD" => URI.decode_www_form_component(database_uri.password.to_s),
        "PGSSLMODE" => database_sslmode
      }
    end

    def database_uri
      @database_uri ||= URI.parse(database_url)
    rescue URI::InvalidURIError
      raise ConfigurationError, "URL do banco de backup invalida"
    end

    def database_name
      name = database_uri.path.to_s.delete_prefix("/")
      raise ConfigurationError, "URL do banco de backup sem database" if name.blank?

      name
    end

    def database_sslmode
      params = URI.decode_www_form(database_uri.query.to_s).to_h
      params.fetch("sslmode", "require")
    end

    def gzip_file(source_path, gzip_path)
      Zlib::GzipWriter.open(gzip_path) do |gzip|
        File.open(source_path, "rb") do |source|
          IO.copy_stream(source, gzip)
        end
      end

      Rails.logger.info("Backup gzip finished: size=#{File.size(gzip_path)} bytes")
    rescue StandardError => e
      Rails.logger.error("Backup gzip failed: #{e.class} - #{e.message}")
      raise Error, "compactacao do backup falhou"
    end

    def upload_file(path)
      metadata = Google::Apis::DriveV3::File.new(
        name: File.basename(path),
        parents: [ folder_id ],
        mime_type: "application/gzip"
      )

      uploaded_file = drive_service.create_file(
        metadata,
        fields: "id, webViewLink",
        supports_all_drives: true,
        upload_source: path,
        content_type: "application/gzip"
      )

      Result.new(
        filename: File.basename(path),
        drive_file_id: uploaded_file.id,
        drive_web_view_link: uploaded_file.web_view_link
      ).tap do |result|
        Rails.logger.info("Backup Google Drive upload finished: file_id=#{result.drive_file_id}")
      end
    rescue Google::Apis::Error => e
      Rails.logger.error("Backup Google Drive upload failed: #{e.class} - #{e.message}")
      raise Error, "upload para Google Drive falhou"
    rescue Signet::AuthorizationError => e
      Rails.logger.error("Backup Google Drive authorization failed: #{e.class} - #{e.message}")
      raise Error, "autorizacao do Google Drive falhou"
    end

    def validate_drive_folder_access!
      folder = drive_service.get_file(
        folder_id,
        fields: "id, name, mimeType",
        supports_all_drives: true
      )

      return if folder.mime_type == "application/vnd.google-apps.folder"

      raise Error, "GOOGLE_DRIVE_FOLDER_ID nao aponta para uma pasta"
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Backup Google Drive folder access failed: #{e.class} - #{e.message}")
      raise Error, "pasta do Google Drive nao encontrada ou sem permissao para a service account"
    end

    def drive_service
      @drive_service ||= Google::Apis::DriveV3::DriveService.new.tap do |service|
        service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(service_account_json),
          scope: SCOPE
        )
      end
    rescue JSON::ParserError => e
      Rails.logger.error("Backup Google credentials invalid JSON: #{e.message}")
      raise ConfigurationError, "GOOGLE_SERVICE_ACCOUNT_JSON invalido"
    end

    def filename_base
      "financial_manager_supabase_#{Time.current.strftime('%Y%m%d_%H%M%S')}"
    end

    def sanitize(text)
      text.to_s.gsub(database_url.to_s, "[DATABASE_URL]")
    end

    def database_log_label
      "#{database_uri.host}/#{database_name}"
    end
  end
end
