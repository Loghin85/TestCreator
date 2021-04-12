class Assessment < ApplicationRecord
	belongs_to :user
	validates :user_id, :Name, :Description, :Duration, :BeginAt, :EndAt, presence: true
end
