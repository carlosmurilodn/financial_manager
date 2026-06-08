require "rails_helper"

RSpec.describe "Incomes" do
  let(:user) { create(:user) }
  let(:category) { user.categories.create!(name: "Salario #{SecureRandom.hex(4)}", color: Category::COLOR_PALETTE.fetch("Verde")) }

  before do
    sign_in user
  end

  describe "GET /incomes" do
    it "renders incomes list for signed user" do
      create(:income, user: user, category: category, description: "Salario mensal", amount: 3_500, balance_month: Date.new(2026, 6, 1))
      create(:income, user: create(:user), description: "Receita externa")

      get incomes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Salario mensal")
      expect(response.body).not_to include("Receita externa")
    end
  end

  describe "POST /incomes" do
    it "creates income for signed user parsing Brazilian amount and dates" do
      expect do
        post incomes_path, params: {
          income: {
            description: "Bonus",
            amount: "R$ 1.234,56",
            date: "10/06/2026",
            balance_month: "01/06/2026",
            paid: "1",
            category_id: category.id
          }
        }
      end.to change { user.incomes.count }.by(1)

      income = user.incomes.last

      expect(response).to redirect_to(incomes_path)
      expect(income).to have_attributes(
        description: "Bonus",
        amount: 1_234.56.to_d,
        date: Date.new(2026, 6, 10),
        balance_month: Date.new(2026, 6, 1),
        paid: true,
        category_id: category.id
      )
    end

    it "ignores category from another user" do
      other_category = create(:user).categories.create!(name: "Categoria externa #{SecureRandom.hex(4)}", color: Category::COLOR_PALETTE.fetch("Azul"))

      post incomes_path, params: {
        income: {
          description: "Sem categoria propria",
          amount: "500,00",
          date: "15/06/2026",
          balance_month: "01/06/2026",
          category_id: other_category.id
        }
      }

      expect(user.incomes.last.category_id).to be_nil
    end

    it "renders new when params are invalid" do
      expect do
        post incomes_path, params: { income: { amount: "", date: "", balance_month: "" } }
      end.not_to change(Income, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /incomes/:id" do
    it "updates income owned by signed user" do
      income = create(:income, user: user, category: category, description: "Freela", amount: 500, date: Date.new(2026, 6, 5), balance_month: Date.new(2026, 6, 1))

      patch income_path(income), params: {
        income: {
          description: "Freela atualizado",
          amount: "750,25",
          date: "07/07/2026",
          balance_month: "01/07/2026",
          paid: "0",
          category_id: category.id
        }
      }

      expect(response).to redirect_to(incomes_path)
      expect(income.reload).to have_attributes(
        description: "Freela atualizado",
        amount: 750.25.to_d,
        date: Date.new(2026, 7, 7),
        balance_month: Date.new(2026, 7, 1),
        paid: false
      )
    end

    it "does not update income from another user" do
      income = create(:income, user: create(:user), description: "Outra receita")

      patch income_path(income), params: { income: { description: "Invadida", amount: "1.000,00", date: "01/06/2026", balance_month: "01/06/2026" } }

      expect(response).to have_http_status(:not_found)
      expect(income.reload.description).to eq("Outra receita")
    end
  end

  describe "PATCH /incomes/:id/toggle_paid" do
    it "toggles paid status" do
      income = create(:income, user: user, category: category, paid: false)

      patch toggle_paid_income_path(income)

      expect(response).to redirect_to(incomes_path)
      expect(income.reload).to be_paid
    end
  end

  describe "DELETE /incomes/:id" do
    it "destroys income owned by signed user" do
      income = create(:income, user: user, category: category)

      expect do
        delete income_path(income)
      end.to change { user.incomes.count }.by(-1)

      expect(response).to redirect_to(incomes_path)
    end
  end

  describe "DELETE /incomes/clear_filters" do
    it "clears persisted filters" do
      get incomes_path, params: { month: "6", year: "2026", description: "bonus", paid: "true" }

      delete clear_filters_incomes_path

      expect(response).to redirect_to(incomes_path)
      expect(session[:incomes_month]).to be_nil
      expect(session[:incomes_year]).to be_nil
      expect(session[:incomes_description]).to be_nil
      expect(session[:incomes_paid]).to be_nil
    end
  end
end
