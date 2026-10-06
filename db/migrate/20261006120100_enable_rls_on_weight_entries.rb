class EnableRlsOnWeightEntries < ActiveRecord::Migration[8.0]
  def up
    execute "ALTER TABLE weight_entries ENABLE ROW LEVEL SECURITY"
  end

  def down
    execute "ALTER TABLE weight_entries DISABLE ROW LEVEL SECURITY"
  end
end
