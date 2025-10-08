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

ActiveRecord::Schema[8.0].define(version: 2025_10_08_005718) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_limit"
    t.decimal "remaining_limit"
    t.integer "due_day"
    t.integer "best_day"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.date "first_due_date"
    t.boolean "is_parent", default: false
    t.bigint "parent_expense_id"
    t.index ["card_id"], name: "index_expenses_on_card_id"
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["parent_expense_id"], name: "index_expenses_on_parent_expense_id"
  end

  create_table "incomes", force: :cascade do |t|
    t.decimal "amount"
    t.date "date"
    t.date "balance_month"
    t.string "description"
    t.boolean "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "installments", force: :cascade do |t|
    t.bigint "expense_id", null: false
    t.integer "number"
    t.decimal "amount", precision: 10, scale: 2
    t.date "due_date"
    t.boolean "paid", default: false
    t.date "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "balance_month"
    t.index ["expense_id"], name: "index_installments_on_expense_id"
  end

  add_foreign_key "expenses", "cards"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "expenses", column: "parent_expense_id"
  add_foreign_key "installments", "expenses"
end
