require "mcp"

module McpIntegration
  class Endpoint
    def call(env)
      request = Rack::Request.new(env)
      return response(404, "not_found") unless Settings.enabled? && [ "", "/" ].include?(request.path_info)
      uri = URI.parse(Settings.base_url)
      return response(403, "forbidden") unless request.host == uri.host && request.port == uri.port
      return response(403, "forbidden") if Rails.env.production? && !request.ssl?
      origin = request.get_header("HTTP_ORIGIN")
      return response(403, "forbidden") if origin && !Settings.allowed_origins.include?(origin)

      authorization = request.get_header("HTTP_AUTHORIZATION").to_s
      match = authorization.match(/\ABearer ([A-Za-z0-9._~-]+)\z/i)
      token = match && Doorkeeper::AccessToken.by_token(match[1])
      return unauthorized unless token&.accessible? && token.expires_in && token.mcp_resource == Settings.resource
      return unauthorized("insufficient_scope", 403) unless token.scopes.include?(Settings::SCOPE)

      user = User.find_by(id: token.resource_owner_id)
      return unauthorized unless user

      configuration = MCP::Configuration.new(protocol_version: "2025-11-25",
        exception_reporter: ->(error, _context) { Rails.logger.error("MCP failure: #{error.class.name}") })
      server = MCP::Server.new(name: "gerenciador_pessoal", title: "Estúdio De Escrita", version: Settings::VERSION,
        tools: [ GetServerInfo ], server_context: UserContext.new(user), configuration: configuration)
      transport = MCP::Server::Transports::StreamableHTTPTransport.new(server, stateless: true, enable_json_response: true,
        allowed_hosts: [ uri.host ], allowed_origins: Settings.allowed_origins, max_request_bytes: Settings::MAX_REQUEST_BYTES,
        serve_subscriptions_listen: false)
      status, headers, body = transport.call(env)
      [ status, headers.merge("cache-control" => "no-store, private"), body ]
    rescue StandardError => error
      Rails.logger.error("MCP failure: #{error.class.name}")
      [ 500, { "content-type" => "application/json", "cache-control" => "no-store" },
        [ { jsonrpc: "2.0", id: nil, error: { code: -32603, message: "Internal error" } }.to_json ] ]
    end

    private

    def response(status, code)
      [ status, { "content-type" => "application/json", "cache-control" => "no-store" }, [ { error: code }.to_json ] ]
    end

    def unauthorized(error = "invalid_token", status = 401)
      result = response(status, error)
      result[1]["www-authenticate"] = %(Bearer resource_metadata="#{Settings.base_url}/.well-known/oauth-protected-resource/mcp", error="#{error}", scope="#{Settings::SCOPE}")
      result
    end
  end
end
