class Question < ApplicationRecord
validates :Title, :Type, :Text, :Answer, :Points, :Feedback, presence: true
end
