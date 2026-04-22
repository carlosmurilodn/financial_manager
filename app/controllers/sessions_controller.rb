class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create close]
  skip_before_action :refresh_session_activity, only: %i[new create close]
  skip_forgery_protection only: :close

  def new
    redirect_to sign_up_path unless User.exists?
    prepare_passkey_hint
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      sign_in(user)

      if user.passkey_credentials.exists?
        remember_passkey_email(user)
        redirect_to root_path, notice: "Login realizado."
      elsif mobile_passkey_device?
        redirect_to passkeys_setup_path, notice: "Login realizado. Ative a entrada por biometria para a proxima vez."
      else
        redirect_to root_path, notice: "Login realizado."
      end
    else
      flash.now[:alert] = "E-mail ou senha invalidos."
      prepare_passkey_hint
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to login_path, notice: "Sessao encerrada."
  end

  def close
    sign_out
    head :ok
  end

  private

  def prepare_passkey_hint
    @remembered_passkey_email = cookies.signed[:last_passkey_email].to_s
    remembered_user = User.find_by(email: @remembered_passkey_email)
    @show_passkey_login = mobile_passkey_device?
    @prefer_passkey = @show_passkey_login && remembered_user&.passkey_credentials&.exists? || false
    @remembered_passkey_name = display_name_for(remembered_user)
  end

  def mobile_passkey_device?
    request.user_agent.to_s.match?(/Android|iPhone|iPad|iPod|Mobile/i)
  end

  def display_name_for(user)
    return if user.blank?
    return "Carlos Murilo Duarte Novais" if user.email == "carlosmurilonovais@gmail.com"

    user.email
  end
end
