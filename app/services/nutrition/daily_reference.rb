module Nutrition
  class DailyReference
    # Anvisa IN 75/2020, Anexo II. Units match MealItemDetails::GROUPS.
    SOURCE_URL = "https://bvs.saude.gov.br/bvs/saudelegis/anvisa/2020/IN%2075_2020_.pdf".freeze
    VALUES = {
      calories: 2000, carbohydrates: 300, proteins: 50, fats: 65,
      fiber: 25, cholesterol: 300, sodium: 2000,
      calcium: 1000, magnesium: 420, manganese: 3, phosphorus: 700,
      iron: 14, potassium: 3500, copper: BigDecimal("0.9"), zinc: 11,
      retinol_activity: 800, thiamine: BigDecimal("1.2"),
      riboflavin: BigDecimal("1.2"), pyridoxine: BigDecimal("1.3"), vitamin_c: 100
    }.freeze

    def self.percentage(field, amount)
      reference = VALUES[field]
      amount.to_d * 100 / reference if reference && !amount.nil?
    end
  end
end
