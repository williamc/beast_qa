class IndexHappy < ActiveRecord::Migration
  def self.up
    remove_index :answers, :name => :index_answers_on_question_id
    add_index :answers, [:category_id, :created_at], :name => :index_answers_on_category_id
    add_index :users, :last_seen_at, :name => :index_users_on_last_seen_at
    add_index :moderatorships, :category_id, :name => :index_moderatorships_on_category_id
  end

  def self.down
    remove_index :answers, :name => :index_answers_on_category_id
    remove_index :users, :name => :index_users_on_last_seen_at
    remove_index :moderatorships, :name => :index_moderatorships_on_category_id
    add_index :answers, [:question_id, :created_at], :name => :index_answers_on_question_id
  end
end
