class ResetCounterCache < ActiveRecord::Migration
  def self.up
    
    Category.find(:all).each do | category |
      category.questions_count=category.questions.count
      category.answers_count=category.answers.count
      category.save
    end
    
    Answer.find(:all).each do | i |
      i.answers_count=i.answers.count
      i.save
    end

    User.find(:all).each do | i |
      i.answers_count=i.answers.count
      i.save
    end
  end

  def self.down
  end
end
