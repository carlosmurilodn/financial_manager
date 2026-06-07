module Incomes
  class CreateRecurring
    def self.call(...)
      new(...).call
    end

    def initialize(income:, user:)
      @income = income
      @user = user
    end

    def call
      repetitions.times do |index|
        user.incomes.create!(
          description: income.description,
          amount: income.amount,
          date: income.date + (index + 1).month,
          balance_month: income.balance_month + (index + 1).month,
          paid: false,
          category_id: income.category_id
        )
      end
    end

    private

    attr_reader :income, :user

    def repetitions
      [ income.repetir.to_i, 0 ].max
    end
  end
end
