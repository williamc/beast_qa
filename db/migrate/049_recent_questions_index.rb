class RecentQuestionsIndex < ActiveRecord::Migration
  def self.up
    # this index needed for when we get recent answers only and bypass the sticky bit
    # in that case the databaes would be unable to use the existing index
    add_index :questions, [:category_id, :replied_at]
  end

  def self.down
    remove_index :questions, [:category_id, :replied_at]
  end
end
