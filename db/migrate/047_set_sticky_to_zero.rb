class SetStickyToZero < ActiveRecord::Migration
  class Question < ActiveRecord::Base; end
  def self.up
    Question.update_all ['sticky = 0'], ['sticky is null']
  end

  def self.down
  end
end
