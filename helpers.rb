helpers do
  def user(user_session)
    { username: user_session[:username], first_name: user_session[:info]['first_name'], token: user_session[:token][:token] }
  end

  def clear_session(username)
    session[username] = nil
    @user = nil
  end

  def set_session
    user_info = request.env['omniauth.auth']['info']
    oauth_data = request.env['omniauth.auth']['extra']['access_token']
    # maybe salt the username key here somehow?
    session[user_info.username] = {
      uid: request.env['omniauth.auth']['uid'],
      info: user_info.username,
      username: user_info.username,
      consumer: {
        secret: oauth_data.consumer.secret,
        key: oauth_data.consumer.key
      },
      token: {
        token: oauth_data.token,
        secret: oauth_data.secret
      }
    }
    user(session[user_info.username])
  end

  def check_session(username, token)
    valid = { session: true }
    invalid = { session: false }
    if session[:username] && session[:username][:token][:token] == token
      json valid
    else
      json invalid
    end
  end
end