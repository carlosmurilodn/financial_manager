module McpIntegration
  class AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
    before_action -> { head :not_found unless Settings.enabled? }
    layout "application"

    def index
      @applications = Doorkeeper::Application.authorized_for(current_resource_owner)
      respond_to do |format|
        format.html
        format.json { render json: @applications.map { |application| { id: application.id, name: application.name } } }
      end
    end
  end
end
