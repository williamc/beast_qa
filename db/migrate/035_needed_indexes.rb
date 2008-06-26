class NeededIndexes < ActiveRecord::Migration
  def self.up
    add_index :answers, :user_id
    add_index :answers, :question_id
    add_index :questions, :category_id
  end

  def self.down
    remove_index :answers, :user_id
    remove_index :answers, :question_id
    remove_index :questions, :category_id
  end
end
