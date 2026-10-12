class RemoveLegacyDailyCalorieEntries < ActiveRecord::Migration[8.0]
  def up
    drop_table :daily_calorie_entries
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Registros de teste e snapshots antigos de calorias foram descartados."
  end
end
