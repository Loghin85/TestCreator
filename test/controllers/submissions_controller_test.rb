require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @submission = submissions(:one)
    @assessment = assessments(:one)
    @user = users(:user)
		@assessment.user_id = @user.id
		@assessment.save
		@submission.assessment_id = @assessment.id
		@submission.save
		
  end
	
	test "should get new(not logged in)" do
			get new_submission_url
			assert_response :ok
  end
  
  test "should get new(user)" do
		log_in_as @user
			get new_submission_url
			assert_response :ok
  end

  test "should create submission(not logged in)" do
    assert_difference('Submission.count') do
      post submissions_url, params: { submission: {assessment_id: @submission.assessment_id, userId: 12345, userEmail: @submission.userEmail,  Scores: "Not submitted", Answers: "Not submitted", Score: 0, Duration: 0} }
    end
    assert_redirected_to edit_submission_url(Submission.last, assessment_id: @submission.assessment_id)
  end
	
  test "should create submission(user)" do
		log_in_as @user
    assert_difference('Submission.count') do
      post submissions_url, params: { submission: {assessment_id: @submission.assessment_id, userId: 12345, userEmail: @submission.userEmail,  Scores: "Not submitted", Answers: "Not submitted", Score: 0, Duration: 0} }
    end
    assert_redirected_to edit_submission_url(Submission.last, assessment_id: @submission.assessment_id)
  end
  
  test "should not show submission(not logged in)" do
    get submission_url(@submission)
    assert_redirected_to login_url
  end
  
  test "should show submission(user)" do
    log_in_as @user
		get submission_url(@submission)
    assert_response :ok
  end
  
  test "should get edit(not logged in)" do
    get edit_submission_url(@submission)
    assert_response :ok
  end
  
  test "should get edit(user)" do
	log_in_as @user
    get edit_submission_url(@submission)
    assert_response :ok
  end

  test "should update submission(not logged in)" do
    patch submission_url(@submission), params: { submission: {assessment_id: @submission.assessment_id, userId: 3, userEmail: @submission.userEmail,  Scores: @submission.Scores, Answers: @submission.Answers, Score: @submission.Score, Duration: @submission.Duration, SubmittedAt: @submission.SubmittedAt} }
    assert_redirected_to '/submissions/received'
  end

  test "should update submission (user)" do
    patch submission_url(@submission), params: { submission: {assessment_id: @submission.assessment_id, userId: 2, userEmail: @submission.userEmail,  Scores: @submission.Scores, Answers: @submission.Answers, Score: @submission.Score, Duration: @submission.Duration, SubmittedAt: @submission.SubmittedAt} }
    assert_redirected_to '/submissions/received'
  end

  test "should not destroy submission(not logger in)" do
    assert_difference('Submission.count', 0) do
      delete submission_url(@submission)
    end
    assert_redirected_to login_url
  end
  
  test "should destroy submission(user)" do
	log_in_as @user
    assert_difference('Submission.count', -1) do
      delete submission_url(@submission)
    end
    assert_redirected_to assessments_url
  end
end
