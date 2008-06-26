class QuestionsCacheLastRepliedUser < ActiveRecord::Migration
  class Answer < ActiveRecord::Base; end
  class Question < ActiveRecord::Base
    has_many :answers
  end
  def self.up
    add_column "questions", "replied_by", :integer
    add_column "questions", "last_answer_id", :integer
    Question.find(:all).each do |question|
      next if question.answers.count.zero?
      question.replied_by   = question.last_answer.user_id
      question.last_answer_id = question.last_answer.id
      question.save!
    end
  end

  def self.down
    remove_column "questions", "replied_by"
    remove_column "questions", "last_answer_id"
  end
end
