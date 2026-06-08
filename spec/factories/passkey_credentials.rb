FactoryBot.define do
  factory :passkey_credential do
    association :user
    sequence(:webauthn_id) { |number| "webauthn-id-#{number}" }
    public_key { "public-key" }
    sign_count { 0 }
  end
end
