require "rails_helper"

RSpec.describe "Authentication" do
  describe "GET /" do
    context "when user is not signed in" do
      it "redirects to sign in" do
        get root_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      it "renders the dashboard" do
        sign_in create(:user)

        get root_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
