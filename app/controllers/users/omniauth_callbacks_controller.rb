class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    oauth_service = OauthService.where(:provider => auth.provider, :uid => auth.uid).first

    if oauth_service
      user = oauth_service.user
      oauth_service.update(
        :expires_at => Time.at(auth.credentials.expires_at),
        :access_token => auth.credentials.token
      )
    else
      pass = Devise.friendly_token[0, 20]
      user = User.create(
        :email => auth.info.email,
        :password => pass,
        :password_confirmation => pass
      )

      user.oauth_services.create(
        :provider => auth.provider,
        :uid => auth.uid,
        :expires_at => Time.at(auth.credentials.expires_at),
        :access_token => auth.credentials.token
      )
    end

    sign_in_and_redirect user, :event => :authentication
    set_flash_message :notice, :success, :kind => "Facebook"
  end

  private

  def auth
    request.env["omniauth.auth"]
  end
end
