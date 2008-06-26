require File.dirname(__FILE__) + '/../test_helper'
require 'posts_controller'

# Re-raise errors caught by the controller.
class PostsController; def rescue_action(e) raise e end; end

class PostsControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_create_reply
    counts = lambda { [Post.count, categories(:rails).posts_count, users(:aaron).posts_count, questions(:pdi).posts_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :aaron
    post :create, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :post => { :body => 'blah' }
    assert_redirected_to question_path(:category_id => categories(:rails).id, :id => questions(:pdi).id, :anchor => assigns(:post).dom_id, :page => '1')
    assert_equal questions(:pdi), assigns(:question)
    [categories(:rails), users(:aaron), questions(:pdi)].each &:reload
  
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_create_reply_with_xml
    content_type 'application/xml'
    authorize_as :aaron
    post :create, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :post => { :body => 'blah' }, :format => 'xml'
    assert_response :created
    assert_equal formatted_post_url(:category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => assigns(:post), :format => :xml), @response.headers["Location"]
  end

  def test_should_update_question_replied_at_upon_replying
    old=questions(:pdi).replied_at
    login_as :aaron
    post :create, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :post => { :body => 'blah' }
    assert_not_equal(old, questions(:pdi).reload.replied_at)
    assert old < questions(:pdi).reload.replied_at
  end

  def test_should_reply_with_no_body
    assert_difference Post, :count, 0 do
      login_as :aaron
      post :create, :category_id => categories(:rails).id, :question_id => posts(:pdi).id, :post => {}
      assert_redirected_to question_path(:category_id => categories(:rails).id, :id => posts(:pdi).id, :anchor => 'reply-form', :page => '1')
    end
  end

  def test_should_delete_reply
    counts = lambda { [Post.count, categories(:rails).posts_count, users(:sam).posts_count, questions(:pdi).posts_count] }
    equal  = lambda { [categories(:rails).questions_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :aaron
    delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_reply).id
    assert_redirected_to question_path(:category_id => categories(:rails), :id => questions(:pdi))
    [categories(:rails), users(:sam), questions(:pdi)].each &:reload

    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_delete_reply_with_xml
    content_type 'application/xml'
    authorize_as :aaron
    delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_reply).id, :format => 'xml'
    assert_response :success
  end

  def test_should_delete_reply_as_moderator
    assert_difference Post, :count, -1 do
      login_as :sam
      delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_rebuttal).id
    end
  end

  def test_should_delete_question_if_deleting_the_last_reply
    assert_difference Post, :count, -1 do
      assert_difference Question, :count, -1 do
        login_as :aaron
        delete :destroy, :category_id => categories(:rails).id, :question_id => questions(:il8n).id, :id => posts(:il8n).id
        assert_redirected_to category_path(categories(:rails))
        assert_raise(ActiveRecord::RecordNotFound) { questions(:il8n).reload }
      end
    end
  end

  def test_can_edit_own_post
    login_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => posts(:silver_surfer).id, :post => {}
    assert_redirected_to question_path(:category_id => categories(:comics), :id => questions(:galactus), :anchor => posts(:silver_surfer).dom_id, :page => '1')
  end

  def test_can_edit_own_post_with_xml
    content_type 'application/xml'
    authorize_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => posts(:silver_surfer).id, :post => {}, :format => 'xml'
    assert_response :success
  end


  def test_can_edit_other_post_as_moderator
    login_as :sam
    put :update, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_rebuttal).id, :post => {}
    assert_redirected_to question_path(:category_id => categories(:rails), :id => posts(:pdi), :anchor => posts(:pdi_rebuttal).dom_id, :page => '1')
  end

  def test_cannot_edit_other_post
    login_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => posts(:galactus).id, :post => {}
    assert_redirected_to login_path
  end

  def test_cannot_edit_other_post_with_xml
    content_type 'application/xml'
    authorize_as :sam
    put :update, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :id => posts(:galactus).id, :post => {}, :format => 'xml'
    assert_response 401
  end

  def test_cannot_edit_own_post_user_id
    login_as :sam
    put :update, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_reply).id, :post => { :user_id => 32 }
    assert_redirected_to question_path(:category_id => categories(:rails), :id => posts(:pdi), :anchor => posts(:pdi_reply).dom_id, :page => '1')
    assert_equal users(:sam).id, posts(:pdi_reply).reload.user_id
  end

  def test_can_edit_other_post_as_admin
    login_as :aaron
    put :update, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_rebuttal).id, :post => {}
    assert_redirected_to question_path(:category_id => categories(:rails), :id => posts(:pdi), :anchor => posts(:pdi_rebuttal).dom_id, :page => '1')
  end
  
  def test_should_view_post_as_xml
    get :show, :category_id => categories(:rails).id, :question_id => questions(:pdi).id, :id => posts(:pdi_rebuttal).id, :format => 'xml'
    assert_response :success
    assert_select 'post'
  end
  
  def test_should_view_recent_posts
    get :index
    assert_response :success
    assert_models_equal [posts(:il8n), posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi), posts(:sticky)], assigns(:posts)
    assert_select 'html>head'
  end

  def test_should_view_posts_by_category
    get :index, :category_id => categories(:comics).id
    assert_response :success
    assert_models_equal [posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus)], assigns(:posts)
    assert_select 'html>head'
  end

  def test_should_view_posts_by_user
    get :index, :user_id => users(:sam).id
    assert_response :success
    assert_models_equal [posts(:shield), posts(:silver_surfer), posts(:ponies), posts(:pdi_reply), posts(:sticky)], assigns(:posts)
    assert_select 'html>head'
  end

  def test_should_view_recent_posts_with_xml
    content_type 'application/xml'
    get :index, :format => 'xml'
    assert_response :success
    assert_models_equal [posts(:il8n), posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi), posts(:sticky)], assigns(:posts)
    assert_select 'posts>post'
  end

  def test_should_view_posts_by_category_with_xml
    content_type 'application/xml'
    get :index, :category_id => categories(:comics).id, :format => 'xml'
    assert_response :success
    assert_models_equal [posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus)], assigns(:posts)
    assert_select 'posts>post'
  end

  def test_should_view_posts_by_user_with_xml
    content_type 'application/xml'
    get :index, :user_id => users(:sam).id, :format => 'xml'
    assert_response :success
    assert_models_equal [posts(:shield), posts(:silver_surfer), posts(:ponies), posts(:pdi_reply), posts(:sticky)], assigns(:posts)
    assert_select 'posts>post'
  end

  def test_should_view_monitored_posts
    get :monitored, :user_id => users(:aaron).id
    assert_models_equal [posts(:pdi_reply)], assigns(:posts)
  end
  
  def test_should_not_view_unmonitored_posts
    get :monitored, :user_id => users(:sam).id
    assert_models_equal [], assigns(:posts)
  end
  

  def test_should_search_recent_posts
    get :search, :q => 'pdi'
    assert_response :success
    assert_models_equal [posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi)], assigns(:posts)
  end

  def test_should_search_posts_by_category
    get :search, :category_id => categories(:comics).id, :q => 'galactus'
    assert_response :success
    assert_models_equal [posts(:silver_surfer), posts(:galactus)], assigns(:posts)
  end
  
  def test_should_view_recent_posts_as_rss
    get :index, :format => 'rss'
    assert_response :success
    assert_models_equal [posts(:il8n), posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi), posts(:sticky)], assigns(:posts)
  end

  def test_should_view_posts_by_category_as_rss
    get :index, :category_id => categories(:comics).id, :format => 'rss'
    assert_response :success
    assert_models_equal [posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus)], assigns(:posts)
  end

  def test_should_view_posts_by_user_as_rss
    get :index, :user_id => users(:sam).id, :format => 'rss'
    assert_response :success
    assert_models_equal [posts(:shield), posts(:silver_surfer), posts(:ponies), posts(:pdi_reply), posts(:sticky)], assigns(:posts)
  end
  
  def test_disallow_new_post_to_locked_question
    galactus = questions(:galactus)
    galactus.locked = 1
    galactus.save
    login_as :aaron
    post :create, :category_id => categories(:comics).id, :question_id => questions(:galactus).id, :post => { :body => 'blah' }
    assert_redirected_to question_path(:category_id => categories(:comics), :id => questions(:galactus))
    assert_equal 'This question is locked', flash[:notice]
  end
end
