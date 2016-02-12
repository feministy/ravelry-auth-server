helpers do
  def current_user
    !session[:uid].nil?
  end

  def set_user
    info = session[:info]
    @user = { username: info['nickname'], first_name: info['first_name'], logged_in: current_user }
  end

  def clear_session
    session[:info] = nil
    session[:uid] = nil
    @user = nil
  end

  def set_session
    session[:uid] = request.env['omniauth.auth']['uid']
    session[:info] = request.env['omniauth.auth']['info']
  end

  def check_session
    valid = { session: true }
    invalid = { session: false }
    if current_user
      json valid
    else
      json invalid
    end
  end
end