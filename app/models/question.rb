class Question < ActiveRecord::Base
  validates_presence_of :category, :user, :title
  before_create  :set_default_replied_at_and_sticky
  before_update  :check_for_changing_categories
  after_save     :update_category_counter_cache
  before_destroy :update_post_user_counts
  after_destroy  :update_category_counter_cache

  belongs_to :category
  belongs_to :user
  belongs_to :last_post, :class_name => "Post", :foreign_key => 'last_post_id'
  has_many :monitorships
  has_many :monitors, :through => :monitorships, :conditions => ["#{Monitorship.table_name}.active = ?", true], :source => :user, :order => "#{User.table_name}.login"

  has_many :posts,     :order => "#{Post.table_name}.created_at", :dependent => :delete_all
  has_one  :recent_post, :order => "#{Post.table_name}.created_at DESC", :class_name => 'Post'
  
  has_many :voices, :through => :posts, :source => :user, :uniq => true

  belongs_to :replied_by_user, :foreign_key => "replied_by", :class_name => "User"

  attr_accessible :title
  # to help with the create form
  attr_accessor :body
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > Post.per_page end
  
  def last_page
    [(posts_count.to_f / Post.per_page).ceil.to_i, 1].max
  end

  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(category_id))
  end
  
  def update_cached_post_fields(post)
    # these fields are not accessible to mass assignment
    remaining_post = post.frozen? ? recent_post : post
    if remaining_post
      self.class.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?, posts_count = ?', 
        remaining_post.created_at, remaining_post.user_id, remaining_post.id, posts.count], ['id = ?', id])
    else
      self.destroy
    end
  end
  
  protected
    def set_default_replied_at_and_sticky
      self.replied_at = Time.now.utc
      self.sticky   ||= 0
    end

    def set_post_category_id
      Post.update_all ['category_id = ?', category_id], ['question_id = ?', id]
    end

    def check_for_changing_categories
      old = Question.find(id)
      @old_category_id = old.category_id if old.category_id != category_id
      true
    end
    
    # using count isn't ideal but it gives us correct caches each time
    def update_category_counter_cache
      category_conditions = ['questions_count = ?', Question.count(:id, :conditions => {:category_id => category_id})]
      # if the question moved categories
      if !frozen? && @old_category_id && @old_category_id != category_id
        set_post_category_id
        Category.update_all ['questions_count = ?, posts_count = ?', 
          Question.count(:id, :conditions => {:category_id => @old_category_id}),
          Post.count(:id,  :conditions => {:category_id => @old_category_id})], ['id = ?', @old_category_id]
      end
      # if the question moved categories or was deleted
      if frozen? || (@old_category_id && @old_category_id != category_id)
        category_conditions.first << ", posts_count = ?"
        category_conditions       << Post.count(:id, :conditions => {:category_id => category_id})
      end
      @voices.each &:update_posts_count if @voices
      Category.update_all category_conditions, ['id = ?', category_id]
      @old_category_id = @voices = nil
    end
    
    def update_post_user_counts
      @voices = voices.to_a
    end
end
