class UpdateUserAnswerCounts < ActiveRecord::Migration
  def self.up
    # old and not needed, we only need to know answer count
    remove_column "users", "questions_count"
    # because i think the counts have been off
    User.find(:all).each do | i |
      i.answers_count=i.answers.count
      i.save
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
