require "open3"
require "tmpdir"
require "uri"
require "zlib"

module Backups
  class DatabaseDump
    Result = Data.define(:filename, :content_type, :data)

    class Error < StandardError; end
    class ConfigurationError < Error; end

    CONTENT_TYPE = "application/gzip"

    def self.call(...)
      new(...).call
    end

    def initialize(database_url: ENV["BACKUP_DATABASE_URL"].presence || ENV["DATABASE_URL_FINANCIAL_MANAGER"])
      @database_url = database_url
    end

    def call
      validate_configuration!

      Dir.mktmpdir("financial-manager-backup") do |dir|
        sql_path = File.join(dir, "#{filename_base}.sql")
        gzip_path = "#{sql_path}.gz"

        Rails.logger.info("Backup download started: database=#{database_log_label}")
        dump_database(sql_path)
        gzip_file(sql_path, gzip_path)

        Result.new(
          filename: File.basename(gzip_path),
          content_type: CONTENT_TYPE,
          data: File.binread(gzip_path)
        )
      end
    end

    private

    attr_reader :database_url

    def validate_configuration!
      raise ConfigurationError, "BACKUP_DATABASE_URL ou DATABASE_URL_FINANCIAL_MANAGER nao configurada" if database_url.blank?
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
