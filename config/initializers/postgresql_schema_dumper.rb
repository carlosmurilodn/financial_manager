# frozen_string_literal: true

require "active_record/schema_dumper"
require "active_record/connection_adapters/abstract/schema_dumper"
require "active_record/connection_adapters/postgresql/schema_dumper"

module PostgreSQLSchemaDumperWithIdempotentSchemas
  private

  def table(table, stream)
    super
    return unless table == "writing_github_syncs"
    return unless @connection.select_value("SELECT relrowsecurity FROM pg_class WHERE oid = 'writing_github_syncs'::regclass")

    stream.puts '  execute "ALTER TABLE writing_github_syncs ENABLE ROW LEVEL SECURITY"'
  end

  def schemas(stream)
    schema_names = @connection.schema_names - [ "public" ]

    if schema_names.any?
      schema_names.sort.each do |name|
        stream.puts "  create_schema #{name.inspect}, if_not_exists: true"
      end
      stream.puts
    end
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend(
  PostgreSQLSchemaDumperWithIdempotentSchemas
)
