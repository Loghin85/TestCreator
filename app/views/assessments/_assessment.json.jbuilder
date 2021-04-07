json.extract! assessment, :id, :UserId, :Name, :Description, :Duration, :ScheduledAt, :created_at, :updated_at
json.url assessment_url(assessment, format: :json)
