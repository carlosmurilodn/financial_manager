# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_07_200000) do
  create_schema "auth", if_not_exists: true
  create_schema "extensions", if_not_exists: true
  create_schema "graphql", if_not_exists: true
  create_schema "graphql_public", if_not_exists: true
  create_schema "pgbouncer", if_not_exists: true
  create_schema "realtime", if_not_exists: true
  create_schema "storage", if_not_exists: true
  create_schema "vault", if_not_exists: true

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_limit"
    t.integer "due_day"
    t.integer "closing_day"
    t.bigint "user_id"
    t.string "color"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
    t.bigint "user_id"
    t.string "color", default: "#2563EB", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "daily_calorie_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "occurred_on", null: false
    t.decimal "consumed_calories", precision: 12, scale: 2
    t.decimal "reference_weight_kg", precision: 5, scale: 2
    t.date "reference_weight_date"
    t.decimal "height_cm", precision: 5, scale: 2
    t.date "birth_date"
    t.integer "age"
    t.string "formula_sex"
    t.boolean "trained", default: false, null: false
    t.boolean "walked", default: false, null: false
    t.decimal "activity_factor", precision: 4, scale: 3, default: "1.2", null: false
    t.decimal "bmr", precision: 14, scale: 4
    t.decimal "tdee", precision: 18, scale: 7
    t.decimal "calorie_deficit", precision: 18, scale: 7
    t.string "calculation_status", default: "missing_consumption", null: false
    t.datetime "calculated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "occurred_on"], name: "index_daily_calorie_entries_on_user_id_and_occurred_on", unique: true
    t.index ["user_id"], name: "index_daily_calorie_entries_on_user_id"
    t.check_constraint "(bmr IS NULL OR bmr > 0::numeric) AND (tdee IS NULL OR tdee > 0::numeric)", name: "daily_calorie_entries_positive_expenditure"
    t.check_constraint "activity_factor = ANY (ARRAY[1.2, 1.375, 1.55, 1.725])", name: "daily_calorie_entries_valid_factor"
    t.check_constraint "calculation_status::text = ANY (ARRAY['calculated'::character varying, 'missing_consumption'::character varying, 'missing_profile'::character varying, 'missing_weight'::character varying, 'invalid_profile'::character varying]::text[])", name: "daily_calorie_entries_valid_status"
    t.check_constraint "consumed_calories IS NULL OR consumed_calories >= 0::numeric", name: "daily_calorie_entries_nonnegative_consumption"
    t.check_constraint "reference_weight_date IS NULL OR reference_weight_date <= occurred_on", name: "daily_calorie_entries_reference_not_later"
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount"
    t.date "date"
    t.date "balance_month"
    t.string "description"
    t.bigint "category_id", null: false
    t.bigint "card_id"
    t.integer "payment_method"
    t.boolean "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "installments_count", default: 1, null: false
    t.integer "current_installment", default: 1, null: false
    t.bigint "installment_group_id"
    t.datetime "paid_at"
    t.bigint "user_id"
    t.index ["card_id"], name: "index_expenses_on_card_id"
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["installment_group_id"], name: "index_expenses_on_installment_group_id"
    t.index ["paid_at"], name: "index_expenses_on_paid_at"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "financial_goal_resources", force: :cascade do |t|
    t.integer "financial_goal_id", null: false
    t.integer "resource_type", default: 0, null: false
    t.string "description", null: false
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "include_in_total", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.index ["financial_goal_id"], name: "index_financial_goal_resources_on_financial_goal_id"
    t.index ["resource_type"], name: "index_financial_goal_resources_on_resource_type"
    t.index ["source_type", "source_id"], name: "index_financial_goal_resources_on_source_type_and_source_id"
  end

  create_table "financial_goals", force: :cascade do |t|
    t.string "description", null: false
    t.decimal "target_amount", precision: 12, scale: 2, null: false
    t.date "due_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "current_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "category_id"
    t.bigint "user_id"
    t.string "color"
    t.index ["category_id"], name: "index_financial_goals_on_category_id"
    t.index ["due_date"], name: "index_financial_goals_on_due_date"
    t.index ["priority"], name: "index_financial_goals_on_priority"
    t.index ["status"], name: "index_financial_goals_on_status"
    t.index ["user_id"], name: "index_financial_goals_on_user_id"
  end

  create_table "health_journal_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "entry_date", null: false
    t.integer "mood"
    t.integer "energy"
    t.integer "tension"
    t.text "main_thought"
    t.text "meaningful_event"
    t.text "emotions"
    t.text "positive_moment"
    t.text "needs_notes"
    t.text "reflection_answer"
    t.text "notes"
    t.string "reflection_prompt_key"
    t.jsonb "needs", default: [], null: false
    t.jsonb "legacy_content", default: {}, null: false
    t.bigint "source_review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_review_id"], name: "index_health_journal_entries_on_source_review_id", unique: true
    t.index ["user_id", "entry_date"], name: "index_health_journal_entries_on_user_id_and_entry_date", unique: true
    t.index ["user_id"], name: "index_health_journal_entries_on_user_id"
    t.check_constraint "energy IS NULL OR energy >= 1 AND energy <= 5", name: "journal_energy_range"
    t.check_constraint "mood IS NULL OR mood >= 1 AND mood <= 5", name: "journal_mood_range"
    t.check_constraint "tension IS NULL OR tension >= 1 AND tension <= 5", name: "journal_tension_range"
  end

  create_table "health_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "height_cm", precision: 5, scale: 2, null: false
    t.date "birth_date", null: false
    t.string "formula_sex", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_health_profiles_on_user_id", unique: true
    t.check_constraint "formula_sex::text = ANY (ARRAY['male'::character varying, 'female'::character varying]::text[])", name: "health_profiles_valid_formula_sex"
    t.check_constraint "height_cm > 0::numeric AND height_cm < 1000::numeric", name: "health_profiles_valid_height"
  end

  create_table "health_weekly_reflections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "week_start", null: false
    t.integer "routine_satisfaction"
    t.text "recurring_patterns"
    t.text "what_helped"
    t.text "what_drained"
    t.text "thought_patterns"
    t.text "avoidance_and_control"
    t.text "self_discovery"
    t.text "weekly_needs_notes"
    t.text "control_reflection"
    t.text "proud_of"
    t.text "weekly_learning"
    t.text "keep_doing"
    t.text "change_next_week"
    t.text "next_small_step"
    t.jsonb "weekly_needs", default: [], null: false
    t.jsonb "legacy_content", default: {}, null: false
    t.bigint "source_review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_review_id"], name: "index_health_weekly_reflections_on_source_review_id", unique: true
    t.index ["user_id", "week_start"], name: "index_health_weekly_reflections_on_user_id_and_week_start", unique: true
    t.index ["user_id"], name: "index_health_weekly_reflections_on_user_id"
    t.check_constraint "EXTRACT(isodow FROM week_start) = 1::numeric", name: "reflection_monday"
    t.check_constraint "routine_satisfaction IS NULL OR routine_satisfaction >= 1 AND routine_satisfaction <= 5", name: "reflection_routine_range"
  end

  create_table "health_weight_goals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "target_weight", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "goal_type", default: "intermediate", null: false
    t.integer "position", default: 0, null: false
    t.index ["user_id", "goal_type"], name: "index_health_weight_goals_on_user_id_final_type", unique: true, where: "((goal_type)::text = 'final'::text)"
    t.index ["user_id"], name: "index_health_weight_goals_on_user_id"
    t.check_constraint "target_weight > 0::numeric", name: "health_weight_goals_positive_target"
  end

  create_table "health_wins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "achieved_on", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "achieved_on"], name: "index_health_wins_on_user_id_and_achieved_on"
    t.index ["user_id"], name: "index_health_wins_on_user_id"
  end

  create_table "incomes", force: :cascade do |t|
    t.decimal "amount"
    t.date "date"
    t.date "balance_month"
    t.string "description"
    t.boolean "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.bigint "user_id"
    t.index ["category_id"], name: "index_incomes_on_category_id"
    t.index ["user_id"], name: "index_incomes_on_user_id"
  end

  create_table "passkey_credentials", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "webauthn_id", null: false
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.string "nickname"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_passkey_credentials_on_user_id"
    t.index ["webauthn_id"], name: "index_passkey_credentials_on_webauthn_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", default: "", null: false
    t.string "webauthn_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["webauthn_id"], name: "index_users_on_webauthn_id", unique: true
  end

  create_table "weekly_health_goal_days", force: :cascade do |t|
    t.bigint "weekly_health_goal_id", null: false
    t.date "occurred_on", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "diet_status"
    t.string "exercise_status"
    t.decimal "duration_minutes", precision: 7, scale: 2
    t.decimal "distance_km", precision: 7, scale: 2
    t.integer "steps"
    t.string "muscle_groups", limit: 150
    t.string "exercise_focus"
    t.string "exercise_intensity"
    t.text "exercise_notes"
    t.index ["weekly_health_goal_id", "occurred_on"], name: "index_weekly_health_goal_days_on_goal_and_date", unique: true
    t.index ["weekly_health_goal_id"], name: "index_weekly_health_goal_days_on_weekly_health_goal_id"
    t.check_constraint "diet_status IS NULL OR (diet_status::text = ANY (ARRAY['full'::character varying, 'partial'::character varying, 'none'::character varying]::text[]))", name: "weekly_health_goal_days_diet_status"
    t.check_constraint "exercise_status IS NULL OR (exercise_status::text = ANY (ARRAY[''::character varying, 'completed'::character varying, 'not_completed'::character varying]::text[]))", name: "weekly_health_goal_days_exercise_status"
  end

  create_table "weekly_health_goals", force: :cascade do |t|
    t.bigint "weekly_health_plan_id", null: false
    t.string "name", null: false
    t.integer "target_count", null: false
    t.integer "completed_count", default: 0, null: false
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["weekly_health_plan_id"], name: "index_weekly_health_goals_on_weekly_health_plan_id"
    t.check_constraint "target_count > 0 AND completed_count >= 0", name: "weekly_health_goals_valid_counts"
  end

  create_table "weekly_health_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "week_start", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "week_start"], name: "index_weekly_health_plans_on_user_id_and_week_start", unique: true
    t.index ["user_id"], name: "index_weekly_health_plans_on_user_id"
    t.check_constraint "EXTRACT(isodow FROM week_start) = 1::numeric", name: "weekly_health_plans_start_on_monday"
  end

  create_table "weekly_health_reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "week_start", null: false
    t.text "worked_well"
    t.text "obstacles"
    t.text "within_control"
    t.text "next_adjustments"
    t.text "minimum_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "review_kind", default: "weekly", null: false
    t.integer "energy"
    t.integer "mood"
    t.integer "routine_satisfaction"
    t.integer "anxiety"
    t.integer "overload"
    t.text "notes"
    t.text "feelings"
    t.text "thoughts"
    t.text "insights"
    t.text "needs_response"
    t.text "recognition"
    t.text "scenario"
    t.text "other_need"
    t.jsonb "needs", default: [], null: false
    t.boolean "legacy_imported", default: false, null: false
    t.bigint "legacy_wellbeing_id"
    t.index ["user_id", "review_kind", "week_start"], name: "index_weekly_health_reviews_on_user_kind_and_start", unique: true
    t.index ["user_id"], name: "index_weekly_health_reviews_on_user_id"
    t.check_constraint "anxiety IS NULL OR anxiety >= 1 AND anxiety <= 5", name: "diary_anxiety_range"
    t.check_constraint "energy IS NULL OR energy >= 1 AND energy <= 5", name: "diary_energy_range"
    t.check_constraint "mood IS NULL OR mood >= 1 AND mood <= 5", name: "diary_mood_range"
    t.check_constraint "overload IS NULL OR overload >= 1 AND overload <= 5", name: "diary_overload_range"
    t.check_constraint "routine_satisfaction IS NULL OR routine_satisfaction >= 1 AND routine_satisfaction <= 5", name: "diary_routine_satisfaction_range"
  end

  create_table "weekly_wellbeings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "week_start", null: false
    t.integer "energy", null: false
    t.integer "mood", null: false
    t.integer "routine_satisfaction", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "week_start"], name: "index_weekly_wellbeings_on_user_id_and_week_start", unique: true
    t.index ["user_id"], name: "index_weekly_wellbeings_on_user_id"
    t.check_constraint "EXTRACT(isodow FROM week_start) = 1::numeric", name: "weekly_wellbeings_start_on_monday"
    t.check_constraint "energy >= 1 AND energy <= 5 AND mood >= 1 AND mood <= 5 AND routine_satisfaction >= 1 AND routine_satisfaction <= 5", name: "weekly_wellbeings_valid_scores"
  end

  create_table "weight_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "measured_on", null: false
    t.decimal "weight_kg", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "measured_on"], name: "index_weight_entries_on_user_id_and_measured_on", unique: true
    t.index ["user_id"], name: "index_weight_entries_on_user_id"
    t.check_constraint "weight_kg > 0::numeric", name: "weight_entries_positive_weight"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cards", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "daily_calorie_entries", "users"
  add_foreign_key "expenses", "cards"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "users"
  add_foreign_key "financial_goal_resources", "financial_goals"
  add_foreign_key "financial_goals", "categories"
  add_foreign_key "financial_goals", "users"
  add_foreign_key "health_journal_entries", "users"
  add_foreign_key "health_profiles", "users"
  add_foreign_key "health_weekly_reflections", "users"
  add_foreign_key "health_weight_goals", "users"
  add_foreign_key "health_wins", "users"
  add_foreign_key "incomes", "categories"
  add_foreign_key "incomes", "users"
  add_foreign_key "passkey_credentials", "users"
  add_foreign_key "weekly_health_goal_days", "weekly_health_goals"
  add_foreign_key "weekly_health_goals", "weekly_health_plans"
  add_foreign_key "weekly_health_plans", "users"
  add_foreign_key "weekly_health_reviews", "users"
  add_foreign_key "weekly_wellbeings", "users"
  add_foreign_key "weight_entries", "users"
end
