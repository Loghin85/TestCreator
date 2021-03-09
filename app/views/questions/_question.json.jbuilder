json.extract! question, :id, :AssessmentId, :Title, :Text, :Feedback, :Type, :created_at, :updated_at
json.url question_url(question, format: :json)
