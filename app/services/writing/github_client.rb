require "base64"
require "json"
require "net/http"
require "uri"

module Writing
  class GithubClient
    class Error < StandardError; end
    class Conflict < Error; end
    API_VERSION = "2026-03-10"

    def initialize(configuration, book_id)
      @configuration = configuration
      @book_id = Integer(book_id)
      @prefix = "livros/livro-#{@book_id}/"
    end

    attr_reader :prefix

    def inspect
      "#<#{self.class.name} credentials=[FILTERED]>"
    end

    def remote_files
      raise Error, @configuration.error_message unless @configuration.configured?

      repository = request(:get, repository_path)
      raise Error, "Sincronização permitida somente com repositório privado." unless repository["private"] == true

      ref = request(:get, "#{repository_path}/git/ref/heads/#{encode(@configuration.branch)}", missing: "Branch indisponível. Inicialize o repositório com um README e confira GITHUB_WRITING_BRANCH.")
      object = ref.fetch("object")
      raise Error, "Referência de branch inválida." unless object["type"] == "commit"

      commit = request(:get, "#{repository_path}/git/commits/#{valid_sha(object.fetch('sha'))}")
      tree_sha = valid_sha(commit.fetch("tree").fetch("sha"))
      prefix.delete_suffix("/").split("/").each do |directory|
        entry = tree(tree_sha).find { |item| item["path"] == directory }
        return {} unless entry
        unless entry["type"] == "tree" && entry["mode"] == "040000"
          raise Error, "A pasta do livro contém um arquivo, link ou submódulo no lugar de um diretório. Nenhum arquivo será sobrescrito."
        end
        tree_sha = valid_sha(entry.fetch("sha"))
      end
      tree(tree_sha, recursive: true).to_h { |entry| [ entry.fetch("path"), entry ] }
    rescue KeyError, TypeError
      raise Error, "GitHub retornou estrutura de dados inesperada. Tente novamente."
    end

    def publish(path, content, sha: nil)
      unless path.match?(%r{\A[\w/-]+\.md\z}) && !path.include?("..") && !path.start_with?("/")
        raise Error, "Caminho de documento inválido."
      end
      raise Error, "Documento excede o limite de 100 MB do GitHub." if content.bytesize > 100.megabytes

      # GitHub recommends serial mutations with at least one second between writes.
      if @last_write_at
        remaining = 1 - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @last_write_at)
        sleep(remaining) if remaining.positive?
      end
      body = { message: "Atualiza contexto literário de livro-#{@book_id}",
        content: Base64.strict_encode64(content), branch: @configuration.branch }
      body[:sha] = valid_sha(sha) if sha
      request(:put, "#{repository_path}/contents/#{encode_path(prefix + path)}", body: body)
      @last_write_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    private

    def repository_path
      "/repos/#{encode_path(@configuration.repository)}"
    end

    def encode(value)
      URI.encode_www_form_component(value).gsub("+", "%20")
    end

    def encode_path(value)
      value.split("/").map { |part| encode(part) }.join("/")
    end

    def valid_sha(value)
      raise Error, "GitHub retornou identificador de conteúdo inválido." unless value.to_s.match?(/\A(?:[a-f0-9]{40}|[a-f0-9]{64})\z/)

      value
    end

    def tree(sha, recursive: false)
      suffix = recursive ? "?recursive=1" : ""
      data = request(:get, "#{repository_path}/git/trees/#{valid_sha(sha)}#{suffix}")
      raise Error, "Listagem remota incompleta. Sincronização interrompida sem excluir arquivos." if data["truncated"]
      entries = data.fetch("tree")
      raise Error, "Listagem remota inválida." unless entries.is_a?(Array)

      entries
    end

    def request(method, path, body: nil, missing: nil)
      uri = URI.parse("https://api.github.com#{path}")
      http = Net::HTTP.new(uri.host, uri.port, nil)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.open_timeout = 5
      http.read_timeout = 20
      http.write_timeout = 20
      http.max_retries = 0
      request_class = method == :put ? Net::HTTP::Put : Net::HTTP::Get
      message = request_class.new(uri.request_uri)
      message["Authorization"] = @configuration.authorization
      message["Accept"] = "application/vnd.github+json"
      message["X-GitHub-Api-Version"] = API_VERSION
      message["User-Agent"] = "Gerenciador-Pessoal-Writing"
      if body
        message["Content-Type"] = "application/json"
        message.body = JSON.generate(body)
      end
      response = http.request(message)
      code = response.code.to_i
      return JSON.parse(response.body) if code.in?([ 200, 201 ])

      case code
      when 401 then raise Error, "GitHub recusou autenticação. Confira validade e autorização do token no servidor."
      when 403, 429 then raise Error, "GitHub recusou acesso ou limitou requisições. Confira Contents: Read and write e aguarde antes de tentar novamente."
      when 404 then raise Error, missing || "Repositório ou branch indisponível. Confira configuração e acesso do token ao repositório privado."
      when 409 then raise Conflict, "Conflito de atualização no GitHub. Inicialize o repositório se estiver vazio; caso contrário, sincronize novamente para obter os SHAs atuais."
      when 422 then raise Error, "GitHub recusou a atualização. Confira branch, regras de proteção e limites dos documentos."
      when 500..599 then raise Error, "GitHub temporariamente indisponível. Tente novamente mais tarde."
      else raise Error, "Resposta inesperada do GitHub. Confira configuração e tente novamente."
      end
    rescue JSON::ParserError
      raise Error, "GitHub retornou resposta inválida. Tente novamente."
    rescue Timeout::Error, SocketError, IOError, SystemCallError, OpenSSL::SSL::SSLError
      raise Error, "Falha de comunicação segura com GitHub. Tente novamente."
    end
  end
end
