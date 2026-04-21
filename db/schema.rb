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

ActiveRecord::Schema[8.0].define(version: 2026_04_20_010000) do
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
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
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
    t.index ["card_id"], name: "index_expenses_on_card_id"
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["installment_group_id"], name: "index_expenses_on_installment_group_id"
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
    t.index ["category_id"], name: "index_incomes_on_category_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "expenses", "cards"
  add_foreign_key "expenses", "categories"
  add_foreign_key "incomes", "categories"
end
