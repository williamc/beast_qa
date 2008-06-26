class ReAddAnswersCategoryId < ActiveRecord::Migration
  class Question < ActiveRecord::Base; end
  class Answer  < ActiveRecord::Base; end
  def self.up
    add_column "answers", "category_id", :integer
    Question.find(:all, :select => 'id, category_id').each do |t|
      Answer.update_all ['category_id = ?', t.category_id], ['question_id = ?', t.id]
    end
  end

  def self.down
    remove_column "answers", "category_id"
  end
end
