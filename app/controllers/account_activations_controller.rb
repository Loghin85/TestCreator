class AccountActivationsController < ApplicationController
  skip_before_action :logged_in_user
  skip_before_action :admin_user
	
	# prepares data for account activation process
  def edit
    user = User.find_by(Email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
  
end
