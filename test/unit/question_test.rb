require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase
  all_fixtures

  def test_save_should_update_post_id_for_posts_belonging_to_question
    # checking current category_id's are in sync
    question = questions(:pdi)
    post_categories = lambda do
      question.posts.each { |p| assert_equal p.category_id, question.category_id }
    end
    post_categories.call
    assert_equal categories(:rails).id, question.category_id
    
    # updating category_id
    question.update_attribute :category_id, categories(:comics).id
    assert_equal categories(:comics).id, question.reload.category_id
    post_categories.call
  end

  def test_knows_last_post
    assert_equal posts(:pdi_rebuttal), questions(:pdi).last_post
  end

  def test_counts_are_valid
    assert_equal categories(:rails).questions_count, categories(:rails).questions.size
    assert_equal categories(:comics).questions_count, categories(:comics).questions.size
  end
  
  def test_moving_question_to_different_category_preserves_counts
    rails = lambda { [categories(:rails).questions_count, categories(:rails).posts_count] }
    comics = lambda { [categories(:comics).questions_count, categories(:comics).posts_count] }
    old_rails = rails.call
    old_comics = comics.call
    
    questions(:il8n).posts.each { |post| post.category==categories(:rails) }
    
    @question=questions(:il8n)
    @question.category=categories(:comics)
    @question.save!
    
    questions(:il8n).posts.each { |post| post.category==categories(:comics) }
    
    categories(:rails).reload
    categories(:comics).reload
  
    assert_equal old_rails.collect { |n| n - 1}, rails.call
    assert_equal old_comics.collect { |n| n + 1}, rails.call
  end
  
  def test_voices
    @pdi=questions(:pdi)
    post=@pdi.posts.build(:body => "test")
    post.user_id=3
    post.save!
    post=@pdi.posts.build(:body => "test")
    post.user_id=4
    post.save!
    @pdi.reload
    assert_equal 5, @pdi.posts.count
    assert_equal [1,2,3,4], @pdi.voices.map(&:id).sort
    assert_equal 4, @pdi.voices.size
  end
  
  def test_should_require_title_user_and_category
    t=Question.new
    t.valid?
    assert t.errors.on(:title)
    assert t.errors.on(:user)
    assert t.errors.on(:category)
    assert ! t.save
    t.user  = users(:aaron)
    t.title = "happy life"
    t.category = categories(:rails)
    assert t.save
    assert_nil t.errors.on(:title)
    assert_nil t.errors.on(:user)
    assert_nil t.errors.on(:category)
  end

  def test_should_add_to_user_counter_cache
    assert_difference Post, :count do
      assert_difference users(:sam).posts, :count do
        p = questions(:pdi).posts.build(:body => "I'll do it")
        p.user = users(:sam)
        p.save
      end
    end
  end
 
  def test_should_create_question
    counts = lambda { [Question.count, categories(:rails).questions_count] }
    old = counts.call
    t = categories(:rails).questions.build(:title => 'foo')
    t.user = users(:aaron)
    assert_valid t
    t.save
    assert_equal 0, t.sticky
    [categories(:rails), users(:aaron)].each &:reload
    assert_equal old.collect { |n| n + 1}, counts.call
  end
  
  def test_should_delete_question
    counts = lambda { [Question.count, Post.count, categories(:rails).questions_count, categories(:rails).posts_count,  users(:sam).posts_count] }
    old = counts.call
    questions(:ponies).destroy
    [categories(:rails), users(:sam)].each &:reload
    assert_equal old.collect { |n| n - 1}, counts.call
  end
  
  def test_hits
    hits=questions(:pdi).views
    questions(:pdi).hit!
    questions(:pdi).hit!
    assert_equal(hits+2, questions(:pdi).reload.hits)
    assert_equal(questions(:pdi).hits, questions(:pdi).views)
  end
  
  def test_replied_at_set
    t=Question.new
    t.user=users(:aaron)
    t.title = "happy life"
    t.category = categories(:rails)
    assert t.save
    assert_not_nil t.replied_at
    assert t.replied_at <= Time.now.utc
    assert_in_delta t.replied_at, Time.now.utc, 5.seconds
  end
  
  def test_doesnt_change_replied_at_on_save
    t=Question.find(:first)
    old=t.replied_at
    assert t.save
    assert_equal old, t.replied_at
  end
  
  def test_should_return_correct_last_page
    t = Question.new
    t.posts_count = 51
    assert_equal 3, t.last_page
    t.posts_count = 26
    assert_equal 2, t.last_page
    t.posts_count = 1
    assert_equal 1, t.last_page
    t.posts_count = 0
    assert_equal 1, t.last_page
  end
end
