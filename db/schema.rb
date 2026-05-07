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

ActiveRecord::Schema[8.0].define(version: 2026_05_01_002555) do
  # These are extensions that must be enabled in order to support this database
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
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
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
    t.bigint "financial_goal_id", null: false
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
    t.bigint "category_id"
    t.bigint "user_id"
    t.index ["category_id"], name: "index_financial_goals_on_category_id"
    t.index ["due_date"], name: "index_financial_goals_on_due_date"
    t.index ["priority"], name: "index_financial_goals_on_priority"
    t.index ["status"], name: "index_financial_goals_on_status"
    t.index ["user_id"], name: "index_financial_goals_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cards", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "expenses", "cards"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "users"
  add_foreign_key "financial_goal_resources", "financial_goals"
  add_foreign_key "financial_goals", "categories"
  add_foreign_key "financial_goals", "users"
  add_foreign_key "incomes", "categories"
  add_foreign_key "incomes", "users"
  add_foreign_key "passkey_credentials", "users"
end
