class FixCategoryAnswersCount < ActiveRecord::Migration
  class Answer  < ActiveRecord::Base; end
  class Category < ActiveRecord::Base; end
  def self.up
    Answer.count(:id, :group => :category_id).each do |category_id, count|
      Category.update_all ['answers_count = ?', count], ['id = ?', category_id]
    end
  end

  def self.down
  end
end
