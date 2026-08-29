class Card < ApplicationRecord
  COLOR_PALETTE = Category::COLOR_PALETTE
  LimitUsage = Data.define(:used, :available, :percentage) do
    def exceeded?
      percentage.present? && percentage > 100
    end

    def used_bar_percentage
      percentage.to_f.clamp(0, 100)
    end

    def available_bar_percentage
      100 - used_bar_percentage
    end
  end

  belongs_to :user

  has_many :expenses, dependent: :nullify
  has_one_attached :icon

  before_validation :normalize_number
  before_validation :normalize_currency_values

  validates :name, presence: true
  validates :number,
            allow_blank: true,
            format: { with: /\A\d{16}\z/, message: "deve conter exatamente 16 numeros" }

  validates :total_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :due_day, :closing_day, inclusion: { in: 1..31 }, allow_nil: true
  validates :color, inclusion: { in: COLOR_PALETTE.values }, allow_blank: true

  def remaining_limit
    total_limit.to_f - unpaid_total
  end

  def limit_usage_from(reference_date)
    start_date = reference_date.to_date.next_month.beginning_of_month
    used = Expense.effective_sum(expenses.where(paid: false, balance_month: start_date..))
    limit = (total_limit || 0).to_d
    available = limit - used
    percentage = (used / limit) * 100 if limit.positive?

    LimitUsage.new(used: used, available: available, percentage: percentage)
  end

  def display_name
    base = if number.present?
      "#{name} (**** **** **** #{number[-4..-1]})"
    else
      name
    end

    "#{base} - Restante: #{ActionController::Base.helpers.number_to_currency(remaining_limit, unit: 'R$ ', separator: ',', delimiter: '.')}"
  end

  def display_color
    color.presence || COLOR_PALETTE.values.first
  end

  def color_name
    Category.color_name_for(display_color)
  end

  def billing_due_date_for(purchase_date)
    return if purchase_date.blank? || due_day.blank? || closing_day.blank?

    closing_reference = purchase_date.day <= closing_day ? purchase_date : purchase_date.next_month
    closing_date = date_with_day(closing_reference.year, closing_reference.month, closing_day)
    due_reference = due_day > closing_day ? closing_date : closing_date.next_month

    date_with_day(due_reference.year, due_reference.month, due_day)
  end

  private

  def unpaid_total
    Expense.effective_sum(expenses.where(paid: false))
  end

  def normalize_number
    self.number = number.gsub(/\D/, "") if number.present?
  end

  def normalize_currency_values
    self.total_limit = parse_brazilian_currency(total_limit_before_type_cast)
  end

  def parse_brazilian_currency(value)
    return value if value.is_a?(Numeric)
    return nil if value.blank?

    value.to_s
         .gsub(/[^\d,]/, "")
         .delete(".")
         .gsub(",", ".")
         .to_f
  end

  def date_with_day(year, month, day)
    end_of_month = Date.new(year, month, -1).day

    Date.new(year, month, [ day.to_i, end_of_month ].min)
  end
end
