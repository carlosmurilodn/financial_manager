require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_index_url
    assert_response :success
  end

  test "should get forecast" do
    get reports_forecast_url
    assert_response :success
  end

  test "should get forecast_pdf" do
    get reports_forecast_pdf_url
    assert_response :success
  end
end
