module Cards
  class IndexQuery
    Result = Struct.new(
      :cards,
      :debt_years,
      :debt_totals_by_card,
      :projected_limit_totals_by_card,
      :month_totals_by_card,
      :limit_total,
      :limit_available,
      :limit_used,
      :open_invoices,
      keyword_init: true
    )

    def initialize(user:, description:, month:, year:)
      @user = user
      @description = description
      @month = month
      @year = year
    end

    def call
      debt_scope = card_debt_scope
      accumulated_debt_scope = accumulated_debt_period(debt_scope)
      projected_limit_scope = projected_limit_period(debt_scope)
      month_expense_scope = month_expense_period(card_expense_scope, accumulated_debt_scope)

      debt_totals_by_card = Expense.effective_sum_by_card(accumulated_debt_scope)
      projected_limit_totals_by_card = Expense.effective_sum_by_card(projected_limit_scope)
      cards = filtered_cards(accumulated_debt_scope)
      limit_total = cards.sum { |card| card.total_limit.to_f }
      limit_available = cards.sum { |card| remaining_limit_for(card, projected_limit_totals_by_card) }

      Result.new(
        cards: cards,
        debt_years: debt_year_options(debt_scope),
        debt_totals_by_card: debt_totals_by_card,
        projected_limit_totals_by_card: projected_limit_totals_by_card,
        month_totals_by_card: Expense.effective_sum_by_card(month_expense_scope),
        limit_total: limit_total,
        limit_available: limit_available,
        limit_used: limit_total - limit_available,
        open_invoices: cards.sum { |card| debt_totals_by_card.fetch(card.id, 0).to_f }
      )
    end

    private

    attr_reader :user, :description, :month, :year

    def card_debt_scope
      user.expenses
          .where(paid: false, payment_method: Expense.card_payment_method_values)
          .where.not(card_id: nil)
    end

    def card_expense_scope
      user.expenses
          .where(payment_method: Expense.card_payment_method_values)
          .where.not(card_id: nil)
    end

    def filtered_cards(accumulated_debt_scope)
      cards = user.cards.order(:name).to_a
      return cards unless filters_active?

      card_ids_from_debt = card_filter_match_scope(debt_filters(card_debt_scope), accumulated_debt_scope)
                           .distinct
                           .pluck(:card_id)
      cards.select { |card| card_ids_from_debt.include?(card.id) }
    end

    def debt_filters(scope)
      filtered_scope = scope
      filtered_scope = filtered_scope.where("EXTRACT(MONTH FROM balance_month) = ?", month) if month.present?
      filtered_scope = filtered_scope.where("EXTRACT(YEAR FROM balance_month) = ?", year) if year.present?

      description_filter(filtered_scope)
    end

    def accumulated_debt_period(scope)
      return description_filter(scope) unless complete_period_filter?

      description_filter(scope.where("balance_month >= ?", Date.new(year, month, 1)))
    rescue ArgumentError
      description_filter(scope)
    end

    def projected_limit_period(scope)
      return description_filter(scope) unless complete_period_filter?

      description_filter(scope.where("balance_month >= ?", Date.new(year, month, 1).next_month))
    rescue ArgumentError
      description_filter(scope)
    end

    def month_expense_period(scope, fallback_scope)
      return fallback_scope unless complete_period_filter?

      balance_month = Date.new(year, month, 1)
      description_filter(scope.where(balance_month: balance_month.all_month))
    rescue ArgumentError
      fallback_scope
    end

    def description_filter(scope)
      return scope if description.blank?

      query = "%#{description.downcase}%"
      matching_card_ids = user.cards.where("LOWER(name) LIKE ?", query).pluck(:id)

      return scope.where("LOWER(description) LIKE ?", query) if matching_card_ids.blank?

      scope.where("LOWER(description) LIKE :query OR card_id IN (:card_ids)", query: query, card_ids: matching_card_ids)
    end

    def debt_year_options(scope)
      scope.pluck(:balance_month)
           .compact
           .map(&:year)
           .uniq
           .sort
    end

    def filters_active?
      description.present? || month.present? || year.present?
    end

    def complete_period_filter?
      month.present? && year.present?
    end

    def card_filter_match_scope(filtered_debt_scope, accumulated_debt_scope)
      complete_period_filter? ? accumulated_debt_scope : filtered_debt_scope
    end

    def remaining_limit_for(card, projected_limit_totals_by_card)
      card.total_limit.to_f - projected_limit_totals_by_card.fetch(card.id, 0).to_f
    end
  end
end
