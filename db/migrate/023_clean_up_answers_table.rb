class CleanUpAnswersTable < ActiveRecord::Migration
  def self.up
    remove_column "answers", "title"
    remove_column "answers", "hits"
    remove_column "answers", "sticky"
    remove_column "answers", "answers_count"
    remove_column "answers", "replied_at"
  end

  def self.down
  end
end
