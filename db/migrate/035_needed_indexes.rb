class NeededIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :user_id
    add_index :posts, :question_id
    add_index :questions, :category_id
  end

  def self.down
    remove_index :posts, :user_id
    remove_index :posts, :question_id
    remove_index :questions, :category_id
  end
end
