class SessionsController < ApplicationController
  skip_before_action :logged_in_user, only: [:new, :create]
  skip_before_action :admin_user, only: [:new, :create, :destroy]
  def new
  end
  def create
	  user = User.find_by(Email: params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])
		if user.activated?
			log_in user
			flash[:info] = 'Logged in successfully'
			if params[:session][:remember_me] == "1"
				remember(user)
			else
				forget(user)
			end
			redirect_to root_url
		  else
			message  = "Account not activated. "
			message += "Check your email for the activation link."
			flash[:warning] = message
			render 'new'
		  end
      else
        # Create an error message.
        flash[:info] = 'Invalid email/password combination' # Not quite right!
        render 'new'
      end
    end

    def destroy
       log_out if logged_in?
       redirect_to root_url
  end
end
