require "#{File.dirname(__FILE__)}/../test_helper"

class NewUserFirstAnswerTest < ActionController::IntegrationTest
  all_fixtures

  ## PLEASE
  ## don't refactor this code - it's me learning integration testing, and I plan
  ## on improving it myself over the next few days / weeks
  #
  # ha, fat chance of that happening!  -- rick

  def test_signup_and_answer_edit_and_question
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
    
    review_question(questions(:pdi))    
    first_answer=add_reply(questions(:pdi), "I'm on it.")
    click_edit_answer(first_answer)

    # update that answer
    post answer_path(:category_id => categories(:rails), :question_id => questions(:pdi), :id => first_answer), :answer => { :body => "I change my mind, I'm scared."}, :_method => "put"
    assert_response :redirect
    follow_redirect!
    assert_template "questions/show"
    assert_equal("I change my mind, I'm scared.", first_answer.reload.body)

    # ponies
    review_question(questions(:ponies))
    add_reply(questions(:ponies), "Ponies are cool.")
    
    # answer new question
    post questions_path(:category_id => categories(:rails).id), :question => { :title => "Beast rocks!", :body => "I love beast!"}
    assert_response :redirect
    follow_redirect!
    assert_template "questions/show"
    
    # back to home
    go_home
  
    # logoff
    get logout_path
    assert_response :redirect
    follow_redirect!
    assert_template "categories/index"
    
    josh=User.find_by_login "jgoebel"
    assert_equal 3, josh.answers.count
  end
  
  private
  
    # return to /
    def go_home
      get categories_path
      assert_response :success
      assert_template "categories/index"
    end
  
    # adds a reply to a particular answer
    def add_reply(question,body)
      post answers_path(question.category, question), :answer => { :body => body }
      assert_response :redirect
      answer = assigns(:answer)
      follow_redirect!
      assert_response :success
      assert_template "questions/show"
      answer
    end
    
    # pulls up the edit form for a answer
    def click_edit_answer(answer)
      get edit_answer_path(answer.question.category, answer.question, answer)
      assert_response :success
      assert_template "answers/edit"
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
    
    # walks down the tree, index, category, question
    def review_question(question)
      get categories_path
      assert_response :success
      assert assigns(:categories)
      assert_template "categories/index"

      get category_path(question.category)
      assert_response :success
      assert assigns(:category)
      assert assigns(:questions)
      assert_template "categories/show"

      get question_path(question.category, question)
      assert_response :success
      assert assigns(:question)
      assert assigns(:answers)
      assert_template "questions/show"
    end

end
