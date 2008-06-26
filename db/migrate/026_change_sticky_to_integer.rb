class ChangeStickyToInteger < ActiveRecord::Migration
  class Question < ActiveRecord::Base; end
  def self.up
    sticky_questions = Question.find_all_by_sticky(true).collect &:id
    change_column :questions, :sticky, :integer, :default => 0
    Question.update_all 'sticky=1', ['id in (?)', sticky_questions]
  end

  def self.down
    change_column :questions, :sticky, :boolean, :default => false
  end
end
