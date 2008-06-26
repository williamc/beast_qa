require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  all_fixtures

  def test_should_list_only_top_level_questions
    assert_models_equal [questions(:sticky), questions(:il8n), questions(:ponies), questions(:pdi)], categories(:rails).questions
  end

  def test_should_list_recent_answers
    assert_models_equal [answers(:il8n), answers(:ponies), answers(:pdi_rebuttal), answers(:pdi_reply), answers(:pdi),answers(:sticky) ], categories(:rails).answers
  end

  def test_should_find_recent_answer
    assert_equal answers(:il8n), categories(:rails).recent_answer
  end

  def test_should_find_recent_question
    assert_equal questions(:il8n), categories(:rails).recent_question
  end

  def test_should_find_first_recent_answer
    assert_equal questions(:il8n), categories(:rails).recent_question
  end

  def test_should_format_body_html
    category = Category.new(:description => 'foo')
    category.send :format_content
    assert_not_nil category.description_html
    
    category.description = ''
    category.send :format_content
    assert category.description_html.blank?
  end
  
  def test_should_find_ordered_categories
    assert_equal [categories(:comics), categories(:rails)], Category.find_ordered
  end
end
