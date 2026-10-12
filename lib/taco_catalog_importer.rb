require "csv"
require "sqlite3"
require "fileutils"
require "active_support/inflector/transliterate"

class TacoCatalogImporter
  # Source: https://github.com/brolesi/taco/blob/main/data/processed/taco/taco_composicao.csv
  # Nutrients are per 100 g; retain source values, including missing values and traces.
  NUTRIENTS = {
    "calories" => "energia_kcal",
    "carbohydrates" => "carboidrato_g",
    "proteins" => "proteina_g",
    "fats" => "lipideos_g",
    "fiber" => "fibra_g"
  }.freeze

  def initialize(csv_path:, database_path:)
    @csv_path = csv_path
    @database_path = database_path
  end

  def call
    rows = CSV.read(@csv_path, headers: true, encoding: "bom|utf-8")
    required = %w[numero_alimento descricao categoria] + NUTRIENTS.values
    raise ArgumentError, "CSV TACO sem colunas obrigatórias" unless (required - rows.headers).empty?

    FileUtils.mkdir_p(File.dirname(@database_path))
    database = SQLite3::Database.new(@database_path.to_s)
    database.busy_timeout = 5000
    database.transaction do
      database.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS taco_foods (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          search_name TEXT NOT NULL,
          calories REAL,
          carbohydrates REAL,
          proteins REAL,
          fats REAL,
          fiber REAL
        )
      SQL
      database.execute("CREATE INDEX IF NOT EXISTS index_taco_foods_on_category ON taco_foods (category)")
      columns = %w[id name category search_name] + NUTRIENTS.keys
      updates = columns.drop(1).map { |column| "#{column} = excluded.#{column}" }.join(", ")
      sql = "INSERT INTO taco_foods (#{columns.join(', ')}) VALUES (#{(['?'] * columns.size).join(', ')}) ON CONFLICT(id) DO UPDATE SET #{updates}"
      rows.each do |row|
        name = row.fetch("descricao")
        category = row.fetch("categoria")
        raise ArgumentError, "Alimento TACO sem nome ou categoria" if name.to_s.strip.empty? || category.to_s.strip.empty?

        values = [ Integer(row.fetch("numero_alimento"), 10), name, category, ActiveSupport::Inflector.transliterate(name).downcase ]
        values.concat(NUTRIENTS.values.map { |column| nutrient(row[column]) })
        database.execute(sql, values)
      end
    end
    rows.size
  ensure
    database&.close
  end

  private

  def nutrient(value)
    return nil if value.nil? || value.strip.empty? || %w[NaN NA N/A NULL].include?(value.strip)

    number = Float(value)
    raise ArgumentError, "Valor nutricional inválido: #{value}" unless number.finite?

    number
  end
end
