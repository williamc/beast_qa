class FixLastPosts < ActiveRecord::Migration
  class Question < ActiveRecord::Base
    has_many :posts, :order => 'posts.created_at'
  end
  class Post  < ActiveRecord::Base; end

  def self.up
    Question.find(:all, :include => :posts).each do |question|
      post = question.last_post
      Question.transaction do
        Question.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', 
          post.created_at, post.user_id, post.id], ['id = ?', question.id]) if post
      end
    end
  end

  def self.down
  end
end
