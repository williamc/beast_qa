class QuestionLocked < ActiveRecord::Migration
  def self.up
    add_column "questions", "locked", :boolean, :default => false
    Question.update_all [ "locked= ? ", false ]
  end

  def self.down
    remove_column "questions", "locked"
  end
end