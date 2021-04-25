class SubmissionMailer < ApplicationMailer	
	
  def assessment_results( submission, assessment, questions, creator)
		@assessment = assessment
		@questions = questions
		@submission = submission
		@creator = creator
    mail to: submission.userEmail, subject: "Assessment results"
  end
	
  def assessment_feedback( submission, text, creator, assessment)
		@text = text
		@submission = submission
		@creator = creator
		@assessment = assessment
    mail to: submission.userEmail, subject: "Assessment feedback"
  end
	
end
