module McpIntegration
  class TokensController < Doorkeeper::TokensController
    before_action :validate_mcp_token_request

    def introspect
      head :not_found
    end

    private

    def validate_mcp_token_request
      return head :not_found unless Settings.enabled?
      return unless action_name == "create"

      if params[:resource].present? && params[:resource] != Settings.resource
        render json: { error: "invalid_target" }, status: :bad_request
      elsif params[:grant_type] == "refresh_token"
        token = Doorkeeper::AccessToken.by_refresh_token(params[:refresh_token].to_s)
        if token && (token.created_at < 30.days.ago || token.mcp_resource != Settings.resource || !User.exists?(token.resource_owner_id))
          token.revoke
          render json: { error: "invalid_grant" }, status: :bad_request
        end
      end
    end
  end
end
