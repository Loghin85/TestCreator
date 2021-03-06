class PasswordResetsController < ApplicationController
  skip_before_action :logged_in_user
  skip_before_action :admin_user
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
	VALID_PASSWORD_REGEX = /\A(?=.*[a-zA-Z])(?=.*[0-9]).{8,}\Z/
  
  def new
  end
  
  def create
    @user = User.find_by(Email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end
  
  def update
		p !!!params[:user][:password_confirmation].match(params[:user][:password])
		if params[:user][:password].empty?             
      flash.now[:warning] = "Password can't be empty"
      render 'edit'
		elsif !!!params[:user][:password].match(VALID_PASSWORD_REGEX)
			flash.now[:warning] = "The password must be at least 8 characters long and contain at least: one lowercase character, one uppercase character and one number"
      render 'edit'
	  elsif !!!params[:user][:password_confirmation].match(params[:user][:password])
			flash.now[:warning] = "The password confirmation and password must match"
      render 'edit'
    elsif @user.update(user_params)          
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     
    end
  end
  
  private

	def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  
    def get_user
      @user = User.find_by(Email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
	
	# Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
