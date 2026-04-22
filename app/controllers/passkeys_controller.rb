class PasskeysController < ApplicationController
  skip_before_action :require_login, only: %i[authentication_options authenticate]
  skip_before_action :refresh_session_activity, only: %i[authentication_options authenticate]

  def setup
  end

  def registration_options
    current_user.update!(webauthn_id: WebAuthn.generate_user_id) if current_user.webauthn_id.blank?

    options = relying_party.options_for_registration(
      user: {
        id: current_user.webauthn_id,
        name: current_user.email,
        display_name: current_user.email
      },
      exclude: current_user.passkey_credentials.pluck(:webauthn_id),
      authenticator_selection: {
        user_verification: "required",
        resident_key: "preferred"
      }
    )

    session[:passkey_registration_challenge] = options.challenge
    render json: options
  end

  def create
    webauthn_credential = relying_party.verify_registration(
      public_key_credential_params,
      session.delete(:passkey_registration_challenge),
      user_verification: true
    )

    current_user.passkey_credentials.create!(
      webauthn_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
      nickname: browser_label
    )

    remember_passkey_email(current_user)
    render json: { message: "Passkey ativada com sucesso.", redirect_url: root_path }
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def authentication_options
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    unless user&.passkey_credentials&.exists?
      render json: { error: "Nenhuma passkey encontrada para este e-mail." }, status: :not_found
      return
    end

    options = relying_party.options_for_authentication(
      allow: user.passkey_credentials.pluck(:webauthn_id),
      user_verification: "required"
    )

    session[:passkey_authentication_challenge] = options.challenge
    session[:passkey_authentication_user_id] = user.id
    render json: options
  end

  def authenticate
    user = User.find_by(id: session[:passkey_authentication_user_id])
    webauthn_credential = WebAuthn::Credential.from_get(public_key_credential_params, relying_party: relying_party)
    stored_credential = user&.passkey_credentials&.find_by(webauthn_id: webauthn_credential.id)

    unless user && stored_credential
      render json: { error: "Credencial nao encontrada." }, status: :not_found
      return
    end

    webauthn_credential.verify(
      session.delete(:passkey_authentication_challenge),
      public_key: stored_credential.public_key,
      sign_count: stored_credential.sign_count,
      user_verification: true
    )

    stored_credential.update!(
      sign_count: webauthn_credential.sign_count,
      last_used_at: Time.current
    )

    sign_in(user)
    remember_passkey_email(user)
    render json: { message: "Login por biometria realizado.", redirect_url: root_path }
  rescue WebAuthn::Error => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  private

  def public_key_credential_params
    params.require(:publicKeyCredential).permit!.to_h
  end

  def relying_party
    @relying_party ||= WebAuthn::RelyingParty.new(
      id: request.host,
      name: "Gerenciador Financeiro",
      allowed_origins: [request.base_url]
    )
  end

  def browser_label
    request.user_agent.to_s.first(120)
  end
end
