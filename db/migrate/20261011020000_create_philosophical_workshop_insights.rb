class CreatePhilosophicalWorkshopInsights < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_insights do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.text :origin
      t.text :notes
      t.string :status, default: "captured", null: false
      t.timestamps
    end

    add_check_constraint :philosophical_workshop_insights, "status IN ('captured', 'reflecting', 'developed', 'archived')", name: "philosophical_workshop_insights_valid_status"
  end
end
