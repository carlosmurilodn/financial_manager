module McpIntegration
  class MetadataController < ActionController::API
    before_action :check_enabled

    def resource
      render json: { resource: Settings.resource, authorization_servers: [ Settings.base_url ],
        scopes_supported: [ Settings::SCOPE ], bearer_methods_supported: [ "header" ],
        resource_name: "Gerenciador Pessoal — Estúdio De Escrita" }
    end

    def authorization_server
      render json: { issuer: Settings.base_url, authorization_endpoint: "#{Settings.base_url}/oauth/authorize",
        token_endpoint: "#{Settings.base_url}/oauth/token", revocation_endpoint: "#{Settings.base_url}/oauth/revoke",
        response_types_supported: [ "code" ], grant_types_supported: %w[authorization_code refresh_token],
        token_endpoint_auth_methods_supported: %w[client_secret_basic client_secret_post none],
        scopes_supported: [ Settings::SCOPE ], code_challenge_methods_supported: [ "S256" ] }
    end

    private

    def check_enabled
      return head :not_found unless Settings.enabled?

      response.headers["Cache-Control"] = "no-store"
      response.headers["Access-Control-Allow-Origin"] = "*"
    end
  end
end
