# db/seeds.rb

categories = [
  # Moradia
  ["🏡", "Aluguel"],
  ["💡", "Conta de luz"],
  ["🚰", "Conta de água e esgoto"],
  ["🔥", "Gás"],

  # Transporte
  ["🚗", "Combustível"],
  ["🚕", "Aplicativos de viagem"],
  ["🛠️", "Manutenção do carro"],

  # Alimentação
  ["🥗", "Supermercado"],
  ["🍔", "Lanches / fast food"],
  ["☕", "Cafés e bebidas"],
  ["🥘", "Restaurantes"],

  # Saúde e bem-estar
  ["💊", "Medicamentos"],
  ["🩺", "Consultas médicas"],
  ["🏥", "Plano de Saúde"],
  ["🏋️", "Academia / esportes"],
  ["🧘", "Terapias / bem-estar"],

  # Educação / conhecimento
  ["📚", "Cursos"],
  ["📝", "Material escolar / livros"],
  ["💻", "Assinaturas educativas"],

  # Lazer e entretenimento
  ["🎬", "Cinema / streaming"],
  ["🎮", "Jogos"],
  ["🎵", "Música / shows"],
  ["✈️", "Viagens"],
  ["🎨", "Hobbies"],

  # Financeiro / investimentos
  ["🏦", "Banco / tarifas"],
  ["📈", "Investimentos"],
  ["💰", "Empréstimos / financiamentos"],

  # Compras e vestuário
  ["👕", "Roupas"],
  ["👟", "Calçados"],
  ["👜", "Acessórios"],
  ["💅", "Beleza / cuidados pessoais"],
  ["💄", "Cosméticos"],

  # Tecnologia / comunicação
  ["📱", "Celular / planos"],
  ["💻", "Internet"],
  ["🖥️", "Eletrônicos"],
  ["🖱️", "Assinaturas de software"],

  # Pets
  ["🍖", "Ração / alimentos pets"],
  ["🐾", "Veterinário / saúde pets"],
  ["🦴", "Acessórios pets"],

  # Presentes / doações
  ["🎁", "Presentes"],
  ["🙏", "Doações / caridade"],

  # Outros
  ["🧾", "Impostos / taxas"],
  ["🛡️", "Seguro"],
  ["🎉", "Eventos / festas"],
  ["📦", "Assinaturas / serviços"],
  ["🧹", "Cuidados domésticos"],
  ["🚴", "Fitness / esportes ao ar livre"],
]

categories.each do |emoji, name|
  Category.find_or_create_by!(name: name) do |category|
    category.emoji = emoji
  end
end

puts "Categorias seed criadas com sucesso!"
