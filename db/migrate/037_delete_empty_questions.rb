class DeleteEmptyQuestions < ActiveRecord::Migration
  class Answer < ActiveRecord::Base; end
  class Question < ActiveRecord::Base
    has_many :answers
  end
  def self.up
    Question.find(:all).each do |question| 
      question.destroy if question.answers.count.zero?
    end
  end

  def self.down
  end
end
