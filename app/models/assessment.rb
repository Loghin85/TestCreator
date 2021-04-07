class Assessment < ApplicationRecord
validates :Name, :Description, :Duration, :AvailableFor, :ScheduledAt, presence: true
end
