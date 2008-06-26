class ReAddPostsCategoryId < ActiveRecord::Migration
  class Topic < ActiveRecord::Base; end
  class Post  < ActiveRecord::Base; end
  def self.up
    add_column "posts", "category_id", :integer
    Topic.find(:all, :select => 'id, category_id').each do |t|
      Post.update_all ['category_id = ?', t.category_id], ['topic_id = ?', t.id]
    end
  end

  def self.down
    remove_column "posts", "category_id"
  end
end
