class RemoveUnnecessaryAnswerCategoryId < ActiveRecord::Migration
  def self.up
    remove_column :answers, :category_id
  end

  def self.down
    add_column :answers, :category_id, :integer
  end
end
