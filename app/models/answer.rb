class Answer < ActiveRecord::Base
  def self.per_page() 25 end

  belongs_to :category
  belongs_to :user
  belongs_to :question

  format_attribute :body
  before_create { |r| r.category_id = r.question.category_id }
  after_create  :update_cached_fields
  after_destroy :update_cached_fields

  validates_presence_of :user_id, :body, :question
  attr_accessible :body
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(category_id))
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :question_title << :category_name
    super
  end
  
  protected
    # using count isn't ideal but it gives us correct caches each time
    def update_cached_fields
      Category.update_all ['answers_count = ?', Answer.count(:id, :conditions => {:category_id => category_id})], ['id = ?', category_id]
      User.update_answers_count(user_id)
      question.update_cached_answer_fields(self)
    end
end
