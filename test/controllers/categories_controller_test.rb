require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "filters categories by description without accents" do
    Category.delete_all

    Category.create!(name: "Plano de Sa\u00fade")
    Category.create!(name: "Mercado")

    get categories_url, params: { description: "saude" }

    assert_response :success
    assert_includes @response.body, "Plano de Sa"
    assert_not_includes @response.body, "Mercado"
  end
end
