class QuestionIndex < ActiveRecord::Migration
  def self.up
    add_index :questions, [:sticky, :replied_at], :name => :index_questions_on_sticky_and_replied_at
  end

  def self.down
    remove_index :questions, :name => :index_questions_on_sticky_and_replied_at
  end
end
