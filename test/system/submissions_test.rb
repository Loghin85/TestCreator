require "application_system_test_case"

class SubmissionsTest < ApplicationSystemTestCase
  setup do
    @submission = submissions(:one)
  end

  test "visiting the index" do
    visit submissions_url
    assert_selector "h1", text: "Submissions"
  end

  test "creating a Submission" do
    visit submissions_url
    click_on "New Submission"

    fill_in "Answers", with: @submission.Answers
    fill_in "Scores", with: @submission.Scores
    fill_in "Submittedat", with: @submission.SubmittedAt
    fill_in "Assessment", with: @submission.assessment_id
    fill_in "Useremail", with: @submission.userEmail
    fill_in "Userid", with: @submission.userId
    click_on "Create Submission"

    assert_text "Submission was successfully created"
    click_on "Back"
  end

  test "updating a Submission" do
    visit submissions_url
    click_on "Edit", match: :first

    fill_in "Answers", with: @submission.Answers
    fill_in "Scores", with: @submission.Scores
    fill_in "Submittedat", with: @submission.SubmittedAt
    fill_in "Assessment", with: @submission.assessment_id
    fill_in "Useremail", with: @submission.userEmail
    fill_in "Userid", with: @submission.userId
    click_on "Update Submission"

    assert_text "Submission was successfully updated"
    click_on "Back"
  end

  test "destroying a Submission" do
    visit submissions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Submission was successfully destroyed"
  end
end
