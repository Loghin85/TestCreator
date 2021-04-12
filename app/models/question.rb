class Question < ApplicationRecord
	belongs_to :assessment
	validates :Title, :Type, :Text, :Answer, :Points, :Feedback, presence: true
end
