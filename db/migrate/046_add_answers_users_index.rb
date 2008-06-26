class AddAnswersUsersIndex < ActiveRecord::Migration
  def self.up
    remove_index "answers", :name => "index_answers_on_user_id"
    add_index "answers", ["user_id", "created_at"], :name => "index_answers_on_user_id"
  end

  def self.down
    remove_index "answers", :name => "index_answers_on_user_id"
    add_index "answers", ["user_id"], :name => "index_answers_on_user_id"
  end
end
