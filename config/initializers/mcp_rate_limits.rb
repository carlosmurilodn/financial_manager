require "rack/attack"
require Rails.root.join("lib/mcp_integration/request_limits")

Rails.application.config.middleware.insert_before Rack::Attack, McpIntegration::RequestLimits
Rack::Attack.cache.store = Rails.cache

class Rack::Attack
  throttle("mcp/ip", limit: 120, period: 1.minute) do |request|
    request.ip if request.path == "/mcp"
  end

  throttle("oauth/ip", limit: 30, period: 1.minute) do |request|
    request.ip if request.path.start_with?("/oauth/") && request.post?
  end

  self.throttled_responder = lambda do |request|
    period = request.env.fetch("rack.attack.match_data", {}).fetch(:period, 60)
    [ 429, { "content-type" => "application/json", "retry-after" => period.to_s, "cache-control" => "no-store" },
      [ { error: "rate_limit_exceeded" }.to_json ] ]
  end
end
