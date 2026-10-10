require "fileutils"
require "json"
require "securerandom"
require "tempfile"

module Writing
  class PublicationStore
    class Missing < StandardError; end
    TTL = 1.hour
    attr_reader :key

    def self.root
      Pathname.new(ENV.fetch("WRITING_PDF_TMP_DIR", Rails.root.join("tmp/writing_publications").to_s))
    end

    def self.cleanup
      return unless root.directory?

      root.children.each do |path|
        next unless path.directory? && path.basename.to_s.match?(/\A[0-9a-f]{32}\z/)

        begin
          created = JSON.parse(File.read(path.join("status.json"))).fetch("created_at")
          FileUtils.remove_entry_secure(path.to_s, true) if created + TTL.to_i < Time.current.to_i
        rescue Errno::ENOENT
          next
        rescue JSON::ParserError, KeyError
          FileUtils.remove_entry_secure(path.to_s, true)
        end
      end
    end

    def self.active_count(user_id)
      return 0 unless root.directory?

      root.children.count do |path|
        next false unless path.directory? && path.basename.to_s.match?(/\A[0-9a-f]{32}\z/)

        begin
          data = new(path.basename.to_s).read
          data["user_id"] == user_id && data["state"].in?(%w[queued processing])
        rescue Missing
          false
        end
      end
    end

    def initialize(key = SecureRandom.hex(16))
      raise Missing unless key.to_s.match?(/\A[0-9a-f]{32}\z/)

      @key = key
    end

    def directory
      self.class.root.join(key)
    end

    def pdf_path
      directory.join("book.pdf")
    end

    def create(user_id:, book_id:, settings:)
      FileUtils.mkdir_p(directory, mode: 0700)
      write("user_id" => user_id, "book_id" => book_id, "settings" => settings, "created_at" => Time.current.to_i, "process_id" => Process.pid, "state" => "queued", "message" => "Exportação aguardando processamento.")
    end

    def read
      data = JSON.parse(File.read(directory.join("status.json")))
      raise Missing if data.fetch("created_at") + TTL.to_i < Time.current.to_i

      if data["state"].in?(%w[queued processing]) && interrupted?(data)
        data.merge!("state" => "failed", "message" => interrupted_message)
        write(data)
      end
      data
    rescue Errno::ENOENT, JSON::ParserError, KeyError
      raise Missing
    end

    def update(attributes)
      write(read.merge(attributes))
    end

    def with_lock
      File.open(directory.join("generation.lock"), File::RDWR | File::CREAT, 0600) do |lock|
        return unless lock.flock(File::LOCK_EX | File::LOCK_NB)

        yield
      ensure
        lock.flock(File::LOCK_UN) if lock
      end
    end

    def remove
      FileUtils.remove_entry_secure(directory.to_s, true) if directory.directory?
    end

    private

    def interrupted_message
      "Geração interrompida por reinício do servidor. Gere um novo PDF."
    end

    def interrupted?(data)
      Process.kill(0, data.fetch("process_id"))
      false
    rescue Errno::ESRCH
      true
    rescue Errno::EPERM
      false
    end

    def write(data)
      Tempfile.create([ "status", ".json" ], directory, encoding: "UTF-8") do |file|
        file.write(JSON.generate(data))
        file.close
        File.rename(file.path, directory.join("status.json"))
      end
    end
  end
end
