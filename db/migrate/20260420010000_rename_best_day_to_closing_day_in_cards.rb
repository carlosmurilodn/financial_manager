class RenameBestDayToClosingDayInCards < ActiveRecord::Migration[8.0]
  def change
    rename_column :cards, :best_day, :closing_day
  end
end
