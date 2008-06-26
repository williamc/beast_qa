class RenamePostToQuestion < ActiveRecord::Migration
  def self.up
    rename_column :posts, :post_id, :question_id
  end

  def self.down
    rename_column :posts, :question_id, :post_id
  end
end
