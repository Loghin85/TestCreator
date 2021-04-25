class Submission < ApplicationRecord
	belongs_to :assessment
	validates :assessment_id, presence: true
	validates :userId, uniqueness: { case_sensitive: true }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :userEmail, length: { maximum: 75 },
												format: { with: VALID_EMAIL_REGEX }
	validates :Score, :Scores, :Answers, :SubmittedAt, :Duration, presence: true
	
  # Sends activation email.
  def send_submission_results(assessment, questions, creator)
    SubmissionMailer.assessment_results(self, assessment, questions, creator).deliver_now
  end
	
end
