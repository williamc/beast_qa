class DeleteEmptyQuestions < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  class Question < ActiveRecord::Base
    has_many :posts
  end
  def self.up
    Question.find(:all).each do |question| 
      question.destroy if question.posts.count.zero?
    end
  end

  def self.down
  end
end
