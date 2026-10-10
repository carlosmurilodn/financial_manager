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

ActiveRecord::Schema[8.0].define(version: 2026_10_11_013000) do
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
  enable_extension "vault.supabase_vault"

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
