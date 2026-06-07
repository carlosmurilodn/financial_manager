module CardsHelper
  def card_projected_used_limit(card)
    @card_projected_limit_totals_by_card.fetch(card.id, 0).to_f
  end

  def card_available_limit(card)
    card.total_limit.to_f - card_projected_used_limit(card)
  end

  def card_selected_month_total(card)
    @card_month_totals_by_card.fetch(card.id, card_projected_used_limit(card)).to_f
  end

  def card_selected_month_label
    @month.present? && @year.present? ? "Total do mês" : "Total utilizado"
  end
end
