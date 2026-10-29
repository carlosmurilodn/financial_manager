# frozen_string_literal: true

require "active_record/schema_dumper"
require "active_record/connection_adapters/abstract/schema_dumper"
require "active_record/connection_adapters/postgresql/schema_dumper"

module PostgreSQLSchemaDumperWithIdempotentSchemas
  private

  def table(table, stream)
    super
    return unless %w[writing_github_syncs health_data_github_syncs].include?(table)
    return unless @connection.select_value("SELECT relrowsecurity FROM pg_class WHERE oid = #{@connection.quote(table)}::regclass")

    stream.puts "  execute #{"ALTER TABLE #{table} ENABLE ROW LEVEL SECURITY".inspect}"
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
