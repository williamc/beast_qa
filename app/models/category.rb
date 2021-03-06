class Category < ActiveRecord::Base
  acts_as_list

  validates_presence_of :name

  has_many :moderatorships, :dependent => :delete_all
  has_many :moderators, :through => :moderatorships, :source => :user, :order => "#{User.table_name}.login"

  has_many :questions, :order => 'sticky desc, replied_at desc', :dependent => :delete_all
  has_one  :recent_question, :class_name => 'Question', :order => 'sticky desc, replied_at desc'

  # this is used to see if a category is "fresh"... we can't use questions because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_questions, :class_name => 'Question', :order => 'replied_at DESC'
  has_one  :recent_question,  :class_name => 'Question', :order => 'replied_at DESC'

  has_many :answers,     :order => "#{Answer.table_name}.created_at DESC", :dependent => :delete_all
  has_one  :recent_answer, :order => "#{Answer.table_name}.created_at DESC", :class_name => 'Answer'

  format_attribute :description
  
  # retrieves categories ordered by position
  def self.find_ordered(options = {})
    find :all, options.update(:order => 'position')
  end
end
