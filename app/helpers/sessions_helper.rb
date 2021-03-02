module SessionsHelper
# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
def remember(user)
   user.remember
   cookies.permanent.signed[:user_id] = user.id
   cookies.permanent[:remember_token] = user.remember_token
end  
  
  # Returns the current logged-in user (if any).
 def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
 end

 # Returns true if the user is logged in, false otherwise.
 def logged_in?
   !current_user.nil?
 end
 
 # Returns true if the current logged user is admin, false otherwise.
 def admin?
	logged_in? && current_user.Privilege=="Admin"
 end

 # Returns true if the current user is the user given in param.
 def current_user?(user)
     user == current_user
 end 
 
 # Confirms a logged-in user.
   def logged_in_user
      unless logged_in?
         flash[:danger] = "Please log in."
         redirect_to login_url
      end
   end
 
 # Confirms correct user.
   def correct_user
      @user = User.find(params[:id])
	  unless current_user?(@user) || current_user.admin?
	     flash[:danger] = "You can't do that you naughty user..."
	     redirect_to root_url 
	  end
   end
 
 # Confirms user admin.
   def admin_user
	  unless admin?
		flash[:danger] = "Please log in as Admin to acces this page"
		redirect_to login_url
      end
   end

	# Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
 
 def redirect_back_or(default)
  redirect_to(session[:return_to] || default)
  session.delete(:return_to)
end
 
 # Logs out the current user.
  def log_out
	forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
