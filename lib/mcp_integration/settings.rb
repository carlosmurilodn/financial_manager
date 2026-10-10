require "uri"

module McpIntegration
  module Settings
    SCOPE = "writing_studio:read"
    VERSION = "1.0.0"
    MAX_REQUEST_BYTES = 64 * 1024

    def self.enabled?
      ENV["MCP_ENABLED"] == "true"
    end

    def self.base_url
      ENV.fetch("MCP_BASE_URL", "http://localhost:3000").delete_suffix("/")
    end

    def self.resource
      "#{base_url}/mcp"
    end

    def self.origin
      base_url
    end

    def self.allowed_origins
      [ origin, *ENV.fetch("MCP_ALLOWED_ORIGINS", "").split(",").map(&:strip) ].reject(&:empty?)
    end

    def self.validate!
      return unless enabled?

      uri = URI.parse(base_url)
      valid = %w[http https].include?(uri.scheme) && uri.host && uri.userinfo.nil? &&
        uri.query.nil? && uri.fragment.nil? && uri.path.empty?
      local = !Rails.env.production? && %w[localhost 127.0.0.1 ::1].include?(uri.host)
      raise ArgumentError, "MCP_BASE_URL deve ser uma origem HTTPS; HTTP somente para loopback em desenvolvimento." unless valid && (uri.scheme == "https" || local)

      allowed_origins.each do |value|
        origin_uri = URI.parse(value)
        raise ArgumentError, "MCP_ALLOWED_ORIGINS inválido." unless %w[http https].include?(origin_uri.scheme) && origin_uri.host && origin_uri.path.empty? && !origin_uri.query && !origin_uri.fragment && !origin_uri.userinfo
      end
    end
  end
end
