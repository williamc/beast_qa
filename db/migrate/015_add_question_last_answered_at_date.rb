class AddQuestionLastAnsweredAtDate < ActiveRecord::Migration
  class Answer < ActiveRecord::Base; end
  def self.up
    add_column "answers", "replied_at", :datetime
    Answer.update_all 'replied_at = updated_at', 'question_id = id'
  end

  def self.down
    remove_column "answers", "replied_at"
  end
end
