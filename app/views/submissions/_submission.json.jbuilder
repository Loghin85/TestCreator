json.extract! submission, :id, :assessment_id, :userId, :userEmail, :Scores, :Answers, :SubmittedAt, :created_at, :updated_at
json.url submission_url(submission, format: :json)
