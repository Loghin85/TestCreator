require "test_helper"

class AssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assessment = assessments(:one)
    @user = users(:user)
		@assessment.user_id = @user.id
		@assessment.save
  end
	
	test "should not get index(not logged in)" do
	get assessments_url
    assert_redirected_to login_url
  end
  
  test "should get index(user)" do
	log_in_as @user
	get assessments_url
    assert_response :ok
  end
	
	test "should not get new(not logged in)" do
    get new_assessment_url
    assert_redirected_to login_url
  end
  
  test "should get new(user)" do
		log_in_as @user
			get new_assessment_url
			assert_response :ok
  end

  test "should not create assessment(not logged in)" do
    assert_difference('Assessment.count', 0) do
      post assessments_url, params: { assessment: {user_id: @user.id, Name: "Assessment 2", Description: @assessment.Description, Duration: @assessment.Duration, BeginAt: @assessment. BeginAt, EndAt: @assessment.EndAt}, offset: 0 }
    end
    assert_redirected_to login_url
  end

  test "should create assessment(user)" do
		log_in_as @user
    assert_difference('Assessment.count') do
      post assessments_url, params: { assessment: {user_id: @user.id, Name: "Assessment 2", Description: @assessment.Description, Duration: @assessment.Duration, BeginAt: @assessment. BeginAt, EndAt: @assessment.EndAt}, offset: 0 }
    end
    assert_redirected_to assessment_url(Assessment.last)
  end
  
  test "should not show assessment(not logged in)" do
    get assessment_url(@assessment)
    assert_redirected_to login_url
  end
  
  test "should show assessment(user)" do
    log_in_as @user
		get assessment_url(@assessment)
    assert_response :ok
  end
  
  test "should not get edit(not logged in)" do
    get edit_assessment_url(@assessment)
    assert_redirected_to login_url
  end
  
  test "should get edit(user)" do
	log_in_as @user
    get edit_assessment_url(@assessment)
    assert_response :ok
  end

  test "should not update assessment(not logged in)" do
    patch assessment_url(@assessment), params: { assessment: {user_id: @user.id, Name: @assessment.Name, Description: @assessment.Description, Duration: @assessment.Duration, BeginAt: @assessment. BeginAt, EndAt: @assessment.EndAt}, offset: 0 }
    assert_redirected_to login_url
  end

  test "should update assessment(user)" do
		log_in_as @user
    patch assessment_url(@assessment), params: { assessment: {user_id: @user.id, Name: @assessment.Name, Description: @assessment.Description, Duration: @assessment.Duration, BeginAt: @assessment. BeginAt, EndAt: @assessment.EndAt}, offset: 0 }
    assert_redirected_to assessment_url(@assessment)
  end

  test "should not destroy assessment(not logger in)" do
    assert_difference('Assessment.count', 0) do
      delete assessment_url(@assessment)
    end
    assert_redirected_to login_url
  end
  
  test "should destroy assessment(user)" do
	log_in_as @user
    assert_difference('Assessment.count', -1) do
      delete assessment_url(@assessment)
    end
    assert_redirected_to assessments_url
  end
end
