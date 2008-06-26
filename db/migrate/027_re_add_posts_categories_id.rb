class ReAddPostsCategoryId < ActiveRecord::Migration
  class Question < ActiveRecord::Base; end
  class Post  < ActiveRecord::Base; end
  def self.up
    add_column "posts", "category_id", :integer
    Question.find(:all, :select => 'id, category_id').each do |t|
      Post.update_all ['category_id = ?', t.category_id], ['question_id = ?', t.id]
    end
  end

  def self.down
    remove_column "posts", "category_id"
  end
end
