module CategoriesHelper
  
  # used to know if a question has changed since we read it last
  def recent_question_activity(question)
    return false if not logged_in?
    return question.replied_at > (session[:questions][question.id] || last_active)
  end 
  
  # used to know if a category has changed since we read it last
  def recent_category_activity(category)
    return false unless logged_in? && category.recent_question
    return category.recent_question.replied_at > (session[:categories][category.id] || last_active)
  end
  
end
