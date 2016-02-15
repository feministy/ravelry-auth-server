helpers do
  def current_user?
    !session[:uid].nil?
  end

  def set_user
    info = session[:info]
    @user = { username: info['nickname'], first_name: info['first_name'], logged_in: current_user? }
  end

  def clear_session
    session[:info] = nil
    session[:uid] = nil
    session[:consumer] = nil
    session[:token] = nil
    @user = nil
  end

  def set_session
    oauth_data = request.env['omniauth.auth']['extra']['access_token']
    session[:uid] = request.env['omniauth.auth']['uid']
    session[:info] = request.env['omniauth.auth']['info']
    session[:consumer] = {
      secret: oauth_data.consumer.secret,
      key: oauth_data.consumer.key
    }
    session[:token] = {
      token: oauth_data.token,
      secret: oauth_data.secret
    }
  end

  def check_session
    valid = { session: true }
    invalid = { session: false }
    if current_user?
      json valid
    else
      json invalid
    end
  end
end