class Assessment < ApplicationRecord
	belongs_to :user
	validates :user_id, :Name, :Description, :Duration, :BeginAt, :EndAt, presence: true
	has_many :question, dependent: :delete_all
end
