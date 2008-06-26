class CreateQuestions < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  class Question < ActiveRecord::Base; end
  def self.up
    create_table :questions do |t|
      t.column "category_id",    :integer
      t.column "user_id",     :integer
      t.column "title",       :string
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
      t.column "hits",        :integer,  :default => 0
      t.column "sticky",      :boolean,  :default => false
      t.column "posts_count", :integer,  :default => 0
      t.column "replied_at",  :datetime
    end
    # find the old questions
    Post.find(:all, :conditions => "id=question_id").each do |old_question|
      question=Question.new
      question.id=old_question.id
      question.attribute_names.each do |prop|
        question.send("#{prop}=", old_question.send(prop))
        question.save!
      end
    end
  end

  def self.down
    drop_table :questions
  end
end
