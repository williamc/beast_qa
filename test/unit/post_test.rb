require File.dirname(__FILE__) + '/../test_helper'

class PostTest < Test::Unit::TestCase
  all_fixtures

  def test_should_select_posts
    assert_equal [posts(:pdi), posts(:pdi_reply), posts(:pdi_rebuttal)], questions(:pdi).posts
  end
  
  def test_should_find_question
    assert_equal questions(:pdi), posts(:pdi_reply).question
  end

  def test_should_require_body_for_post
    p = questions(:pdi).posts.build
    p.valid?
    assert p.errors.on(:body)
  end

  def test_should_create_reply
    counts = lambda { [Post.count, categories(:rails).posts_count, users(:aaron).posts_count, questions(:pdi).posts_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call
    
    p = create_post questions(:pdi), :body => 'blah'
    assert_valid p

    [categories(:rails), users(:aaron), questions(:pdi)].each &:reload
    
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_update_cached_data
    p = create_post questions(:pdi), :body => 'ok, ill get right on it'
    assert_valid p
    questions(:pdi).reload
    assert_equal p.id, questions(:pdi).last_post_id
    assert_equal p.user_id, questions(:pdi).replied_by
    assert_equal p.created_at.to_i, questions(:pdi).replied_at.to_i
  end

  def test_should_delete_last_post_and_fix_question_cached_data
    posts(:pdi_rebuttal).destroy
    assert_equal posts(:pdi_reply), questions(:pdi).last_post
    assert_equal posts(:pdi_reply).user_id, questions(:pdi).replied_by
    assert_equal posts(:pdi_reply).created_at.to_i, questions(:pdi).replied_at.to_i
  end
  
  def test_should_delete_only_remaining_post_and_clear_question
    posts(:sticky).destroy
    assert_raises ActiveRecord::RecordNotFound do
      questions(:sticky)
    end
  end

  def test_should_create_reply_and_set_category_from_question
    p = create_post questions(:pdi), :body => 'blah'
    assert_equal questions(:pdi).category_id, p.category_id
  end

  def test_should_delete_reply
    counts = lambda { [Post.count, categories(:rails).posts_count, users(:sam).posts_count, questions(:pdi).posts_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call
    posts(:pdi_reply).destroy
    [categories(:rails), users(:sam), questions(:pdi)].each &:reload
    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_edit_own_post
    assert posts(:shield).editable_by?(users(:sam))
  end

  def test_should_edit_post_as_admin
    assert posts(:shield).editable_by?(users(:aaron))
  end

  def test_should_edit_post_as_moderator
    assert posts(:pdi).editable_by?(users(:sam))
  end

  def test_should_not_edit_post_in_own_question
    assert !posts(:shield_reply).editable_by?(users(:sam))
  end

  protected
    def create_post(question, options = {})
      returning question.posts.build(options) do |p|
        p.user = users(:aaron)
        p.save
        # post should inherit the category from the question
        assert_equal p.question.category, p.category
      end
    end
end
