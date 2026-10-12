module TacoFoodsHelper
  def taco_nutrient_value(value)
    return "—" if value.nil?

    number_with_precision(value, precision: 2, strip_insignificant_zeros: true, separator: ",", delimiter: ".")
  end
end
