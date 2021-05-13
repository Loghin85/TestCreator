require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question = questions(:one)
    @assessment = assessments(:one)
    @user = users(:user)
		@assessment.user_id = @user.id
		@assessment.save
		@question.assessment_id = @assessment.id
		@question.save
		
  end
	
	test "should not get new(not logged in)" do
    get new_question_url
    assert_redirected_to login_url
  end
  
  test "should get new(user)" do
		log_in_as @user
			get new_question_url, params: {assessment_id: @assessment.id}
			assert_response :ok
  end

  test "should not create question(not logged in)" do
    assert_difference('Question.count', 0) do
      post questions_url, params: { question: {assessment_id: @question.assessment_id, Title: "Question 1", Type: "TF", Text: "<p>text</p>", Points: 10, Feedback: "<p>text</p>"}, Negative: {result: 0}, negValue: -5, Partial: {result: 0}, Contains: {result: 0}, CaseSensitive: {result: 0}, MultiSpaces: {result: 0}, Range: {result: 0}, rangeValue: 0.5, MCQRadios: "A", MCQRadio1: "", MCQRadio2: "", MCQRadio3: "", MCQRadio4: "", MACheckbox1: "", MACheckbox1Credit: 0, MACheckbox2: "", MACheckbox2Credit: 0, MACheckbox3: "", MACheckbox3Credit: 0, MACheckbox4: "", MACheckbox4Credit: 0, FTBAnswer: "", TFRadio: "True", FRMAnswer: "", REGAnswer: ""}
    end
    assert_redirected_to login_url
  end
	
  test "should create question(user)" do
		log_in_as @user
    assert_difference('Question.count') do
      post questions_url, params: { question: {assessment_id: @question.assessment_id, Title: "Question 1", Type: "TF", Text: "<p>text</p>", Points: 10, Feedback: "<p>text</p>"}, Negative: {result: 0}, negValue: -5, Partial: {result: 0}, Contains: {result: 0}, CaseSensitive: {result: 0}, MultiSpaces: {result: 0}, Range: {result: 0}, rangeValue: 0.5, MCQRadios: "A", MCQRadio1: "", MCQRadio2: "", MCQRadio3: "", MCQRadio4: "", MACheckbox1: "", MACheckbox1Credit: 0, MACheckbox2: "", MACheckbox2Credit: 0, MACheckbox3: "", MACheckbox3Credit: 0, MACheckbox4: "", MACheckbox4Credit: 0, FTBAnswer: "", TFRadio: "True", FRMAnswer: "", REGAnswer: ""}
    end
    assert_redirected_to question_url(Question.last)
  end
  
  test "should not show question(not logged in)" do
    get question_url(@question)
    assert_redirected_to login_url
  end
  
  test "should show question(user)" do
    log_in_as @user
		get question_url(@question)
    assert_response :ok
  end
  test "should not get edit(not logged in)" do
    get edit_question_url(@question)
    assert_redirected_to login_url
  end
  
  test "should get edit(user)" do
	log_in_as @user
    get edit_question_url(@question)
    assert_response :ok
  end

  test "should not update question(not logged in)" do
    patch question_url(@question), params: { question: {assessment_id: @question.assessment_id, Title: "Question 1", Type: "TF", Text: "<p>text</p>", Points: 10, Feedback: "<p>text</p>"}, Negative: {result: 0}, negValue: -5, Partial: {result: 0}, Contains: {result: 0}, CaseSensitive: {result: 0}, MultiSpaces: {result: 0}, Range: {result: 0}, rangeValue: 0.5, MCQRadios: "A", MCQRadio1: "", MCQRadio2: "", MCQRadio3: "", MCQRadio4: "", MACheckbox1: "", MACheckbox1Credit: 0, MACheckbox2: "", MACheckbox2Credit: 0, MACheckbox3: "", MACheckbox3Credit: 0, MACheckbox4: "", MACheckbox4Credit: 0, FTBAnswer: "", TFRadio: "True", FRMAnswer: "", REGAnswer: ""}
    assert_redirected_to login_url
  end

  test "should update question(user)" do
	log_in_as @user
    patch question_url(@question), params: { question: {assessment_id: @question.assessment_id, Title: "Question 1", Type: "TF", Text: "<p>text</p>", Points: 10, Feedback: "<p>text</p>"}, Negative: {result: 0}, negValue: -5, Partial: {result: 0}, Contains: {result: 0}, CaseSensitive: {result: 0}, MultiSpaces: {result: 0}, Range: {result: 0}, rangeValue: 0.5, MCQRadios: "A", MCQRadio1: "", MCQRadio2: "", MCQRadio3: "", MCQRadio4: "", MACheckbox1: "", MACheckbox1Credit: 0, MACheckbox2: "", MACheckbox2Credit: 0, MACheckbox3: "", MACheckbox3Credit: 0, MACheckbox4: "", MACheckbox4Credit: 0, FTBAnswer: "", TFRadio: "True", FRMAnswer: "", REGAnswer: ""}
    assert_redirected_to question_url(@question)
  end

  test "should not destroy question(not logger in)" do
    assert_difference('Question.count', 0) do
      delete question_url(@question)
    end
    assert_redirected_to login_url
  end
  
  test "should destroy question(user)" do
	log_in_as @user
    assert_difference('Question.count', -1) do
      delete question_url(@question)
    end
    assert_redirected_to assessments_url
  end
end
