class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index "answers", ["question_id", "created_at"], :name => "index_answers_on_question_id"
    add_index "users", ["answers_count"], :name => "index_users_on_answers_count"
  end

  def self.down
    remove_index "answers", :name => "index_answers_on_question_id"
    remove_index "users", :name => "index_users_on_answers_count"
  end
end
