module Cards
  class PayInvoice
    def self.call(...)
      new(...).call
    end

    def initialize(card:, user:, balance_month:)
      @card = card
      @user = user
      @balance_month = balance_month
    end

    def call
      now = Time.current

      ActiveRecord::Base.transaction do
        card.expenses
            .where(user: user)
            .where(paid: false, payment_method: Expense.card_payment_method_values)
            .where(balance_month: balance_month.beginning_of_month..balance_month.end_of_month)
            .update_all(paid: true, paid_at: now, updated_at: now)
      end
    end

    private

    attr_reader :card, :user, :balance_month
  end
end
