module CategoriesHelper
  
  # used to know if a topic has changed since we read it last
  def recent_topic_activity(topic)
    return false if not logged_in?
    return topic.replied_at > (session[:topics][topic.id] || last_active)
  end 
  
  # used to know if a category has changed since we read it last
  def recent_category_activity(category)
    return false unless logged_in? && category.recent_topic
    return category.recent_topic.replied_at > (session[:categories][category.id] || last_active)
  end
  
end
