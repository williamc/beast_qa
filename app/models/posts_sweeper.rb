class PostsSweeper < ActionController::Caching::Sweeper
  observe Post
  
  def after_save(post)
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'categories', post.category_id.to_s, 'posts.rss')
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'categories', post.category_id.to_s, 'questions', "#{post.question_id}.rss")
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'users')
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'posts.rss')
  end
  
  alias_method :after_destroy, :after_save
end