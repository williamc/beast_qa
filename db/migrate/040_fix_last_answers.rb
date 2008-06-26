class FixLastAnswers < ActiveRecord::Migration
  class Question < ActiveRecord::Base
    has_many :answers, :order => 'answers.created_at'
  end
  class Answer  < ActiveRecord::Base; end

  def self.up
    Question.find(:all, :include => :answers).each do |question|
      answer = question.last_answer
      Question.transaction do
        Question.update_all(['replied_at = ?, replied_by = ?, last_answer_id = ?', 
          answer.created_at, answer.user_id, answer.id], ['id = ?', question.id]) if answer
      end
    end
  end

  def self.down
  end
end
