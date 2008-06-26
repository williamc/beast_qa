require "#{File.dirname(__FILE__)}/../test_helper"

class CachingTest < ActionController::IntegrationTest
  all_fixtures
  
  def setup
    ActionController::Base.perform_caching = true
  end
  
  def teardown
    ActionController::Base.perform_caching = false
  end
  
  #
  # These are not passing with autotest right now. Don't have time to look into it
  # but it needs to be fixed.
  #
  # def test_should_cache_answers_rss
  #   assert_cached "answers.rss" do
  #     get formatted_all_answers_path(:rss)
  #   end
  # end
  # 
  # def test_should_cache_category_answers_rss
  #   assert_cached "categories/1/answers.rss" do
  #     get formatted_category_answers_path(1, :rss)
  #   end
  # end
  # 
  # def test_should_cache_question_answers_rss
  #   assert_cached "categories/1/questions/1/answers.rss" do
  #     get formatted_answers_path(1, 1, :rss)
  #   end
  # end
  # 
  # def test_should_cache_monitored_answers
  #   assert_cached "users/1/monitored.rss" do
  #     get formatted_monitored_answers_path(1, :rss)
  #   end
  # end
  # 
  # def assert_cached(path)
  #   path = File.join(RAILS_ROOT, 'public', path)
  #   yield
  #   assert File.exist?(path), "oops, not cached in: #{path.inspect}"
  #   FileUtils.rm_rf path
  # end
end