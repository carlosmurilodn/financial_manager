module BrazilianParameterParsing
  private

  def parse_brazilian_amount(value, blank: nil)
    return blank if value.blank?

    cleaned = value.to_s.gsub(/[^\d,\.]/, "")
    return blank if cleaned.blank?

    normalized = if cleaned.include?(",")
      cleaned.delete(".").tr(",", ".")
    else
      cleaned.delete(".")
    end

    BigDecimal(normalized)
  rescue ArgumentError
    blank
  end

  def parse_brazilian_date(value)
    Date.strptime(value, "%d/%m/%Y")
  rescue ArgumentError, TypeError
    nil
  end
end
