ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
	
  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end
end

class ActionDispatch::IntegrationTest
  
  # Log in as a particular user.
  def log_in_as(user, remember_me: '1')
    post login_path, params: { session: { email: user.Email,
                                          password: 'Pass1234',
                                          remember_me: remember_me } }
										  
  end
	
end
