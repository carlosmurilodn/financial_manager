# db/seeds.rb

categories = [
  # Moradia
  ["home", "Aluguel"],
  ["lightbulb", "Conta de luz"],
  ["water_drop", "Água e esgoto"],
  ["local_fire_department", "Gás"],

  # Transporte
  ["local_gas_station", "Combustível"],
  ["local_taxi", "Aplicativos de viagem"],
  ["car_repair", "Manutenção do carro"],

  # Alimentação
  ["shopping_cart", "Supermercado"],
  ["fastfood", "Lanches / fast food"],
  ["local_cafe", "Cafés e bebidas"],
  ["restaurant", "Restaurantes"],

  # Saúde e bem-estar
  ["medication", "Medicamentos"],
  ["medical_services", "Consultas médicas"],
  ["health_and_safety", "Plano de Saúde"],
  ["fitness_center", "Academia / esportes"],
  ["self_improvement", "Terapias / bem-estar"],

  # Educação / conhecimento
  ["menu_book", "Cursos"],
  ["edit_note", "Material escolar / livros"],
  ["school", "Assinaturas educativas"],

  # Lazer e entretenimento
  ["movie", "Cinema / streaming"],
  ["sports_esports", "Jogos"],
  ["music_note", "Música / shows"],
  ["flight", "Viagens"],
  ["palette", "Hobbies"],

  # Financeiro / investimentos
  ["account_balance", "Banco / tarifas"],
  ["trending_up", "Investimentos"],
  ["request_quote", "Empréstimos / financiamentos"],

  # Compras e vestuário
  ["checkroom", "Roupas"],
  ["steps", "Calçados"],
  ["styler", "Acessórios"],
  ["spa", "Beleza / cuidados pessoais"],
  ["face", "Cosméticos"],

  # Tecnologia / comunicação
  ["smartphone", "Celular / planos"],
  ["wifi", "Internet"],
  ["devices", "Eletrônicos"],
  ["deployed_code", "Assinaturas de software"],

  # Pets
  ["pets", "Ração / alimentos pets"],
  ["pets", "Veterinário / saúde pets"],
  ["pets", "Acessórios pets"],

  # Presentes / doações
  ["redeem", "Presentes"],
  ["volunteer_activism", "Doações / caridade"],

  # Outros
  ["receipt_long", "Impostos / taxas"],
  ["shield", "Seguro"],
  ["celebration", "Eventos / festas"],
  ["subscriptions", "Assinaturas / serviços"],
  ["cleaning_services", "Cuidados domésticos"],
  ["directions_bike", "Fitness / esportes ao ar livre"],
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
  ["2026-04-01", "Supermercado", "Compra semanal no mercado", 286.74, :debito, true],
  ["2026-04-08", "Supermercado", "Reposição de alimentos", 198.32, :pix, true],
  ["2026-04-15", "Supermercado", "Hortifruti e limpeza", 142.90, :debito, true],
  ["2026-04-25", "Supermercado", "Feira do fim de semana", 96.45, :dinheiro, false],

  ["2026-04-02", "Restaurantes", "Almoço em restaurante", 64.90, :pix, true],
  ["2026-04-10", "Restaurantes", "Jantar fora", 132.80, :debito, true],
  ["2026-04-18", "Restaurantes", "Delivery de comida", 78.50, :pix, false],
  ["2026-04-27", "Restaurantes", "Café da tarde", 36.20, :dinheiro, false],

  ["2026-04-03", "Combustível", "Abastecimento do carro", 220.00, :debito, true],
  ["2026-04-11", "Combustível", "Etanol posto centro", 160.00, :pix, true],
  ["2026-04-19", "Combustível", "Completar tanque", 245.30, :debito, false],
  ["2026-04-29", "Combustível", "Abastecimento viagem curta", 180.00, :pix, false],

  ["2026-04-04", "Conta de luz", "Conta de energia abril", 238.67, :pix, true],
  ["2026-04-09", "Conta de luz", "Ajuste bandeira tarifária", 42.15, :pix, true],
  ["2026-04-18", "Conta de luz", "Consumo adicional energia", 58.30, :pix, false],
  ["2026-04-27", "Conta de luz", "Complemento energia abril", 36.70, :pix, false],

  ["2026-04-06", "Internet", "Internet residencial", 119.90, :pix, true],
  ["2026-04-12", "Internet", "Upgrade temporário internet", 29.90, :pix, true],
  ["2026-04-20", "Internet", "Roteador e cabos", 86.40, :debito, false],
  ["2026-04-30", "Internet", "Serviço técnico internet", 75.00, :pix, false],

  ["2026-04-09", "Medicamentos", "Farmácia e vitaminas", 88.35, :debito, true],
  ["2026-04-13", "Medicamentos", "Medicamento de uso contínuo", 126.70, :pix, true],
  ["2026-04-21", "Medicamentos", "Itens de farmácia", 54.20, :debito, false],
  ["2026-04-28", "Medicamentos", "Reposição remédios abril", 97.45, :pix, false],

  ["2026-04-12", "Roupas", "Camisetas básicas", 149.90, :debito, true],
  ["2026-04-14", "Roupas", "Calça casual", 189.90, :debito, true],
  ["2026-04-20", "Roupas", "Meias e roupas íntimas", 72.50, :dinheiro, false],
  ["2026-04-23", "Roupas", "Blusa de frio", 159.90, :pix, false],

  ["2026-04-02", "Lanches / fast food", "Lanche rápido", 42.90, :pix, true],
  ["2026-04-16", "Lanches / fast food", "Cafeteria", 28.50, :debito, true],
  ["2026-04-22", "Lanches / fast food", "Pedido fast food", 57.80, :pix, false],
  ["2026-04-24", "Lanches / fast food", "Combo lanche noite", 64.30, :debito, false],

  ["2026-04-03", "Ração / alimentos pets", "Ração mensal", 189.90, :debito, true],
  ["2026-04-17", "Ração / alimentos pets", "Sachês para pet", 63.20, :pix, true],
  ["2026-04-26", "Ração / alimentos pets", "Areia higiênica pet", 48.90, :debito, false],
  ["2026-04-30", "Ração / alimentos pets", "Petiscos", 36.80, :pix, false],

  ["2026-04-05", "Cursos", "Curso online", 97.00, :pix, true],
  ["2026-04-12", "Cursos", "Aula avulsa", 65.00, :debito, true],
  ["2026-04-19", "Cursos", "Plataforma de estudos", 49.90, :pix, false],
  ["2026-04-26", "Cursos", "Material complementar curso", 72.50, :debito, false]
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
