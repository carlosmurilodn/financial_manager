# frozen_string_literal: true

require "active_record/schema_dumper"
require "active_record/connection_adapters/abstract/schema_dumper"
require "active_record/connection_adapters/postgresql/schema_dumper"

module PostgreSQLSchemaDumperWithIdempotentSchemas
  private

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
