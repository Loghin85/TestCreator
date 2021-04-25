class SubmissionMailer < ApplicationMailer	
	
  def assessment_results( submission, assessment, questions, creator)
		@assessment = assessment
		@questions = questions
		@submission = submission
		@creator = creator
    mail to: submission.userEmail, subject: "Assessment results"
  end
	
end
