class TweakCategoryIndex < ActiveRecord::Migration
  def self.up
    remove_index :questions, :name => :index_questions_on_sticky_and_replied_at
    add_index :questions, [:category_id, :sticky, :replied_at], :name => :index_questions_on_sticky_and_replied_at
  end

  def self.down
    remove_index :questions, :name => :index_questions_on_sticky_and_replied_at
    add_index :questions, [:sticky, :replied_at], :name => :index_questions_on_sticky_and_replied_at
  end
end
