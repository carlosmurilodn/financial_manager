WebAuthn.configure do |config|
  config.allowed_origins = ENV.fetch(
    "WEBAUTHN_ALLOWED_ORIGINS",
    [
      "http://localhost:3000",
      "https://sphere-patient-sometimes-copying.trycloudflare.com"
    ].join(",")
  ).split(",").map(&:strip)

  config.rp_name = "Gerenciador Financeiro"
end
