class RenameCategoryEmojiToIcon < ActiveRecord::Migration[8.0]
  ICONS_BY_CATEGORY = {
    "acessorios" => "styler",
    "acessorios pets" => "pets",
    "academia esportes" => "fitness_center",
    "agua e esgoto" => "water_drop",
    "conta de agua e esgoto" => "water_drop",
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
    "teste" => "category",
    "teste gargalo" => "category",
    "veterinario saude pets" => "pets",
    "viagens" => "flight"
  }.freeze

  class CategoryRecord < ActiveRecord::Base
    self.table_name = "categories"
  end

  def up
    rename_column :categories, :emoji, :icon
    CategoryRecord.reset_column_information

    CategoryRecord.find_each do |category|
      clean_name = clean_category_name(category.name)
      category.update_columns(
        name: clean_name,
        icon: ICONS_BY_CATEGORY.fetch(normalized_name(clean_name), "category")
      )
    end
  end

  def down
    rename_column :categories, :icon, :emoji
  end

  private

  def clean_category_name(name)
    name.to_s.gsub(/\A[^\p{Alnum}]+/u, "").strip
  end

  def normalized_name(name)
    name
      .unicode_normalize(:nfkd)
      .encode("ASCII", replace: "", undef: :replace)
      .downcase
      .gsub(/[^a-z0-9]+/, " ")
      .squeeze(" ")
      .strip
  end
end
