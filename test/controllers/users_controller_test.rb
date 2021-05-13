require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
  end

  test "should not get index(not logged in)" do
	get users_url
    assert_redirected_to login_url
  end
  
  test "should not get index(user)" do
	log_in_as @user
	get users_url
    assert_redirected_to login_url
  end

  test "should get new(not logged in)" do
    get new_user_url
    assert_response :ok
  end
  
  test "should get new(user)" do
		log_in_as @user
			get new_user_url
			assert_response :ok
  end

  test "should create user" do
    assert_difference('User.count', 1) do
      post users_url, params: { user: { Email: "email@email.com", Fname: "-", Lname: "-", password: "Pass1234", password_confirmation: "Pass1234"} }
    end
    assert_redirected_to root_url
  end

  test "should not show user(not logged in)" do
		get user_url(@user)
    assert_redirected_to login_url
  end
  
  test "should show user(user)" do
		log_in_as @user
		get user_url(@user)
    assert_response :ok
  end
  
  test "should not get edit(not logged in)" do
    get edit_user_path(@user)
    assert_redirected_to login_url
  end
  
  test "should get edit(user)" do
		log_in_as @user
		get edit_user_path(@user)
    assert_response :ok
  end

  test "should not update user(not logged in)" do
	patch user_url(@user), params: { user: {Email: "email@email.com", Fname: "Userr", Lname: "-"} }
    assert_redirected_to login_url
  end
  
  test "should update user(user)" do
    log_in_as @user
	patch user_url(@user), params: { user: {Email: "email@email.com", Fname: "Userr", Lname: "-"} }
    assert_redirected_to user_url(@user)
  end

  test "should not destroy user(not logged in)" do
    assert_difference('User.count', 0) do
      delete user_url(@user)
    end

    assert_redirected_to login_url
  end
  
  test "should destroy user(user)" do
	log_in_as @user
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to root_url
  end
end
