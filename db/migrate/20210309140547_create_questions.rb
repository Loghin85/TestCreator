class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.integer :AssessmentId
      t.string :Title
      t.string :Text
      t.string :Feedback
      t.string :Type

      t.timestamps
    end
  end
end
