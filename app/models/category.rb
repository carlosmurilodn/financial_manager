class Category < ApplicationRecord
  belongs_to :user

  has_many :expenses, dependent: :nullify
  has_many :incomes, dependent: :nullify
  has_many :financial_goals, dependent: :nullify

  MATERIAL_ICONS = {
    "acessorios" => "styler",
    "acessorios pets" => "pets",
    "academia esportes" => "fitness_center",
    "agua e esgoto" => "water_drop",
    "aluguel" => "home",
    "aplicativos de viagem" => "local_taxi",
    "assinaturas de software" => "deployed_code",
    "assinaturas educativas" => "school",
    "assinaturas servicos" => "subscriptions",
    "banco tarifas" => "account_balance",
    "beleza cuidados pessoais" => "spa",
    "cafes e bebidas" => "local_cafe",
    "calcados" => "steps",
    "celular planos" => "smartphone",
    "cinema streaming" => "movie",
    "combustivel" => "local_gas_station",
    "consultas medicas" => "medical_services",
    "conta de luz" => "lightbulb",
    "cosmeticos" => "face",
    "cuidados domesticos" => "cleaning_services",
    "cursos" => "menu_book",
    "doacoes caridade" => "volunteer_activism",
    "eletronicos" => "devices",
    "emprestimos financiamentos" => "request_quote",
    "eventos festas" => "celebration",
    "fitness esportes ao ar livre" => "directions_bike",
    "gas" => "local_fire_department",
    "hobbies" => "palette",
    "impostos taxas" => "receipt_long",
    "internet" => "wifi",
    "investimentos" => "trending_up",
    "jogos" => "sports_esports",
    "lanches fast food" => "fastfood",
    "manutencao do carro" => "car_repair",
    "material escolar livros" => "edit_note",
    "medicamentos" => "medication",
    "musica shows" => "music_note",
    "plano de saude" => "health_and_safety",
    "presentes" => "redeem",
    "racao alimentos pets" => "pets",
    "restaurantes" => "restaurant",
    "roupas" => "checkroom",
    "seguro" => "shield",
    "supermercado" => "shopping_cart",
    "terapias bem estar" => "self_improvement",
    "veterinario saude pets" => "pets",
    "viagens" => "flight"
  }.freeze

  validates :name, presence: true, uniqueness: true

  def display_name
    clean_name
  end

  def sort_name
    clean_name.downcase
  end

  def clean_name
    name.to_s.gsub(/\A[^\p{Alnum}]+/u, "").strip
  end

  def material_icon
    icon.presence || MATERIAL_ICONS.fetch(normalized_name, "category")
  end

  def normalized_name
    clean_name
      .unicode_normalize(:nfkd)
      .encode("ASCII", replace: "", undef: :replace)
      .downcase
      .gsub(/[^a-z0-9]+/, " ")
      .squeeze(" ")
      .strip
  end
end
