require "net/http"
require "json"
require "nokogiri"

module Nutrition
  class TabNutClient
    BASE_URL = "https://tabelanutricional.com.br".freeze
    class Unavailable < StandardError; end

    FIELDS = {
      "Valor energético" => "calories", "Carboidratos" => "carbohydrates",
      "Proteínas" => "proteins", "Gorduras totais" => "fats",
      "Fibras alimentares" => "fiber", "Sódio" => "sodium",
      "Cálcio" => "calcium", "Ferro" => "iron", "Potássio" => "potassium",
      "Magnésio" => "magnesium", "Fósforo" => "phosphorus", "Zinco" => "zinc",
      "Colesterol" => "cholesterol", "Vitamina C" => "vitamin_c"
    }.freeze

    def search(name)
      Rails.cache.fetch(["tabnut-search-v1", name], expires_in: 15.minutes) do
        data = JSON.parse(get("/alimentos/buscar", q: name, page: 1))
        data.fetch("items").first(10).map do |item|
          path = URI.parse(item.fetch("url")).path
          { id: path.delete_prefix("/alimentos/"), source: "tabnut", name: item.fetch("name"),
            data_source: item["data_source"], serving: item["serving"], nutrients: {}, needs_details: true }
        end
      end
    rescue JSON::ParserError, KeyError, URI::InvalidURIError
      raise Unavailable, "TabNut retornou uma busca inválida."
    end

    def find(id)
      raise ArgumentError, "Identificador TabNut inválido." unless id.to_s.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/) && id.length <= 500

      Rails.cache.fetch(["tabnut-food-v2", id], expires_in: 24.hours) { extract(id) }
    end

    private

    def get(path, query = {})
      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(query) if query.any?
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 8) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Accept"] = "application/json, text/html"
        http.request(request)
      end
      raise Unavailable, "TabNut indisponível. Tente novamente." unless response.is_a?(Net::HTTPSuccess)

      response.body
    rescue Timeout::Error, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError, Net::HTTPBadResponse
      raise Unavailable, "Não foi possível consultar TabNut. Tente novamente."
    end

    def extract(id)
      doc = Nokogiri::HTML(get("/alimentos/#{id}"))
      graph = doc.css('script[type="application/ld+json"]').flat_map { |node| JSON.parse(node.text).fetch("@graph", []) }
      food = graph.find { |node| node["@type"] == "Food" } or raise KeyError
      serving = food.fetch("nutrition").fetch("servingSize").match(/\A([\d.,]+)\s*(g|ml)\z/i)
      raise ArgumentError, "Porção TabNut não suportada." unless serving
      unit = serving[2].downcase

      amount = BigDecimal(serving[1].tr(",", "."))
      raise ArgumentError, "Porção TabNut inválida." unless amount.finite? && amount.positive?

      nutrients = doc.css("tbody tr").filter_map do |row|
        label = row.at_css("td:first-child")&.text&.squish
        cell = row.at_css("[data-nutrient-cell]")
        next unless label && cell

        value = cell["data-base-value"].presence
        number = value && BigDecimal(value)
        raise ArgumentError, "Nutriente TabNut inválido." if number && (!number.finite? || number.negative?)
        { "key" => FIELDS[label], "name" => label, "value" => number&.to_s("F"), "unit" => cell["data-unit"] }
      end
      raise Unavailable, "Tabela de nutrientes TabNut indisponível ou alterada." if nutrients.empty?

      normalized = (NutritionMealItem::NUTRIENTS + [:fiber, :sodium]).index_with { nil }.stringify_keys
      nutrients.each do |nutrient|
        key = nutrient["key"]
        next unless key && nutrient["value"]
        expected = key == "calories" ? "kcal" : (%w[carbohydrates proteins fats fiber].include?(key) ? "g" : "mg")
        next unless nutrient["unit"] == expected

        normalized[key] = (BigDecimal(nutrient["value"]) * 100 / amount).to_s("F")
      end
      snapshot = { "version" => 1, "name" => food.fetch("name"), "source_url" => "#{BASE_URL}/alimentos/#{id}",
        "data_source" => food.fetch("additionalProperty", []).find { |p| p["name"] == "Fonte dos dados" }&.dig("value"),
        "captured_at" => Time.current.iso8601, "serving" => { "amount" => amount.to_s("F"), "unit" => unit },
        "nutrients" => nutrients, "per_100#{unit}" => normalized }
      { id: id, source: "tabnut", name: snapshot["name"], nutrients: normalized.symbolize_keys,
        quantity_unit: unit, food_snapshot: snapshot, data_source: snapshot["data_source"], serving: "#{serving[1]} #{unit}" }
    rescue JSON::ParserError, KeyError
      raise Unavailable, "Estrutura TabNut indisponível ou alterada."
    end
  end
end
