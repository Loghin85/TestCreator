class AccountActivationsController < ApplicationController
  skip_before_action :logged_in_user
  skip_before_action :admin_user

  def edit
    user = User.find_by(Email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      redirect_to user, notice: "Account activated!"
    else
      redirect_to root_url, danger: "Invalid activation link"
    end
  end
  
end
