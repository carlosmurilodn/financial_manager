namespace :mcp do
  desc "Cadastrar cliente OAuth MCP usando MCP_CLIENT_NAME e MCP_CLIENT_REDIRECT_URI"
  task register_client: :environment do
    abort "Habilite MCP_ENABLED=true e configure MCP_BASE_URL." unless McpIntegration::Settings.enabled?
    name = ENV.fetch("MCP_CLIENT_NAME")
    redirect = ENV.fetch("MCP_CLIENT_REDIRECT_URI")
    uri = URI.parse(redirect)
    abort "Callback deve ser HTTPS, sem fragmento, wildcard nem credenciais." unless uri.scheme == "https" && uri.host && !uri.host.include?("*") && !uri.fragment && !uri.userinfo
    abort "Cliente já cadastrado com este callback." if Doorkeeper::Application.exists?(redirect_uri: redirect)

    client = Doorkeeper::Application.create!(name: name, redirect_uri: redirect,
      scopes: McpIntegration::Settings::SCOPE, confidential: ENV.fetch("MCP_CLIENT_CONFIDENTIAL", "true") == "true")
    puts "Client ID: #{client.uid}"
    puts "Client Secret: #{client.plaintext_secret}" if client.confidential?
    puts "Guarde credenciais em local seguro; não inclua no Git."
  end

  desc "Revogar todos os tokens e códigos de um cliente usando MCP_CLIENT_ID"
  task revoke_client: :environment do
    client = Doorkeeper::Application.find_by!(uid: ENV.fetch("MCP_CLIENT_ID"))
    Doorkeeper::AccessToken.where(application_id: client.id, revoked_at: nil).update_all(revoked_at: Time.current)
    Doorkeeper::AccessGrant.where(application_id: client.id, revoked_at: nil).update_all(revoked_at: Time.current)
    puts "Tokens e códigos revogados. Para impedir novas autorizações, remova o cliente."
  end
end
