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

ActiveRecord::Schema[8.0].define(version: 2026_10_11_012200) do
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

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.string "mcp_resource", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "mcp_resource", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "writing_studio:read", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

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

  create_table "exercise_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "performed_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "performed_on"], name: "index_exercise_entries_on_user_id_and_performed_on"
    t.index ["user_id"], name: "index_exercise_entries_on_user_id"
  end

  create_table "exercise_items", force: :cascade do |t|
    t.bigint "exercise_entry_id", null: false
    t.string "exercise_type", null: false
    t.integer "duration_minutes"
    t.string "intensity"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_entry_id"], name: "index_exercise_items_on_exercise_entry_id"
    t.index ["exercise_type"], name: "index_exercise_items_on_exercise_type"
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

  create_table "muscle_groups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "active"], name: "index_muscle_groups_on_user_id_and_active"
    t.index ["user_id", "name"], name: "index_muscle_groups_on_user_id_and_name", unique: true
    t.index ["user_id", "position"], name: "index_muscle_groups_on_user_id_and_position"
    t.index ["user_id"], name: "index_muscle_groups_on_user_id"
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

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", limit: 1024, null: false
    t.binary "value", limit: 536870912, null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "strength_exercise_catalogs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "muscle_group_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["muscle_group_id"], name: "index_strength_exercise_catalogs_on_muscle_group_id"
    t.index ["user_id", "active"], name: "index_strength_exercise_catalogs_on_user_id_and_active"
    t.index ["user_id", "muscle_group_id"], name: "idx_on_user_id_muscle_group_id_b5d651f973"
    t.index ["user_id", "name"], name: "index_strength_exercise_catalogs_on_user_id_and_name", unique: true
    t.index ["user_id", "position"], name: "index_strength_exercise_catalogs_on_user_id_and_position"
    t.index ["user_id"], name: "index_strength_exercise_catalogs_on_user_id"
  end

  create_table "strength_exercise_logs", force: :cascade do |t|
    t.bigint "exercise_item_id", null: false
    t.bigint "muscle_group_id", null: false
    t.bigint "strength_exercise_catalog_id", null: false
    t.integer "sets", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_item_id"], name: "index_strength_exercise_logs_on_exercise_item_id"
    t.index ["muscle_group_id"], name: "index_strength_exercise_logs_on_muscle_group_id"
    t.index ["strength_exercise_catalog_id"], name: "index_strength_exercise_logs_on_strength_exercise_catalog_id"
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
    t.index ["weekly_health_goal_id", "occurred_on"], name: "index_weekly_health_goal_days_on_goal_and_date", unique: true
    t.index ["weekly_health_goal_id"], name: "index_weekly_health_goal_days_on_weekly_health_goal_id"
    t.check_constraint "diet_status IS NULL OR (diet_status::text = ANY (ARRAY['full'::character varying, 'partial'::character varying, 'none'::character varying]::text[]))", name: "weekly_health_goal_days_diet_status"
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

  create_table "writing_activity_events", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "chapter_id"
    t.bigint "scene_id"
    t.string "chapter_title", null: false
    t.string "scene_title"
    t.string "operation", null: false
    t.datetime "occurred_at", null: false
    t.bigint "previous_words", null: false
    t.bigint "current_words", null: false
    t.bigint "added_words", null: false
    t.bigint "removed_words", null: false
    t.bigint "net_words", null: false
    t.bigint "book_words", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id", "chapter_id", "occurred_at"], name: "idx_writing_activity_chapter"
    t.index ["writing_book_id", "occurred_at", "id"], name: "idx_writing_activity_history"
    t.index ["writing_book_id"], name: "index_writing_activity_events_on_writing_book_id"
    t.check_constraint "previous_words >= 0 AND current_words >= 0 AND added_words >= 0 AND removed_words >= 0 AND book_words >= 0 AND net_words = (added_words - removed_words)", name: "writing_activity_valid_counts"
  end

  create_table "writing_books", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "subtitle"
    t.string "author"
    t.string "genre", null: false
    t.string "secondary_genres", default: [], null: false, array: true
    t.string "target_audience"
    t.text "synopsis"
    t.text "premise"
    t.text "notes"
    t.string "status", default: "idea", null: false
    t.date "started_on"
    t.date "expected_completion_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "writing_history_started_at"
    t.bigint "writing_history_initial_words"
    t.jsonb "writing_history_initial_chapters", default: {}, null: false
    t.index ["user_id", "genre"], name: "index_writing_books_on_user_id_and_genre"
    t.index ["user_id", "status"], name: "index_writing_books_on_user_id_and_status"
    t.index ["user_id"], name: "index_writing_books_on_user_id"
  end

  create_table "writing_chapters", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "title", null: false
    t.jsonb "content", default: {"type"=>"doc", "content"=>[{"type"=>"paragraph", "attrs"=>{"textAlign"=>"left", "firstLineIndent"=>true}}]}, null: false
    t.integer "document_version", default: 1, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0, null: false
    t.index ["id", "writing_book_id"], name: "index_writing_chapters_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_chapters_on_writing_book_id"
  end

  create_table "writing_characters", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "name", null: false
    t.string "surname"
    t.string "nicknames"
    t.string "role"
    t.string "status"
    t.text "age"
    t.text "appearance"
    t.text "height"
    t.text "distinguishing_features"
    t.text "usual_clothing"
    t.text "personality"
    t.text "virtues"
    t.text "flaws"
    t.text "fears"
    t.text "desires"
    t.text "motivations"
    t.text "beliefs"
    t.text "internal_contradictions"
    t.text "origin"
    t.text "past"
    t.text "family"
    t.text "education"
    t.text "profession"
    t.text "secrets"
    t.text "goals"
    t.text "internal_needs"
    t.text "conflicts"
    t.text "initial_situation"
    t.text "planned_transformations"
    t.text "planned_outcome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_characters_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_characters_on_writing_book_id"
  end

  create_table "writing_relationships", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "source_character_id", null: false
    t.bigint "target_character_id", null: false
    t.string "relation_type", null: false
    t.text "description"
    t.text "current_situation"
    t.string "fingerprint", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_character_id"], name: "index_writing_relationships_on_source_character_id"
    t.index ["target_character_id"], name: "index_writing_relationships_on_target_character_id"
    t.index ["writing_book_id", "fingerprint"], name: "index_writing_relationships_on_writing_book_id_and_fingerprint", unique: true
    t.index ["writing_book_id"], name: "index_writing_relationships_on_writing_book_id"
    t.check_constraint "source_character_id <> target_character_id", name: "writing_relationship_different_characters"
  end

  create_table "writing_plots", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "kind"
    t.string "status"
    t.text "narrative_goal"
    t.text "planned_development"
    t.text "planned_outcome"
    t.bigint "parent_plot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_plots_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_plots_on_writing_book_id"
    t.check_constraint "parent_plot_id IS NULL OR parent_plot_id <> id", name: "writing_plots_not_self_parent"
  end

  create_table "writing_conflicts", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "kind"
    t.text "origin"
    t.string "intensity"
    t.string "status"
    t.text "consequences"
    t.text "planned_resolution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_conflicts_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_conflicts_on_writing_book_id"
  end

  create_table "writing_github_syncs", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "status", default: "never", null: false
    t.datetime "last_attempt_at"
    t.datetime "last_success_at"
    t.text "error_message"
    t.string "repository"
    t.string "branch"
    t.integer "created_count", default: 0, null: false
    t.integer "updated_count", default: 0, null: false
    t.integer "unchanged_count", default: 0, null: false
    t.jsonb "obsolete_files", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pending_changes", default: false, null: false
    t.datetime "first_pending_at"
    t.datetime "scheduled_at"
    t.datetime "retry_at"
    t.datetime "next_pending_at"
    t.bigint "content_revision", default: 0, null: false
    t.bigint "synced_revision", default: 0, null: false
    t.bigint "sending_revision"
    t.index ["scheduled_at"], name: "index_writing_github_syncs_pending_schedule", where: "pending_changes"
    t.index ["writing_book_id"], name: "index_writing_github_syncs_on_writing_book_id", unique: true
    t.check_constraint "NOT pending_changes OR first_pending_at IS NOT NULL AND scheduled_at IS NOT NULL", name: "writing_github_syncs_pending_schedule"
    t.check_constraint "content_revision >= synced_revision AND synced_revision >= 0", name: "writing_github_syncs_valid_revisions"
    t.check_constraint "created_count >= 0 AND updated_count >= 0 AND unchanged_count >= 0", name: "writing_github_syncs_valid_counts"
    t.check_constraint "status::text = ANY (ARRAY['never'::character varying, 'processing'::character varying, 'succeeded'::character varying, 'failed'::character varying]::text[])", name: "writing_github_syncs_valid_status"
  end
  execute "ALTER TABLE writing_github_syncs ENABLE ROW LEVEL SECURITY"

  create_table "writing_locations", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "name", null: false
    t.string "kind"
    t.text "description"
    t.text "location"
    t.text "physical_features"
    t.text "atmosphere"
    t.text "narrative_importance"
    t.bigint "parent_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_locations_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_locations_on_writing_book_id"
    t.check_constraint "parent_location_id IS NULL OR parent_location_id <> id", name: "writing_locations_not_self_parent"
  end

  create_table "writing_organizations", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "name", null: false
    t.string "kind"
    t.text "description"
    t.text "history"
    t.text "purpose"
    t.text "structure"
    t.text "notes"
    t.bigint "writing_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_organizations_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_organizations_on_writing_book_id"
  end

  create_table "writing_timeline_events", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "kind", default: "main", null: false
    t.string "status", default: "planned", null: false
    t.string "date_mode", default: "undefined", null: false
    t.date "occurred_on"
    t.time "occurred_at"
    t.string "temporal_reference"
    t.bigint "reference_event_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_timeline_events_on_id_and_writing_book_id", unique: true
    t.index ["reference_event_id"], name: "index_writing_timeline_events_on_reference_event_id"
    t.index ["writing_book_id", "occurred_on", "position"], name: "idx_timeline_chronology"
    t.index ["writing_book_id"], name: "index_writing_timeline_events_on_writing_book_id"
    t.check_constraint "date_mode::text = 'exact'::text AND occurred_on IS NOT NULL AND reference_event_id IS NULL OR (date_mode::text = ANY (ARRAY['approximate'::character varying, 'relative'::character varying, 'undefined'::character varying]::text[])) AND occurred_on IS NULL AND (date_mode::text = 'relative'::text OR reference_event_id IS NULL)", name: "timeline_valid_date"
    t.check_constraint "reference_event_id IS NULL OR reference_event_id <> id", name: "timeline_no_self_reference"
  end

  create_table "writing_timeline_links", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_timeline_event_id", null: false
    t.bigint "writing_character_id"
    t.bigint "writing_location_id"
    t.bigint "writing_plot_id"
    t.bigint "writing_conflict_id"
    t.bigint "writing_chapter_id"
    t.bigint "writing_scene_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_timeline_links_on_writing_book_id"
    t.index ["writing_chapter_id"], name: "index_writing_timeline_links_on_writing_chapter_id"
    t.index ["writing_character_id"], name: "index_writing_timeline_links_on_writing_character_id"
    t.index ["writing_conflict_id"], name: "index_writing_timeline_links_on_writing_conflict_id"
    t.index ["writing_location_id"], name: "index_writing_timeline_links_on_writing_location_id"
    t.index ["writing_plot_id"], name: "index_writing_timeline_links_on_writing_plot_id"
    t.index ["writing_scene_id"], name: "index_writing_timeline_links_on_writing_scene_id"
    t.index ["writing_timeline_event_id", "writing_chapter_id"], name: "idx_timeline_link_chapter", unique: true, where: "(writing_chapter_id IS NOT NULL)"
    t.index ["writing_timeline_event_id", "writing_character_id"], name: "idx_timeline_link_character", unique: true, where: "(writing_character_id IS NOT NULL)"
    t.index ["writing_timeline_event_id", "writing_conflict_id"], name: "idx_timeline_link_conflict", unique: true, where: "(writing_conflict_id IS NOT NULL)"
    t.index ["writing_timeline_event_id", "writing_location_id"], name: "idx_timeline_link_location", unique: true, where: "(writing_location_id IS NOT NULL)"
    t.index ["writing_timeline_event_id", "writing_plot_id"], name: "idx_timeline_link_plot", unique: true, where: "(writing_plot_id IS NOT NULL)"
    t.index ["writing_timeline_event_id", "writing_scene_id"], name: "idx_timeline_link_scene", unique: true, where: "(writing_scene_id IS NOT NULL)"
    t.index ["writing_timeline_event_id"], name: "idx_timeline_links_event"
    t.check_constraint "num_nonnulls(writing_character_id, writing_location_id, writing_plot_id, writing_conflict_id, writing_chapter_id, writing_scene_id) = 1", name: "timeline_link_one_target"
  end

  create_table "writing_universe_rules", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "title", null: false
    t.string "category"
    t.text "description"
    t.text "limitations"
    t.text "exceptions"
    t.text "narrative_consequences"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_universe_rules_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_universe_rules_on_writing_book_id"
  end

  create_table "writing_plot_characters", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_plot_id", null: false
    t.bigint "writing_character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_plot_characters_on_writing_book_id"
    t.index ["writing_character_id"], name: "index_writing_plot_characters_on_writing_character_id"
    t.index ["writing_plot_id", "writing_character_id"], name: "idx_plot_character_unique", unique: true
    t.index ["writing_plot_id"], name: "index_writing_plot_characters_on_writing_plot_id"
  end

  create_table "writing_conflict_characters", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_conflict_id", null: false
    t.bigint "writing_character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_conflict_characters_on_writing_book_id"
    t.index ["writing_character_id"], name: "index_writing_conflict_characters_on_writing_character_id"
    t.index ["writing_conflict_id", "writing_character_id"], name: "idx_conflict_character_unique", unique: true
    t.index ["writing_conflict_id"], name: "index_writing_conflict_characters_on_writing_conflict_id"
  end

  create_table "writing_conflict_plots", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_conflict_id", null: false
    t.bigint "writing_plot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_conflict_plots_on_writing_book_id"
    t.index ["writing_conflict_id", "writing_plot_id"], name: "idx_conflict_plot_unique", unique: true
    t.index ["writing_conflict_id"], name: "index_writing_conflict_plots_on_writing_conflict_id"
    t.index ["writing_plot_id"], name: "index_writing_conflict_plots_on_writing_plot_id"
  end

  create_table "writing_organization_memberships", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_organization_id", null: false
    t.bigint "writing_character_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_organization_memberships_on_writing_book_id"
    t.index ["writing_character_id"], name: "index_writing_organization_memberships_on_writing_character_id"
    t.index ["writing_organization_id", "writing_character_id"], name: "idx_organization_membership_unique", unique: true
    t.index ["writing_organization_id"], name: "idx_on_writing_organization_id_d17612b1ef"
  end

  create_table "writing_scenes", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_chapter_id", null: false
    t.string "title", null: false
    t.jsonb "content", default: {"type"=>"doc", "content"=>[{"type"=>"paragraph", "attrs"=>{"textAlign"=>"left", "firstLineIndent"=>true}}]}, null: false
    t.integer "document_version", default: 1, null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_scenes_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_scenes_on_writing_book_id"
    t.index ["writing_chapter_id", "position"], name: "index_writing_scenes_on_writing_chapter_id_and_position"
  end

  create_table "writing_notes", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "category"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "writing_book_id"], name: "index_writing_notes_on_id_and_writing_book_id", unique: true
    t.index ["writing_book_id"], name: "index_writing_notes_on_writing_book_id"
  end

  create_table "writing_note_links", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_note_id", null: false
    t.bigint "writing_character_id"
    t.bigint "writing_plot_id"
    t.bigint "writing_conflict_id"
    t.bigint "writing_chapter_id"
    t.bigint "writing_scene_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_note_links_on_writing_book_id"
    t.index ["writing_chapter_id"], name: "index_writing_note_links_on_writing_chapter_id"
    t.index ["writing_character_id"], name: "index_writing_note_links_on_writing_character_id"
    t.index ["writing_conflict_id"], name: "index_writing_note_links_on_writing_conflict_id"
    t.index ["writing_note_id", "writing_chapter_id"], name: "idx_note_link_chapter", unique: true, where: "(writing_chapter_id IS NOT NULL)"
    t.index ["writing_note_id", "writing_character_id"], name: "idx_note_link_character", unique: true, where: "(writing_character_id IS NOT NULL)"
    t.index ["writing_note_id", "writing_conflict_id"], name: "idx_note_link_conflict", unique: true, where: "(writing_conflict_id IS NOT NULL)"
    t.index ["writing_note_id", "writing_plot_id"], name: "idx_note_link_plot", unique: true, where: "(writing_plot_id IS NOT NULL)"
    t.index ["writing_note_id", "writing_scene_id"], name: "idx_note_link_scene", unique: true, where: "(writing_scene_id IS NOT NULL)"
    t.index ["writing_plot_id"], name: "index_writing_note_links_on_writing_plot_id"
    t.index ["writing_scene_id"], name: "index_writing_note_links_on_writing_scene_id"
    t.check_constraint "num_nonnulls(writing_character_id, writing_plot_id, writing_conflict_id, writing_chapter_id, writing_scene_id) = 1", name: "note_link_one_target"
  end

  create_table "writing_narrative_associations", force: :cascade do |t|
    t.bigint "writing_book_id", null: false
    t.bigint "writing_chapter_id"
    t.bigint "writing_scene_id"
    t.bigint "writing_character_id"
    t.bigint "writing_plot_id"
    t.bigint "writing_conflict_id"
    t.bigint "writing_location_id"
    t.bigint "writing_organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writing_book_id"], name: "index_writing_narrative_associations_on_writing_book_id"
    t.index ["writing_chapter_id", "writing_character_id"], name: "idx_narrative_chapter_character", unique: true, where: "((writing_chapter_id IS NOT NULL) AND (writing_character_id IS NOT NULL))"
    t.index ["writing_chapter_id", "writing_conflict_id"], name: "idx_narrative_chapter_conflict", unique: true, where: "((writing_chapter_id IS NOT NULL) AND (writing_conflict_id IS NOT NULL))"
    t.index ["writing_chapter_id", "writing_location_id"], name: "idx_narrative_chapter_location", unique: true, where: "((writing_chapter_id IS NOT NULL) AND (writing_location_id IS NOT NULL))"
    t.index ["writing_chapter_id", "writing_organization_id"], name: "idx_narrative_chapter_organization", unique: true, where: "((writing_chapter_id IS NOT NULL) AND (writing_organization_id IS NOT NULL))"
    t.index ["writing_chapter_id", "writing_plot_id"], name: "idx_narrative_chapter_plot", unique: true, where: "((writing_chapter_id IS NOT NULL) AND (writing_plot_id IS NOT NULL))"
    t.index ["writing_chapter_id"], name: "index_writing_narrative_associations_on_writing_chapter_id"
    t.index ["writing_character_id"], name: "index_writing_narrative_associations_on_writing_character_id"
    t.index ["writing_conflict_id"], name: "index_writing_narrative_associations_on_writing_conflict_id"
    t.index ["writing_location_id"], name: "index_writing_narrative_associations_on_writing_location_id"
    t.index ["writing_organization_id"], name: "idx_on_writing_organization_id_b99c8ed9d0"
    t.index ["writing_plot_id"], name: "index_writing_narrative_associations_on_writing_plot_id"
    t.index ["writing_scene_id", "writing_character_id"], name: "idx_narrative_scene_character", unique: true, where: "((writing_scene_id IS NOT NULL) AND (writing_character_id IS NOT NULL))"
    t.index ["writing_scene_id", "writing_conflict_id"], name: "idx_narrative_scene_conflict", unique: true, where: "((writing_scene_id IS NOT NULL) AND (writing_conflict_id IS NOT NULL))"
    t.index ["writing_scene_id", "writing_location_id"], name: "idx_narrative_scene_location", unique: true, where: "((writing_scene_id IS NOT NULL) AND (writing_location_id IS NOT NULL))"
    t.index ["writing_scene_id", "writing_organization_id"], name: "idx_narrative_scene_organization", unique: true, where: "((writing_scene_id IS NOT NULL) AND (writing_organization_id IS NOT NULL))"
    t.index ["writing_scene_id", "writing_plot_id"], name: "idx_narrative_scene_plot", unique: true, where: "((writing_scene_id IS NOT NULL) AND (writing_plot_id IS NOT NULL))"
    t.index ["writing_scene_id"], name: "index_writing_narrative_associations_on_writing_scene_id"
    t.check_constraint "num_nonnulls(writing_chapter_id, writing_scene_id) = 1", name: "narrative_association_one_owner"
    t.check_constraint "num_nonnulls(writing_character_id, writing_plot_id, writing_conflict_id, writing_location_id, writing_organization_id) = 1", name: "narrative_association_one_element"
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id", on_delete: :cascade
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id", on_delete: :cascade
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cards", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "daily_calorie_entries", "users"
  add_foreign_key "exercise_entries", "users"
  add_foreign_key "exercise_items", "exercise_entries"
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
  add_foreign_key "muscle_groups", "users"
  add_foreign_key "passkey_credentials", "users"
  add_foreign_key "strength_exercise_catalogs", "muscle_groups"
  add_foreign_key "strength_exercise_catalogs", "users"
  add_foreign_key "strength_exercise_logs", "exercise_items"
  add_foreign_key "strength_exercise_logs", "muscle_groups"
  add_foreign_key "strength_exercise_logs", "strength_exercise_catalogs"
  add_foreign_key "weekly_health_goal_days", "weekly_health_goals"
  add_foreign_key "weekly_health_goals", "weekly_health_plans"
  add_foreign_key "weekly_health_plans", "users"
  add_foreign_key "weekly_health_reviews", "users"
  add_foreign_key "weekly_wellbeings", "users"
  add_foreign_key "weight_entries", "users"
  add_foreign_key "writing_books", "users"
  add_foreign_key "writing_activity_events", "writing_books"
  add_foreign_key "writing_chapters", "writing_books"
  add_foreign_key "writing_characters", "writing_books"
  add_foreign_key "writing_relationships", "writing_books"
  add_foreign_key "writing_relationships", "writing_characters", column: ["source_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_writing_relationship_source_book"
  add_foreign_key "writing_relationships", "writing_characters", column: ["target_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_writing_relationship_target_book"
  add_foreign_key "writing_conflict_characters", "writing_books"
  add_foreign_key "writing_conflict_characters", "writing_characters", column: ["writing_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_conflict_characters", "writing_conflicts", column: ["writing_conflict_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_conflict_plots", "writing_books"
  add_foreign_key "writing_conflict_plots", "writing_conflicts", column: ["writing_conflict_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_conflict_plots", "writing_plots", column: ["writing_plot_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_conflicts", "writing_books"
  add_foreign_key "writing_github_syncs", "writing_books"
  add_foreign_key "writing_locations", "writing_books"
  add_foreign_key "writing_locations", "writing_locations", column: ["parent_location_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_organization_memberships", "writing_books"
  add_foreign_key "writing_organization_memberships", "writing_characters", column: ["writing_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_organization_memberships", "writing_organizations", column: ["writing_organization_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_organizations", "writing_books"
  add_foreign_key "writing_organizations", "writing_locations", column: ["writing_location_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_plot_characters", "writing_books"
  add_foreign_key "writing_plot_characters", "writing_characters", column: ["writing_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_plot_characters", "writing_plots", column: ["writing_plot_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_plots", "writing_books"
  add_foreign_key "writing_plots", "writing_plots", column: ["parent_plot_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_universe_rules", "writing_books"
  add_foreign_key "writing_narrative_associations", "writing_books"
  add_foreign_key "writing_narrative_associations", "writing_chapters", column: ["writing_chapter_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_narrative_associations", "writing_characters", column: ["writing_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_narrative_associations", "writing_conflicts", column: ["writing_conflict_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_narrative_associations", "writing_locations", column: ["writing_location_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_narrative_associations", "writing_organizations", column: ["writing_organization_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_narrative_associations", "writing_plots", column: ["writing_plot_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_narrative_associations", "writing_scenes", column: ["writing_scene_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_note_links", "writing_books"
  add_foreign_key "writing_note_links", "writing_chapters", column: ["writing_chapter_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_note_links", "writing_characters", column: ["writing_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_note_links", "writing_conflicts", column: ["writing_conflict_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_note_links", "writing_notes", column: ["writing_note_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_note_links", "writing_plots", column: ["writing_plot_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_note_links", "writing_scenes", column: ["writing_scene_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_notes", "writing_books"
  add_foreign_key "writing_scenes", "writing_books"
  add_foreign_key "writing_scenes", "writing_chapters", column: ["writing_chapter_id", "writing_book_id"], primary_key: ["id", "writing_book_id"]
  add_foreign_key "writing_timeline_events", "writing_books"
  add_foreign_key "writing_timeline_events", "writing_timeline_events", column: ["reference_event_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_reference_book"
  add_foreign_key "writing_timeline_links", "writing_books"
  add_foreign_key "writing_timeline_links", "writing_chapters", column: ["writing_chapter_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_chapter_book"
  add_foreign_key "writing_timeline_links", "writing_characters", column: ["writing_character_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_character_book"
  add_foreign_key "writing_timeline_links", "writing_conflicts", column: ["writing_conflict_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_conflict_book"
  add_foreign_key "writing_timeline_links", "writing_locations", column: ["writing_location_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_location_book"
  add_foreign_key "writing_timeline_links", "writing_plots", column: ["writing_plot_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_plot_book"
  add_foreign_key "writing_timeline_links", "writing_scenes", column: ["writing_scene_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_scene_book"
  add_foreign_key "writing_timeline_links", "writing_timeline_events", column: ["writing_timeline_event_id", "writing_book_id"], primary_key: ["id", "writing_book_id"], name: "fk_timeline_link_event_book"
end
