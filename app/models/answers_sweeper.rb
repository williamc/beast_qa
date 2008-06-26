class AnswersSweeper < ActionController::Caching::Sweeper
  observe Answer
  
  def after_save(answer)
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'categories', answer.category_id.to_s, 'answers.rss')
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'categories', answer.category_id.to_s, 'questions', "#{answer.question_id}.rss")
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'users')
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'answers.rss')
  end
  
  alias_method :after_destroy, :after_save
end