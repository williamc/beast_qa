require File.dirname(__FILE__) + '/../test_helper'
require 'answers_controller'

# Re-raise errors caught by the controller.
class AnswersController; def rescue_action(e) raise e end; end

class AnswersControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = AnswersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_create_reply
    counts = lambda { [Answer.count, categories(:rails).answers_count, users(:aaron).answers_count, questions(:pdi).answers_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :aaron
    post :create, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :answer => { :body => 'blah' }
    assert_redirected_to question_path(:category_id => categories(:rails).id, :id => questions(:pdi).id, :anchor => assigns(:answer).dom_id, :page => '1')
    assert_equal questions(:pdi), assigns(:question)
    [categories(:rails), users(:aaron), questions(:pdi)].each &:reload
  
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_create_reply_with_xml
    content_type 'application/xml'
    authorize_as :aaron
    post :create, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :answer => { :body => 'blah' }, :format => 'xml'
    assert_response :created
    assert_equal formatted_answer_url(:category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => assigns(:answer), :format => :xml), @response.headers["Location"]
  end

  def test_should_update_question_replied_at_upon_replying
    old=questions(:pdi).replied_at
    login_as :aaron
    post :create, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :answer => { :body => 'blah' }
    assert_not_equal(old, questions(:pdi).reload.replied_at)
    assert old < questions(:pdi).reload.replied_at
  end

  def test_should_reply_with_no_body
    assert_difference Answer, :count, 0 do
      login_as :aaron
      post :create, :category_id => categories(:rails).id, :question_id => answers(:pdi).id, :answer => {}
      assert_redirected_to question_path(:category_id => categories(:rails).id, :id => answers(:pdi).id, :anchor => 'reply-form', :page => '1')
    end
  end

  def test_should_delete_reply
    counts = lambda { [Answer.count, categories(:rails).answers_count, users(:sam).answers_count, questions(:pdi).answers_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :aaron
    delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_reply).id
    assert_redirected_to question_path(:category_id => categories(:rails), :id => questions(:pdi))
    [categories(:rails), users(:sam), questions(:pdi)].each &:reload

    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_delete_reply_with_xml
    content_type 'application/xml'
    authorize_as :aaron
    delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_reply).id, :format => 'xml'
    assert_response :success
  end

  def test_should_delete_reply_as_moderator
    assert_difference Answer, :count, -1 do
      login_as :sam
      delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_rebuttal).id
    end
  end

  def test_should_delete_question_if_deleting_the_last_reply
    assert_difference Answer, :count, -1 do
      assert_difference Question, :count, -1 do
        login_as :aaron
        delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:il8n).id, :id => answers(:il8n).id
        assert_redirected_to category_path(categories(:rails))
        assert_raise(ActiveRecord::RecordNotFound) { questions(:il8n).reload }
      end
    end
  end

  def test_can_edit_own_answer
    login_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => answers(:silver_surfer).id, :answer => {}
    assert_redirected_to question_path(:category_id => categories(:comics), :id => questions(:galactus), :anchor => answers(:silver_surfer).dom_id, :page => '1')
  end

  def test_can_edit_own_answer_with_xml
    content_type 'application/xml'
    authorize_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => answers(:silver_surfer).id, :answer => {}, :format => 'xml'
    assert_response :success
  end


  def test_can_edit_other_answer_as_moderator
    login_as :sam
    put :update, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_rebuttal).id, :answer => {}
    assert_redirected_to question_path(:category_id => categories(:rails), :id => answers(:pdi), :anchor => answers(:pdi_rebuttal).dom_id, :page => '1')
  end

  def test_cannot_edit_other_answer
    login_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => answers(:galactus).id, :answer => {}
    assert_redirected_to login_path
  end

  def test_cannot_edit_other_answer_with_xml
    content_type 'application/xml'
    authorize_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => answers(:galactus).id, :answer => {}, :format => 'xml'
    assert_response 401
  end

  def test_cannot_edit_own_answer_user_id
    login_as :sam
    put :update, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_reply).id, :answer => { :user_id => 32 }
    assert_redirected_to question_path(:category_id => categories(:rails), :id => answers(:pdi), :anchor => answers(:pdi_reply).dom_id, :page => '1')
    assert_equal users(:sam).id, answers(:pdi_reply).reload.user_id
  end

  def test_can_edit_other_answer_as_admin
    login_as :aaron
    put :update, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_rebuttal).id, :answer => {}
    assert_redirected_to question_path(:category_id => categories(:rails), :id => answers(:pdi), :anchor => answers(:pdi_rebuttal).dom_id, :page => '1')
  end
  
  def test_should_view_answer_as_xml
    get :show, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => answers(:pdi_rebuttal).id, :format => 'xml'
    assert_response :success
    assert_select 'answer'
  end
  
  def test_should_view_recent_answers
    get :index
    assert_response :success
    assert_models_equal [answers(:il8n), answers(:shield_reply), answers(:shield), answers(:silver_surfer), answers(:galactus), answers(:ponies), answers(:pdi_rebuttal), answers(:pdi_reply), answers(:pdi), answers(:sticky)], assigns(:answers)
    assert_select 'html>head'
  end

  def test_should_view_answers_by_category
    get :index, :category_id => categories(:comics).id
    assert_response :success
    assert_models_equal [answers(:shield_reply), answers(:shield), answers(:silver_surfer), answers(:galactus)], assigns(:answers)
    assert_select 'html>head'
  end

  def test_should_view_answers_by_user
    get :index, :user_id => users(:sam).id
    assert_response :success
    assert_models_equal [answers(:shield), answers(:silver_surfer), answers(:ponies), answers(:pdi_reply), answers(:sticky)], assigns(:answers)
    assert_select 'html>head'
  end

  def test_should_view_recent_answers_with_xml
    content_type 'application/xml'
    get :index, :format => 'xml'
    assert_response :success
    assert_models_equal [answers(:il8n), answers(:shield_reply), answers(:shield), answers(:silver_surfer), answers(:galactus), answers(:ponies), answers(:pdi_rebuttal), answers(:pdi_reply), answers(:pdi), answers(:sticky)], assigns(:answers)
    assert_select 'answers>answer'
  end

  def test_should_view_answers_by_category_with_xml
    content_type 'application/xml'
    get :index, :category_id => categories(:comics).id, :format => 'xml'
    assert_response :success
    assert_models_equal [answers(:shield_reply), answers(:shield), answers(:silver_surfer), answers(:galactus)], assigns(:answers)
    assert_select 'answers>answer'
  end

  def test_should_view_answers_by_user_with_xml
    content_type 'application/xml'
    get :index, :user_id => users(:sam).id, :format => 'xml'
    assert_response :success
    assert_models_equal [answers(:shield), answers(:silver_surfer), answers(:ponies), answers(:pdi_reply), answers(:sticky)], assigns(:answers)
    assert_select 'answers>answer'
  end

  def test_should_view_monitored_answers
    get :monitored, :user_id => users(:aaron).id
    assert_models_equal [answers(:pdi_reply)], assigns(:answers)
  end
  
  def test_should_not_view_unmonitored_answers
    get :monitored, :user_id => users(:sam).id
    assert_models_equal [], assigns(:answers)
  end
  

  def test_should_search_recent_answers
    get :search, :q => 'pdi'
    assert_response :success
    assert_models_equal [answers(:pdi_rebuttal), answers(:pdi_reply), answers(:pdi)], assigns(:answers)
  end

  def test_should_search_answers_by_category
    get :search, :category_id => categories(:comics).id, :q => 'galactus'
    assert_response :success
    assert_models_equal [answers(:silver_surfer), answers(:galactus)], assigns(:answers)
  end
  
  def test_should_view_recent_answers_as_rss
    get :index, :format => 'rss'
    assert_response :success
    assert_models_equal [answers(:il8n), answers(:shield_reply), answers(:shield), answers(:silver_surfer), answers(:galactus), answers(:ponies), answers(:pdi_rebuttal), answers(:pdi_reply), answers(:pdi), answers(:sticky)], assigns(:answers)
  end

  def test_should_view_answers_by_category_as_rss
    get :index, :category_id => categories(:comics).id, :format => 'rss'
    assert_response :success
    assert_models_equal [answers(:shield_reply), answers(:shield), answers(:silver_surfer), answers(:galactus)], assigns(:answers)
  end

  def test_should_view_answers_by_user_as_rss
    get :index, :user_id => users(:sam).id, :format => 'rss'
    assert_response :success
    assert_models_equal [answers(:shield), answers(:silver_surfer), answers(:ponies), answers(:pdi_reply), answers(:sticky)], assigns(:answers)
  end
  
  def test_disallow_new_answer_to_locked_question
    galactus = questions(:galactus)
    galactus.locked = 1
    galactus.save
    login_as :aaron
    post :create, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :answer => { :body => 'blah' }
    assert_redirected_to question_path(:category_id => categories(:comics), :id => questions(:galactus))
    assert_equal 'This question is locked', flash[:notice]
  end
end
