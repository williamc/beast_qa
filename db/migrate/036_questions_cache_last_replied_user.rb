class QuestionsCacheLastRepliedUser < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  class Question < ActiveRecord::Base
    has_many :posts
  end
  def self.up
    add_column "questions", "replied_by", :integer
    add_column "questions", "last_post_id", :integer
    Question.find(:all).each do |question|
      next if question.posts.count.zero?
      question.replied_by   = question.last_post.user_id
      question.last_post_id = question.last_post.id
      question.save!
    end
  end

  def self.down
    remove_column "questions", "replied_by"
    remove_column "questions", "last_post_id"
  end
end
