require File.dirname(__FILE__) + '/../test_helper'

class MonitorshipsTest < Test::Unit::TestCase
  all_fixtures

  def test_should_find_monitorships_from_users
    assert_models_equal [monitorships(:aaron_pdi)], users(:aaron).monitorships
    assert_models_equal [monitorships(:sam_pdi)],   users(:sam).monitorships
  end
  
  def test_should_find_monitorships_from_questions
    assert_models_equal [monitorships(:aaron_pdi), monitorships(:sam_pdi)], questions(:pdi).monitorships
  end
  
  def test_should_find_active_watchers
    assert_models_equal [users(:aaron)], questions(:pdi).monitors
  end

  def test_should_find_monitored_questions_for_user
    assert_models_equal [questions(:pdi)], users(:aaron).monitored_questions
  end
  
  def test_should_not_find_inactive_monitored_questions
    assert_equal [], users(:sam).monitored_questions
  end
  
  def test_should_not_find_any_monitored_questions
    assert_equal [], users(:joe).monitored_questions
  end
end
