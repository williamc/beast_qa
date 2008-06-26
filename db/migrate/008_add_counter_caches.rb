class AddCounterCaches < ActiveRecord::Migration
  def self.up
    add_column "users", "questions_count",  :integer, :default => 0
    add_column "categories", "questions_count", :integer, :default => 0
    add_column "categories", "posts_count",  :integer, :default => 0
    add_column "posts", "posts_count",   :integer, :default => 0
  end

  def self.down
    remove_column "users", "questions_count"
    remove_column "categories", "questions_count"
    remove_column "categories", "posts_count"
    remove_column "posts", "posts_count"
  end
end
