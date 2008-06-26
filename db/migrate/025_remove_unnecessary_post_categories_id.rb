class RemoveUnnecessaryPostCategoryId < ActiveRecord::Migration
  def self.up
    remove_column :posts, :category_id
  end

  def self.down
    add_column :posts, :category_id, :integer
  end
end
