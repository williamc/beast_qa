class AddHits < ActiveRecord::Migration
  def self.up
    add_column "answers", "hits", :integer, :default => 0 
  end

  def self.down
    remove_column "answers", "hits"
  end
end
