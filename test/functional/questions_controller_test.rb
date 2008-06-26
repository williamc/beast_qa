require File.dirname(__FILE__) + '/../test_helper'
require 'questions_controller'

# Re-raise errors caught by the controller.
#class QuestionsController; def rescue_action(e) raise e end; end

class QuestionsControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = QuestionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # page sure we have a special page link back to the last page
  # of the category we're currently viewing
  def test_should_have_page_link_to_category
    @request.session[:category_page]=Hash.new(1)
    @request.session[:category_page][1]=911
    get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id
    assert_tag :tag => "a", :content => "page 911"
  end


  def test_should_get_index
    get :index, :category_id => 1
    assert_redirected_to category_path(1)
  end

  def test_should_get_index_as_xml
    content_type 'application/xml'
    get :index, :category_id => 1, :format => 'xml'
    assert_response :success
    assert_select 'questions>question'
  end

  def test_should_show_question_as_rss
    get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id, :format => 'rss'
    assert_response :success
    assert_select 'channel'
  end
  
  def test_should_show_question_as_xml
    content_type 'application/xml'
    get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id, :format => 'xml'
    assert_response :success
    assert_select 'question'
  end

  def test_should_get_new
    login_as :aaron
    get :new, :category_id => 1
    assert_response :success
  end

  def test_sticky_and_locked_protected_from_non_admin
    login_as :joe
    assert ! users(:joe).admin?
    assert ! users(:joe).moderator_of?(:rails)
    post :create, :category_id => categories(:rails).id, :question => { :title => 'blah', :sticky => "1", :locked => "1", :body => 'foo' }
    assert assigns(:question)
    assert ! assigns(:question).sticky?
    assert ! assigns(:question).locked?
  end

  def test_sticky_and_locked_allowed_to_moderator
    login_as :sam
    assert ! users(:sam).admin?
    assert users(:sam).moderator_of?(categories(:rails))
    post :create, :category_id => categories(:rails).id, :question => { :title => 'blah', :sticky => "1", :locked => "1", :body => 'foo' }
    assert assigns(:question)
    assert assigns(:question).sticky?
    assert assigns(:question).locked?
  end
    
  def test_should_allow_admin_to_sticky_and_lock
    login_as :aaron
    post :create, :category_id => categories(:rails).id, :question => { :title => 'blah2', :sticky => "1", :locked => "1", :body => 'foo' }
    assert assigns(:question).sticky?
    assert assigns(:question).locked?
  end

  uses_transaction :test_should_not_create_question_without_body

  def test_should_not_create_question_without_body
    counts = lambda { [Question.count, Answer.count] }
    old = counts.call
    
    login_as :aaron
    
    post :create, :category_id => categories(:rails).id, :question => { :title => 'blah' }
    assert assigns(:question)
    assert assigns(:answer)
    # both of these should be new records if the save fails so that the view can
    # render accordingly
    assert assigns(:question).new_record?
    assert assigns(:answer).new_record?
    
    assert_equal old, counts.call
  end
  
  def test_should_not_create_question_without_title
    counts = lambda { [Question.count, Answer.count] }
    old = counts.call
    
    login_as :aaron
    
    post :create, :category_id => categories(:rails).id, :question => { :body => 'blah' }
    assert_equal "blah", assigns(:question).body
    assert assigns(:answer)
    # both of these should be new records if the save fails so that the view can
    # render accordingly
    assert assigns(:question).new_record?
    assert assigns(:answer).new_record?
    
    assert_equal old, counts.call
  end

  def test_should_create_question
    counts = lambda { [Question.count, Answer.count, categories(:rails).questions_count, categories(:rails).answers_count,  users(:aaron).answers_count] }
    old = counts.call
    
    login_as :aaron
    post :create, :category_id => categories(:rails).id, :question => { :title => 'blah', :body => 'foo' }
    assert assigns(:question)
    assert assigns(:answer)
    assert_redirected_to question_path(categories(:rails), assigns(:question))
    [categories(:rails), users(:aaron)].each &:reload
  
    assert_equal old.collect { |n| n + 1}, counts.call
  end

  def test_should_create_question_with_xml
    content_type 'application/xml'
    authorize_as :aaron
    post :create, :category_id => categories(:rails).id, :question => { :title => 'blah', :body => 'foo' }, :format => 'xml'
    assert_response :created
    assert_equal formatted_question_url(:category_id => categories(:rails), :id => assigns(:question), :format => :xml), @response.headers["Location"]
  end

  def test_should_delete_question
    counts = lambda { [Answer.count, categories(:rails).questions_count, categories(:rails).answers_count] }
    old = counts.call
    
    login_as :aaron
    delete :destroy, :category_id => categories(:rails).id, :id => questions(:ponies).id
    assert_redirected_to category_path(categories(:rails))
    [categories(:rails), users(:aaron)].each &:reload

    assert_equal old.collect { |n| n - 1}, counts.call
  end

  def test_should_delete_question_with_xml
    content_type 'application/xml'
    authorize_as :aaron
    delete :destroy, :category_id => categories(:rails).id, :id => questions(:ponies).id, :format => 'xml'
    assert_response :success
  end

  def test_should_allow_moderator_to_delete_question
    assert_difference Question, :count, -1 do
      login_as :sam
      delete :destroy, :category_id => categories(:rails).id, :id => questions(:pdi).id
    end
  end

  def test_should_update_views_for_show
    assert_difference questions(:pdi), :views do
      get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id
      assert_response :success
      questions(:pdi).reload
    end
  end

  def test_should_not_update_views_for_show_via_rss
    assert_difference questions(:pdi), :views, 0 do
      get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id, :format => 'rss'
      assert_response :success
      questions(:pdi).reload
    end
  end

  def test_should_not_add_viewed_question_to_session_on_show_rss
    login_as :aaron
    get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id, :format => 'rss'
    assert_response :success
    assert session[:questions].blank?
  end

  def test_should_update_views_for_show_except_question_author
    login_as :aaron
    views=questions(:pdi).views
    get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id
    assert_response :success
    assert_equal views, questions(:pdi).reload.views
  end

  def test_should_show_question
    get :show, :category_id => categories(:rails).id, :id => questions(:pdi).id
    assert_response :success
    assert_equal questions(:pdi), assigns(:question)
    assert_models_equal [answers(:pdi), answers(:pdi_reply), answers(:pdi_rebuttal)], assigns(:answers)
  end

  def test_should_show_other_answer
    get :show, :category_id => categories(:rails).id, :id => questions(:ponies).id
    assert_response :success
    assert_equal questions(:ponies), assigns(:question)
    assert_models_equal [answers(:ponies)], assigns(:answers)
  end

  def test_should_get_edit
    login_as :aaron
    get :edit, :category_id => 1, :id => 1
    assert_response :success
  end
  
  def test_should_update_own_answer
    login_as :sam
    put :update, :category_id => categories(:rails).id, :id => questions(:ponies).id, :question => { }
    assert_redirected_to question_path(categories(:rails), assigns(:question))
  end

  def test_should_update_with_xml
    content_type 'application/xml'
    authorize_as :sam
    put :update, :category_id => categories(:rails).id, :id => questions(:ponies).id, :question => { }, :format => 'xml'
    assert_response :success
  end

  def test_should_not_update_user_id_of_own_answer
    login_as :sam
    put :update, :category_id => categories(:rails).id, :id => questions(:ponies).id, :question => { :user_id => 32 }
    assert_redirected_to question_path(categories(:rails), assigns(:question))
    assert_equal users(:sam).id, answers(:ponies).reload.user_id
  end

  def test_should_not_update_other_answer
    login_as :sam
    put :update, :category_id => categories(:comics).id, :id => questions(:galactus).id, :question => { }
    assert_redirected_to login_path
  end

  def test_should_not_update_other_answer_with_xml
    content_type 'application/xml'
    authorize_as :sam
    put :update, :category_id => categories(:comics).id, :id => questions(:galactus).id, :question => { }, :format => 'xml'
    assert_response :unauthorized
  end

  def test_should_update_other_answer_as_moderator
    login_as :sam
    put :update, :category_id => categories(:rails).id, :id => questions(:pdi).id, :question => { }
    assert_redirected_to question_path(categories(:rails), assigns(:question))
  end

  def test_should_update_other_answer_as_admin
    login_as :aaron
    put :update, :category_id => categories(:rails).id, :id => questions(:ponies), :question => { }
    assert_redirected_to question_path(categories(:rails), assigns(:question))
  end
end
