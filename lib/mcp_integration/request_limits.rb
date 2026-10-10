require "stringio"

module McpIntegration
  class RequestLimits
    def initialize(app)
      @app = app
    end

    def call(env)
      path = env["PATH_INFO"].to_s
      return @app.call(env) unless path == "/mcp" || path.start_with?("/oauth/")
      return too_large if env["CONTENT_LENGTH"].to_i > Settings::MAX_REQUEST_BYTES

      input = env["rack.input"]
      if input
        body = input.read(Settings::MAX_REQUEST_BYTES + 1)
        return too_large if body.bytesize > Settings::MAX_REQUEST_BYTES

        env["rack.input"] = StringIO.new(body)
      end
      @app.call(env)
    end

    private

    def too_large
      [ 413, { "content-type" => "application/json", "cache-control" => "no-store" }, [ '{"error":"payload_too_large"}' ] ]
    end
  end
end
