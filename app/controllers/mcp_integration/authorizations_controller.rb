module McpIntegration
  class AuthorizationsController < Doorkeeper::AuthorizationsController
    before_action :validate_mcp_authorization
    layout "application"

    def show
      head :not_found
    end

    private

    def validate_mcp_authorization
      return head :not_found unless Settings.enabled?

      resource = params[:resource].presence || params[:mcp_resource]
      if resource != Settings.resource
        render json: { error: "invalid_target" }, status: :bad_request
      elsif params[:code_challenge_method] != "S256" || !params[:code_challenge].to_s.match?(/\A[A-Za-z0-9_-]{43}\z/)
        render json: { error: "invalid_request", error_description: "PKCE S256 obrigatório." }, status: :bad_request
      else
        params[:mcp_resource] = Settings.resource
      end
    end
  end
end
