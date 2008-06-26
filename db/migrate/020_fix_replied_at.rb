class FixRepliedAt < ActiveRecord::Migration
  def self.up
    execute 'update posts set replied_at=created_at where replied_at is null and id=question_id'
  end

  def self.down
  end
end
