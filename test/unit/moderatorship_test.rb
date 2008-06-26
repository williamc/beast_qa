require File.dirname(__FILE__) + '/../test_helper'

class ModeratorshipTest < Test::Unit::TestCase
  all_fixtures

  def test_should_find_moderators
    assert_models_equal [users(:sam)], categories(:rails).moderators
  end
  
  def test_should_find_moderated_categories
    assert_models_equal [categories(:rails)], users(:sam).categories
  end
  
  def test_should_add_moderator
    assert_equal [], categories(:comics).moderators
    assert_difference Moderatorship, :count do
      categories(:comics).moderators << users(:sam)
    end
    assert_models_equal [users(:sam)], categories(:comics).moderators(true)
  end
  
  def test_should_not_add_duplicate_moderator
    assert_models_equal [users(:sam)], categories(:rails).moderators
    assert_difference Moderatorship, :count, 0 do
      assert_raise ActiveRecord::RecordNotSaved do 
        categories(:rails).moderators << users(:sam)
      end
    end
  end
end
