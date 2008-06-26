require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  all_fixtures

  def test_should_list_only_top_level_questions
    assert_models_equal [questions(:sticky), questions(:il8n), questions(:ponies), questions(:pdi)], categories(:rails).questions
  end

  def test_should_list_recent_posts
    assert_models_equal [posts(:il8n), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi),posts(:sticky) ], categories(:rails).posts
  end

  def test_should_find_recent_post
    assert_equal posts(:il8n), categories(:rails).recent_post
  end

  def test_should_find_recent_question
    assert_equal questions(:il8n), categories(:rails).recent_question
  end

  def test_should_find_first_recent_post
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
