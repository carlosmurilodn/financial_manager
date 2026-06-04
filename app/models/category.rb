class Category < ApplicationRecord
  has_many :expenses, dependent: :nullify
  has_many :incomes, dependent: :nullify
  has_many :financial_goals, dependent: :nullify

  COLOR_PALETTE = {
    "Amarelo" => "#F0C510",
    "Azul" => "#2563EB",
    "Bege" => "#AB7743",
    "Ciano" => "#0891B2",
    "Cinza" => "#6B7280",
    #"Índigo" => "#4F46E5",
    "Laranja" => "#EA580C",
    #"Magenta" => "#C026D3",
    "Rosa" => "#DB2777",
    "Roxo" => "#7C3AED",
    "Turquesa" => "#0F766E",
    "Verde" => "#16A34A",
    "Vermelho" => "#DC2626"
  }.freeze

  def self.color_name_for(color)
    COLOR_PALETTE.key(color.to_s.upcase) || "Personalizada"
  end

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
  validates :color, inclusion: { in: COLOR_PALETTE.values }, allow_blank: true

  def display_name
    clean_name
  end

  def sort_name
    normalized_name
  end

  def clean_name
    name.to_s.gsub(/\A[^\p{Alnum}]+/u, "").strip
  end

  def material_icon
    icon.presence || MATERIAL_ICONS.fetch(normalized_name, "category")
  end

  # Retorna a cor visual da categoria para cards, ícones e badges.
  def display_color
    color.presence || COLOR_PALETTE.values.first
  end

  def color_name
    self.class.color_name_for(display_color)
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
