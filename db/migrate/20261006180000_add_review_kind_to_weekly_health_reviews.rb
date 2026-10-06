class AddReviewKindToWeeklyHealthReviews < ActiveRecord::Migration[8.0]
  def up
    add_column :weekly_health_reviews, :review_kind, :string, null: false, default: "weekly"

    remove_index :weekly_health_reviews, [ :user_id, :week_start ]
    add_index :weekly_health_reviews, [ :user_id, :review_kind, :week_start ],
              unique: true,
              name: "index_weekly_health_reviews_on_user_kind_and_start"

    remove_check_constraint :weekly_health_reviews, name: "weekly_health_reviews_start_on_monday"
  end

  def down
    add_check_constraint :weekly_health_reviews,
                         "EXTRACT(ISODOW FROM week_start) = 1",
                         name: "weekly_health_reviews_start_on_monday"

    remove_index :weekly_health_reviews, name: "index_weekly_health_reviews_on_user_kind_and_start"
    add_index :weekly_health_reviews, [ :user_id, :week_start ], unique: true
    remove_column :weekly_health_reviews, :review_kind
  end
end
