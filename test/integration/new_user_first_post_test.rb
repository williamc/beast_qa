require "#{File.dirname(__FILE__)}/../test_helper"

class NewUserFirstPostTest < ActionController::IntegrationTest
  all_fixtures

  ## PLEASE
  ## don't refactor this code - it's me learning integration testing, and I plan
  ## on improving it myself over the next few days / weeks
  #
  # ha, fat chance of that happening!  -- rick

  def test_signup_and_post_edit_and_topic
    go_home

    get login_path
    assert_response :success
    assert_template "sessions/new"
    
    get signup_path
    assert_response :success
    assert_template "users/new"

    # create an account
    post users_path, :user => { :display_name => "Josh Goebel", :login => "jgoebel", :password => "beast", :password_confirmation => "beast", :email => "josh@dwgsolutions.com" }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "sessions/new"

    # sign in?
    post session_path, :login => 'jgoebel', :password => 'beast'
    assert_response :success # blast!  not activated yet!
    
    activate 'jgoebel'
    
    # sign in
    # login("jgoebel","beast")
    
    review_topic(topics(:pdi))    
    first_post=add_reply(topics(:pdi), "I'm on it.")
    click_edit_post(first_post)

    # update that post
    post post_path(:category_id => categories(:rails), :topic_id => topics(:pdi), :id => first_post), :post => { :body => "I change my mind, I'm scared."}, :_method => "put"
    assert_response :redirect
    follow_redirect!
    assert_template "topics/show"
    assert_equal("I change my mind, I'm scared.", first_post.reload.body)

    # ponies
    review_topic(topics(:ponies))
    add_reply(topics(:ponies), "Ponies are cool.")
    
    # post new topic
    post topics_path(:category_id => categories(:rails).id), :topic => { :title => "Beast rocks!", :body => "I love beast!"}
    assert_response :redirect
    follow_redirect!
    assert_template "topics/show"
    
    # back to home
    go_home
  
    # logoff
    get logout_path
    assert_response :redirect
    follow_redirect!
    assert_template "categories/index"
    
    josh=User.find_by_login "jgoebel"
    assert_equal 3, josh.posts.count
  end
  
  private
  
    # return to /
    def go_home
      get categories_path
      assert_response :success
      assert_template "categories/index"
    end
  
    # adds a reply to a particular post
    def add_reply(topic,body)
      post posts_path(topic.category, topic), :post => { :body => body }
      assert_response :redirect
      post = assigns(:post)
      follow_redirect!
      assert_response :success
      assert_template "topics/show"
      post
    end
    
    # pulls up the edit form for a post
    def click_edit_post(post)
      get edit_post_path(post.topic.category, post.topic, post)
      assert_response :success
      assert_template "posts/edit"
    end
    
    def login(user, password)
      post session_path, :login => user, :password => password
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_template "categories/index"
    end
    
    def activate(login)
      user = User.find_by_login login
      get "/activate/#{user.login_key}"
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_template "categories/index"
    end
    
    # walks down the tree, index, category, topic
    def review_topic(topic)
      get categories_path
      assert_response :success
      assert assigns(:categories)
      assert_template "categories/index"

      get category_path(topic.category)
      assert_response :success
      assert assigns(:category)
      assert assigns(:topics)
      assert_template "categories/show"

      get topic_path(topic.category, topic)
      assert_response :success
      assert assigns(:topic)
      assert assigns(:posts)
      assert_template "topics/show"
    end

end
