class ResetCounterCache < ActiveRecord::Migration
  def self.up
    
    Category.find(:all).each do | category |
      category.topics_count=category.topics.count
      category.posts_count=category.posts.count
      category.save
    end
    
    Post.find(:all).each do | i |
      i.posts_count=i.posts.count
      i.save
    end

    User.find(:all).each do | i |
      i.posts_count=i.posts.count
      i.save
    end
  end

  def self.down
  end
end
