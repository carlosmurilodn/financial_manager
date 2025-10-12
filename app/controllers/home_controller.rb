class HomeController < ApplicationController
  def index
    @hoje = Date.current
    @mes_atual = @hoje.beginning_of_month..@hoje.end_of_month

    # --- KPIs ---
    @saldo_atual = Income.where("balance_month <= ?", @hoje.end_of_month).sum(:amount) -
                   Expense.where("balance_month <= ?", @hoje.end_of_month).sum(:amount) -
                   Installment.where("balance_month <= ?", @hoje.end_of_month).sum(:amount)

    @receitas_mes = Income.where(balance_month: @mes_atual).sum(:amount)
    @despesas_mes = Expense.where(balance_month: @mes_atual).sum(:amount)
    @saldo_liquido = Income.sum(:amount) - Expense.sum(:amount) - Installment.sum(:amount)

    # --- Saldo por cartão ---
    @cards_info = Card.all.map do |card|
      total_expenses = Expense.where(card: card, balance_month: @mes_atual).sum(:amount)
      total_installments = Installment.joins(:expense)
                                      .where(expenses: { card_id: card.id })
                                      .where(balance_month: @mes_atual)
                                      .sum(:amount)
      { card: card, total: total_expenses + total_installments }
    end

    # --- Despesas por categoria (gráfico) ---
    @despesas_por_categoria = Category.all.map do |cat|
      despesas_soma = Expense.where(category_id: cat.id, balance_month: @mes_atual).sum(:amount)
      parcelas_soma = Installment.joins(:expense)
                                 .where(expenses: { category_id: cat.id })
                                 .where(balance_month: @mes_atual)
                                 .sum(:amount)
      [cat.name, despesas_soma + parcelas_soma]
    end.reject { |_, total| total.zero? }
     .sort_by { |_, total| -total }
     .to_h

    # --- Detalhes das despesas (tooltip do gráfico) ---
    despesas_com_parcelas_ids = Installment.where(balance_month: @mes_atual).select(:expense_id)

    @detalhes_despesas_por_categoria =
      Expense.includes(:installments, :category)
            .where("balance_month BETWEEN ? AND ? OR id IN (?)", @mes_atual.begin, @mes_atual.end, despesas_com_parcelas_ids)
            .group_by { |e| e.category.name }
            .transform_values do |expenses|
        detalhes = []

        expenses.each do |e|
          parcelas_no_mes = e.installments.where(balance_month: @mes_atual)

          if e.payment_method_credito_parcelado? && parcelas_no_mes.any?
            # Inclui apenas parcelas do mês
            parcelas_no_mes.each do |p|
              valor_parcela = ActionController::Base.helpers.number_to_currency(
                p.amount, unit: "R$ ", separator: ",", delimiter: "."
              )
              detalhes << "#{e.description} - Parcela #{p.number}/#{e.installments_count} (#{valor_parcela})"
            end

          elsif @mes_atual.cover?(e.balance_month)
            # Despesa única ou parcela única no mês
            valor = ActionController::Base.helpers.number_to_currency(
              e.amount, unit: "R$ ", separator: ",", delimiter: "."
            )
            detalhes << "#{e.description} (#{valor})"
          end
        end

        detalhes
      end

    # --- Receitas x Despesas (últimos 4 meses) ---
    @meses_datas = 4.times.map { |i| @hoje - i.months }.reverse
    @meses_labels = @meses_datas.map { |d| d.strftime('%B') }

    @receitas_mensais = @meses_datas.map do |data|
      Income.where(balance_month: data.beginning_of_month..data.end_of_month).sum(:amount)
    end

    @despesas_mensais = @meses_datas.map do |data|
      despesas_soma = Expense.where(balance_month: data.beginning_of_month..data.end_of_month).sum(:amount)
      parcelas_soma = Installment.where(balance_month: data.beginning_of_month..data.end_of_month).sum(:amount)
      despesas_soma + parcelas_soma
    end
  end
end
