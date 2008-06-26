ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'categories', :action => 'index'

  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session
  
  map.resources :users, :member => { :admin => :answer }, :has_many => [:moderators, :answers]
  
  map.resources :categories, :has_many => [:answers] do |category|
    category.resources :questions, :name_prefix => nil do |question|
      question.resources :answers, :name_prefix => nil
      question.resource :monitorship, :name_prefix => nil
    end
    category.resources :answers, :name_prefix => 'category_'
  end

  map.resources :answers, :name_prefix => 'all_', :collection => { :search => :get }

  map.with_options :controller => 'users' do |user|
    user.signup   'signup',        :action => 'new'
    user.settings 'settings',      :action => 'edit'
    user.activate 'activate/:key', :action => 'activate'
  end
  
  map.with_options :controller => 'sessions' do |session|
    session.login    'login',  :action => 'new'
    session.logout   'logout', :action => 'destroy'
  end

  map.with_options :controller => 'answers', :action => 'monitored' do |map|
    map.formatted_monitored_answers 'users/:user_id/monitored.:format'
    map.monitored_answers           'users/:user_id/monitored'
  end

  map.exceptions 'logged_exceptions/:action/:id', :controller => 'logged_exceptions', :action => 'index', :id => nil
end
