class ChangeCardIdNullOnExpenses < ActiveRecord::Migration[8.0]
  def change
    change_column_null :expenses, :card_id, true
  end
end

