class HomeController < ApplicationController
  def index
    @hoje = Date.current
    @mes_atual = @hoje.beginning_of_month..@hoje.end_of_month

    # --- Cards KPIs ---
    @receitas_mes = Income.where(date: @mes_atual, paid: true).sum(:amount)

    @despesas_mes = Expense.includes(:installments).sum do |e|
      if e.payment_method_credito_parcelado? && e.installments.any?
        e.installments.select(&:paid?).sum(&:amount)
      else
        e.paid? ? e.amount : 0
      end
    end

    @saldo_atual = @receitas_mes - @despesas_mes
    @saldo_liquido = @saldo_atual

    # --- Listas recentes ---
    @despesas_recentes = Expense.includes(:category).order(date: :desc).limit(5)
    @receitas_recentes = Income.order(date: :desc).limit(5)

    # --- Gráfico Despesas por Categoria ---
    categorias = Category.includes(:expenses).all
    @categorias_despesas = categorias.map(&:name)
    @categorias_emoji = categorias.map(&:display_name)

    @valores_despesas = categorias.map do |cat|
      cat.expenses.includes(:installments).sum do |e|
        if e.payment_method_credito_parcelado? && e.installments.any?
          e.installments.select(&:paid?).sum(&:amount)
        else
          e.paid? ? e.amount : 0
        end
      end
    end

    # Cores dinâmicas
    cores_base = ['#dc3545','#fd7e14','#ffc107','#6c757d','#0d6efd','#198754']
    @cores_despesas = (cores_base * ((@categorias_despesas.size / cores_base.size.to_f).ceil)).first(@categorias_despesas.size)

    # --- Gráfico Receitas x Despesas últimos 4 meses ---
    @meses = 3.downto(0).map { |i| (Date.current - i.months).strftime("%b") }

    @valores_receitas = 3.downto(0).map do |i|
      mes = (Date.current - i.months)
      Income.where(date: mes.beginning_of_month..mes.end_of_month, paid: true).sum(:amount)
    end

    @valores_despesas = 3.downto(0).map do |i|
      mes = (Date.current - i.months)
      Expense.includes(:installments).sum do |e|
        if e.payment_method_credito_parcelado? && e.installments.any?
          e.installments.select { |p| p.paid? && p.due_date&.month == mes.month && p.due_date&.year == mes.year }.sum(&:amount)
        else
          e.paid? && e.date.month == mes.month && e.date.year == mes.year ? e.amount : 0
        end
      end
    end
  end
end
