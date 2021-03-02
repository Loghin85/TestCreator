class ApplicationController < ActionController::Base
	include SessionsHelper
	protect_from_forgery
	before_action :logged_in_user
	before_action :admin_user
	
	def naughty_user
		flash[:danger] = "You can't do that you naughty user..."
		redirect_to root_url
	end
end
