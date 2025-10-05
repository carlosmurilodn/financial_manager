class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.string :name
      t.string :number

      t.timestamps
    end
  end
end
