require_relative "../taco_catalog_importer"

namespace :taco do
  desc "Importa o CSV TACO local para o catálogo SQLite, atualizando por identificador original"
  task :import do
    count = TacoCatalogImporter.new(
      csv_path: Rails.root.join("db/catalog/data/taco_composicao.csv"),
      database_path: Rails.root.join("db/catalog/taco.sqlite3")
    ).call
    puts "Catálogo TACO: #{count} alimentos importados."
  end
end
