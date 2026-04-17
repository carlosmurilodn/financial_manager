require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_url
    assert_response :success
  end

  test "should get forecast" do
    get forecast_reports_url
    assert_response :success
  end

  test "should get forecast_pdf" do
    get forecast_pdf_reports_url
    assert_response :success
  end
end
