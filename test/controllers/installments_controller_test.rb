require "test_helper"

class InstallmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get installments_edit_url
    assert_response :success
  end

  test "should get update" do
    get installments_update_url
    assert_response :success
  end
end
