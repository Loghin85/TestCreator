class ApplicationController < ActionController::Base
	include SessionsHelper
	protect_from_forgery
	before_action :logged_in_user
	before_action :admin_user
	
	# Method to call when a user is not supposed to access a page
	def naughty_user
		flash[:danger] = "You are not allowed to access that page."
		redirect_to root_url
	end
end
