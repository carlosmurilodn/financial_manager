require "rails_helper"

RSpec.describe "Categories" do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /categories" do
    it "renders categories list" do
      user.categories.create!(name: "Moradia", color: Category::COLOR_PALETTE.fetch("Azul"))

      get categories_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Moradia")
    end
  end

  describe "POST /categories" do
    it "creates category for signed user" do
      expect do
        post categories_path, params: {
          category: {
            name: "Transporte",
            icon: "directions_car",
            color: Category::COLOR_PALETTE.fetch("Verde")
          }
        }
      end.to change { user.categories.count }.by(1)

      expect(response).to redirect_to(categories_path)
      expect(user.categories.last).to have_attributes(
        name: "Transporte",
        icon: "directions_car",
        color: Category::COLOR_PALETTE.fetch("Verde")
      )
    end

    it "renders new when params are invalid" do
      expect do
        post categories_path, params: { category: { name: "" } }
      end.not_to change(Category, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /categories/:id" do
    it "updates category owned by signed user" do
      category = user.categories.create!(name: "Lazer", color: Category::COLOR_PALETTE.fetch("Roxo"))

      patch category_path(category), params: {
        category: {
          name: "Entretenimento",
          icon: "movie",
          color: Category::COLOR_PALETTE.fetch("Rosa")
        }
      }

      expect(response).to redirect_to(categories_path)
      expect(category.reload).to have_attributes(
        name: "Entretenimento",
        icon: "movie",
        color: Category::COLOR_PALETTE.fetch("Rosa")
      )
    end

    it "does not update category from another user" do
      other_user = create(:user)
      category = other_user.categories.create!(name: "Outro usuario", color: Category::COLOR_PALETTE.fetch("Azul"))

      patch category_path(category), params: { category: { name: "Invadida" } }

      expect(response).to have_http_status(:not_found)
      expect(category.reload.name).to eq("Outro usuario")
    end
  end

  describe "DELETE /categories/:id" do
    it "destroys category owned by signed user" do
      category = user.categories.create!(name: "Temporaria", color: Category::COLOR_PALETTE.fetch("Cinza"))

      expect do
        delete category_path(category)
      end.to change { user.categories.count }.by(-1)

      expect(response).to redirect_to(categories_path)
    end
  end
end
