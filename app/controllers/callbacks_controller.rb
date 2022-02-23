# frozen_string_literal: true

class CallbacksController < Devise::OmniauthCallbacksController

  def yandex
    @user = User.find_for_oauth(auth(request.env['omniauth.auth'] || params))

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'YANDEX') if is_navigational_format?
    end
  end

  def auth(params)
    email    = params.dig(:user, :email).present? ? params.dig(:user, :email) : params.dig(:info, :email)
    uid      = params[:uid]      || params.dig(:user, :uid)
    provider = params[:provider] || params.dig(:user, :provider)
    password = Devise.friendly_token[0, 20]
    {
        uid:      uid,
        provider: provider,
        email:    email || "#{params.dig(:user, :phone) || uid}@#{provider}",
        token:    params.dig(:credentials, :token)      || params[:token],
        name:     params.dig(:extra, :raw_info, :login) || params.dig(:user, :name),
        phone:    params.dig(:user, :phone),
        password: password,
        password_confirmation: password
    }
  end
end
