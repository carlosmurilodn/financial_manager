# db/seeds.rb

categories = [
  # Moradia
  [ "home", "Aluguel" ],
  [ "lightbulb", "Conta de luz" ],
  [ "water_drop", "Água e esgoto" ],
  [ "local_fire_department", "Gás" ],

  # Transporte
  [ "local_gas_station", "Combustível" ],
  [ "local_taxi", "Aplicativos de viagem" ],
  [ "car_repair", "Manutenção do carro" ],

  # Alimentação
  [ "shopping_cart", "Supermercado" ],
  [ "fastfood", "Lanches / fast food" ],
  [ "local_cafe", "Cafés e bebidas" ],
  [ "restaurant", "Restaurantes" ],

  # Saúde e bem-estar
  [ "medication", "Medicamentos" ],
  [ "medical_services", "Consultas médicas" ],
  [ "health_and_safety", "Plano de Saúde" ],
  [ "fitness_center", "Academia / esportes" ],
  [ "self_improvement", "Terapias / bem-estar" ],

  # Educação / conhecimento
  [ "menu_book", "Cursos" ],
  [ "edit_note", "Material escolar / livros" ],
  [ "school", "Assinaturas educativas" ],

  # Lazer e entretenimento
  [ "movie", "Cinema / streaming" ],
  [ "sports_esports", "Jogos" ],
  [ "music_note", "Música / shows" ],
  [ "flight", "Viagens" ],
  [ "palette", "Hobbies" ],

  # Financeiro / investimentos
  [ "account_balance", "Banco / tarifas" ],
  [ "trending_up", "Investimentos" ],
  [ "request_quote", "Empréstimos / financiamentos" ],

  # Compras e vestuário
  [ "checkroom", "Roupas" ],
  [ "steps", "Calçados" ],
  [ "styler", "Acessórios" ],
  [ "spa", "Beleza / cuidados pessoais" ],
  [ "face", "Cosméticos" ],

  # Tecnologia / comunicação
  [ "smartphone", "Celular / planos" ],
  [ "wifi", "Internet" ],
  [ "devices", "Eletrônicos" ],
  [ "deployed_code", "Assinaturas de software" ],

  # Pets
  [ "pets", "Ração / alimentos pets" ],
  [ "pets", "Veterinário / saúde pets" ],
  [ "pets", "Acessórios pets" ],

  # Presentes / doações
  [ "redeem", "Presentes" ],
  [ "volunteer_activism", "Doações / caridade" ],

  # Outros
  [ "receipt_long", "Impostos / taxas" ],
  [ "shield", "Seguro" ],
  [ "celebration", "Eventos / festas" ],
  [ "subscriptions", "Assinaturas / serviços" ],
  [ "cleaning_services", "Cuidados domésticos" ],
  [ "directions_bike", "Fitness / esportes ao ar livre" ]
]

categories.each do |icon, name|
  category = Category.find_or_initialize_by(name: name)
  category.icon = icon
  category.save!
end

puts "Categorias seed criadas com sucesso!"

legacy_april_seed_descriptions = [
  "Conta de água abril",
  "Plano de celular",
  "Farmácia e vitaminas",
  "Consulta de rotina",
  "Mensalidade plano saúde",
  "Sessão de terapia",
  "Camisetas básicas",
  "Tênis casual",
  "Corte de cabelo",
  "Itens de cuidado pessoal",
  "Cafeteria",
  "Assinatura streaming",
  "Compra digital de jogo",
  "Consulta veterinária",
  "Brinquedos para pet",
  "Petiscos",
  "Tarifa bancária",
  "Taxa municipal",
  "Parcela seguro",
  "Parcela financiamento",
  "Livro técnico",
  "Plataforma de estudos",
  "Material para hobby"
]

Expense.where(date: Date.new(2026, 4, 1).all_month, description: legacy_april_seed_descriptions).destroy_all

april_expenses = [
  [ "2026-04-01", "Supermercado", "Compra semanal no mercado", 286.74, :debito, true ],
  [ "2026-04-08", "Supermercado", "Reposição de alimentos", 198.32, :pix, true ],
  [ "2026-04-15", "Supermercado", "Hortifruti e limpeza", 142.90, :debito, true ],
  [ "2026-04-25", "Supermercado", "Feira do fim de semana", 96.45, :dinheiro, false ],

  [ "2026-04-02", "Restaurantes", "Almoço em restaurante", 64.90, :pix, true ],
  [ "2026-04-10", "Restaurantes", "Jantar fora", 132.80, :debito, true ],
  [ "2026-04-18", "Restaurantes", "Delivery de comida", 78.50, :pix, false ],
  [ "2026-04-27", "Restaurantes", "Café da tarde", 36.20, :dinheiro, false ],

  [ "2026-04-03", "Combustível", "Abastecimento do carro", 220.00, :debito, true ],
  [ "2026-04-11", "Combustível", "Etanol posto centro", 160.00, :pix, true ],
  [ "2026-04-19", "Combustível", "Completar tanque", 245.30, :debito, false ],
  [ "2026-04-29", "Combustível", "Abastecimento viagem curta", 180.00, :pix, false ],

  [ "2026-04-04", "Conta de luz", "Conta de energia abril", 238.67, :pix, true ],
  [ "2026-04-09", "Conta de luz", "Ajuste bandeira tarifária", 42.15, :pix, true ],
  [ "2026-04-18", "Conta de luz", "Consumo adicional energia", 58.30, :pix, false ],
  [ "2026-04-27", "Conta de luz", "Complemento energia abril", 36.70, :pix, false ],

  [ "2026-04-06", "Internet", "Internet residencial", 119.90, :pix, true ],
  [ "2026-04-12", "Internet", "Upgrade temporário internet", 29.90, :pix, true ],
  [ "2026-04-20", "Internet", "Roteador e cabos", 86.40, :debito, false ],
  [ "2026-04-30", "Internet", "Serviço técnico internet", 75.00, :pix, false ],

  [ "2026-04-09", "Medicamentos", "Farmácia e vitaminas", 88.35, :debito, true ],
  [ "2026-04-13", "Medicamentos", "Medicamento de uso contínuo", 126.70, :pix, true ],
  [ "2026-04-21", "Medicamentos", "Itens de farmácia", 54.20, :debito, false ],
  [ "2026-04-28", "Medicamentos", "Reposição remédios abril", 97.45, :pix, false ],

  [ "2026-04-12", "Roupas", "Camisetas básicas", 149.90, :debito, true ],
  [ "2026-04-14", "Roupas", "Calça casual", 189.90, :debito, true ],
  [ "2026-04-20", "Roupas", "Meias e roupas íntimas", 72.50, :dinheiro, false ],
  [ "2026-04-23", "Roupas", "Blusa de frio", 159.90, :pix, false ],

  [ "2026-04-02", "Lanches / fast food", "Lanche rápido", 42.90, :pix, true ],
  [ "2026-04-16", "Lanches / fast food", "Cafeteria", 28.50, :debito, true ],
  [ "2026-04-22", "Lanches / fast food", "Pedido fast food", 57.80, :pix, false ],
  [ "2026-04-24", "Lanches / fast food", "Combo lanche noite", 64.30, :debito, false ],

  [ "2026-04-03", "Ração / alimentos pets", "Ração mensal", 189.90, :debito, true ],
  [ "2026-04-17", "Ração / alimentos pets", "Sachês para pet", 63.20, :pix, true ],
  [ "2026-04-26", "Ração / alimentos pets", "Areia higiênica pet", 48.90, :debito, false ],
  [ "2026-04-30", "Ração / alimentos pets", "Petiscos", 36.80, :pix, false ],

  [ "2026-04-05", "Cursos", "Curso online", 97.00, :pix, true ],
  [ "2026-04-12", "Cursos", "Aula avulsa", 65.00, :debito, true ],
  [ "2026-04-19", "Cursos", "Plataforma de estudos", 49.90, :pix, false ],
  [ "2026-04-26", "Cursos", "Material complementar curso", 72.50, :debito, false ]
]

april_expenses.each do |date_text, category_name, description, amount, payment_method, paid|
  date = Date.parse(date_text)
  category = Category.find_by!(name: category_name)

  expense = Expense.find_or_initialize_by(
    description: description,
    date: date,
    category: category
  )

  expense.assign_attributes(
    amount: amount,
    balance_month: date.beginning_of_month,
    payment_method: payment_method,
    paid: paid,
    installments_count: 1,
    current_installment: 1
  )

  expense.save!
end

puts "40 despesas de abril de 2026 criadas/atualizadas com sucesso!"

financial_goals = [
  [ "Reserva de emergência", 30000.00, 12500.00, "2026-12-31", :in_progress, :high, "Meta para cobrir pelo menos seis meses de despesas essenciais." ],
  [ "Entrada do apartamento", 85000.00, 18000.00, "2028-06-30", :planned, :high, "Compor recursos próprios e avaliar limites apenas como apoio de negociação." ],
  [ "Viagem para o Chile", 12000.00, 4200.00, "2027-07-15", :in_progress, :medium, "Passagens, hospedagem, passeios e reserva para câmbio." ],
  [ "Troca do carro", 45000.00, 9000.00, "2027-11-30", :planned, :medium, "Valor estimado para entrada e documentação." ],
  [ "Curso de especialização", 9000.00, 3500.00, "2026-09-10", :in_progress, :high, "Mensalidades, material e taxa de certificação." ],
  [ "Notebook novo", 7500.00, 1800.00, "2026-08-20", :planned, :medium, "Priorizar equipamento para trabalho e estudos." ],
  [ "Reforma da cozinha", 18000.00, 2500.00, "2027-03-31", :paused, :medium, "Aguardar novos orçamentos antes de retomar." ],
  [ "Quitação de financiamento", 25000.00, 6000.00, "2027-12-20", :planned, :high, "Avaliar antecipações quando houver sobra no mês." ],
  [ "Fundo para impostos anuais", 8000.00, 2100.00, "2027-01-15", :in_progress, :medium, "IPVA, IPTU e taxas de início de ano." ],
  [ "Seguro e manutenção do carro", 6500.00, 900.00, "2026-10-05", :planned, :medium, "Reserva para seguro, revisão e pneus." ],
  [ "Reserva médica", 10000.00, 4800.00, "2026-12-15", :in_progress, :high, "Consultas, exames e eventuais procedimentos." ],
  [ "Viagem em família", 20000.00, 5200.00, "2027-01-10", :planned, :medium, "Planejamento de férias com hospedagem e deslocamentos." ],
  [ "Mobília da sala", 6000.00, 750.00, "2026-11-30", :planned, :low, "Sofá, rack e iluminação." ],
  [ "Celular novo", 4200.00, 3200.00, "2026-06-30", :in_progress, :low, "Troca planejada caso o aparelho atual não compense manutenção." ],
  [ "Plano de investimentos", 50000.00, 11000.00, "2028-12-31", :planned, :high, "Meta inicial de carteira de longo prazo." ],
  [ "Aniversário especial", 3500.00, 2800.00, "2026-05-25", :in_progress, :low, "Festa pequena, presentes e jantar." ],
  [ "Reserva para pets", 4000.00, 900.00, "2026-09-30", :planned, :medium, "Vacinas, consultas e emergências veterinárias." ],
  [ "Home office", 5500.00, 2200.00, "2026-07-31", :in_progress, :medium, "Cadeira, mesa, monitor e acessórios." ],
  [ "Intercâmbio futuro", 70000.00, 8500.00, "2029-02-28", :planned, :high, "Projeto de longo prazo para curso no exterior." ],
  [ "Objetivo concluído de teste", 2500.00, 2500.00, "2026-03-31", :completed, :low, "Registro de exemplo para validar filtros e KPIs futuros." ]
]

financial_goals.each do |description, target_amount, current_amount, due_date, status, priority, notes|
  financial_goal = FinancialGoal.find_or_initialize_by(description: description)

  financial_goal.assign_attributes(
    target_amount: target_amount,
    current_amount: current_amount,
    due_date: Date.parse(due_date),
    status: status,
    priority: priority,
    notes: notes
  )

  financial_goal.save!
end

goal_resources = {
  "Reserva de emergência" => [
    [ :own_resource, "Conta investimento", 9000.00 ],
    [ :own_resource, "Conta corrente", 3500.00 ]
  ],
  "Entrada do apartamento" => [
    [ :own_resource, "Poupanca dedicada", 14000.00 ],
    [ :external_resource, "FGTS estimado", 4000.00 ],
    [ :credit_limit, "Credito aprovado estimado", 12000.00 ]
  ],
  "Viagem para o Chile" => [
    [ :own_resource, "Reserva viagem", 3000.00 ],
    [ :external_resource, "Milhas convertidas", 1200.00 ],
    [ :credit_limit, "Limite cartao viagem", 5000.00 ]
  ],
  "Curso de especialização" => [
    [ :own_resource, "Conta educacao", 3500.00 ]
  ],
  "Notebook novo" => [
    [ :own_resource, "Reserva tecnologia", 1800.00 ],
    [ :credit_limit, "Limite cartao principal", 2500.00 ]
  ],
  "Home office" => [
    [ :own_resource, "Reserva equipamentos", 2200.00 ],
    [ :credit_limit, "Limite cartao compras", 1800.00 ]
  ],
  "Objetivo concluído de teste" => [
    [ :own_resource, "Valor acumulado", 2500.00 ]
  ]
}

goal_resources.each do |goal_description, resources|
  financial_goal = FinancialGoal.find_by!(description: goal_description)

  resources.each do |resource_type, resource_description, amount|
    resource = financial_goal.financial_goal_resources.find_or_initialize_by(description: resource_description)
    resource.assign_attributes(
      resource_type: resource_type,
      amount: amount,
      include_in_total: true
    )
    resource.save!
  end
end

puts "20 objetivos financeiros criados/atualizados com sucesso!"
