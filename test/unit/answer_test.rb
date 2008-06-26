require File.dirname(__FILE__) + '/../test_helper'

class AnswerTest < Test::Unit::TestCase
  all_fixtures

  def test_should_select_answers
    assert_equal [answers(:pdi), answers(:pdi_reply), answers(:pdi_rebuttal)], questions(:pdi).answers
  end
  
  def test_should_find_question
    assert_equal questions(:pdi), answers(:pdi_reply).question
  end

  def test_should_require_body_for_answer
    p = questions(:pdi).answers.build
    p.valid?
    assert p.errors.on(:body)
  end

  def test_should_create_reply
    counts = lambda { [Answer.count, categories(:rails).answers_count, users(:aaron).answers_count, questions(:pdi).answers_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call
    
    p = create_answer questions(:pdi), :body => 'blah'
    assert_valid p

    [categories(:rails), users(:aaron), questions(:pdi)].each &:reload
    
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_update_cached_data
    p = create_answer questions(:pdi), :body => 'ok, ill get right on it'
    assert_valid p
    questions(:pdi).reload
    assert_equal p.id, questions(:pdi).last_answer_id
    assert_equal p.user_id, questions(:pdi).replied_by
    assert_equal p.created_at.to_i, questions(:pdi).replied_at.to_i
  end

  def test_should_delete_last_answer_and_fix_question_cached_data
    answers(:pdi_rebuttal).destroy
    assert_equal answers(:pdi_reply), questions(:pdi).last_answer
    assert_equal answers(:pdi_reply).user_id, questions(:pdi).replied_by
    assert_equal answers(:pdi_reply).created_at.to_i, questions(:pdi).replied_at.to_i
  end
  
  def test_should_delete_only_remaining_answer_and_clear_question
    answers(:sticky).destroy
    assert_raises ActiveRecord::RecordNotFound do
      questions(:sticky)
    end
  end

  def test_should_create_reply_and_set_category_from_question
    p = create_answer questions(:pdi), :body => 'blah'
    assert_equal questions(:pdi).category_id, p.category_id
  end

  def test_should_delete_reply
    counts = lambda { [Answer.count, categories(:rails).answers_count, users(:sam).answers_count, questions(:pdi).answers_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call
    answers(:pdi_reply).destroy
    [categories(:rails), users(:sam), questions(:pdi)].each &:reload
    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_edit_own_answer
    assert answers(:shield).editable_by?(users(:sam))
  end

  def test_should_edit_answer_as_admin
    assert answers(:shield).editable_by?(users(:aaron))
  end

  def test_should_edit_answer_as_moderator
    assert answers(:pdi).editable_by?(users(:sam))
  end

  def test_should_not_edit_answer_in_own_question
    assert !answers(:shield_reply).editable_by?(users(:sam))
  end

  protected
    def create_answer(question, options = {})
      returning question.answers.build(options) do |p|
        p.user = users(:aaron)
        p.save
        # answer should inherit the category from the question
        assert_equal p.question.category, p.category
      end
    end
end
