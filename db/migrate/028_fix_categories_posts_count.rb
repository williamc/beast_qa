class FixCategoryPostsCount < ActiveRecord::Migration
  class Post  < ActiveRecord::Base; end
  class Category < ActiveRecord::Base; end
  def self.up
    Post.count(:id, :group => :category_id).each do |category_id, count|
      Category.update_all ['posts_count = ?', count], ['id = ?', category_id]
    end
  end

  def self.down
  end
end
