class AddCounterCaches < ActiveRecord::Migration
  def self.up
    add_column "users", "questions_count",  :integer, :default => 0
    add_column "categories", "questions_count", :integer, :default => 0
    add_column "categories", "answers_count",  :integer, :default => 0
    add_column "answers", "answers_count",   :integer, :default => 0
  end

  def self.down
    remove_column "users", "questions_count"
    remove_column "categories", "questions_count"
    remove_column "categories", "answers_count"
    remove_column "answers", "answers_count"
  end
end
