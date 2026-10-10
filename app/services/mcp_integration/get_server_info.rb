require "mcp"

module McpIntegration
  class GetServerInfo < MCP::Tool
    tool_name "get_server_info"
    description "Informações públicas da integração, sem consultar dados pessoais."
    input_schema(type: "object", properties: {}, additionalProperties: false)
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    def self.call(server_context:)
      raise "Contexto autenticado ausente" unless server_context.user

      info = { application: "Gerenciador Pessoal", module: "Estúdio de Escrita", integration_version: Settings::VERSION,
        read_capabilities: [ "get_server_info" ] }
      MCP::Tool::Response.new([ { type: "text", text: info.to_json } ], structured_content: info)
    end
  end
end
