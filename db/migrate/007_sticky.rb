class Sticky < ActiveRecord::Migration
  def self.up
    add_column "answers", "sticky", :boolean, :default => false
  end

  def self.down
    remove_column "answers", "sticky"
  end
end
