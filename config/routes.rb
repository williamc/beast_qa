ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'forums', :action => 'index'

  map.resources :sessions
  
  map.resources :users, :member => { :admin => :post } do |user|
    user.resources :moderators
  end
  
  map.resources :forums do |forum|
    forum.resources :topics do |topic|
      topic.resources :posts, :monitorships
    end
  end

  map.resources :posts, :name_prefix => 'all_'

  %w(user forum).each do |attr|
    map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
  end

  map.signup   '/signup',        :controller => 'users',    :action => 'new'
  map.settings '/settings',      :controller => 'users',    :action => 'edit'
  map.activate '/activate/:key', :controller => 'users',    :action => 'activate'
  map.login    '/login',         :controller => 'sessions', :action => 'new'
  map.logout   '/logout',        :controller => 'sessions', :action => 'destroy'
  map.with_options :controller => 'posts', :action => 'monitored' do |map|
    map.formatted_monitored_posts '/users/:user_id/monitored.:format'
    map.monitored_posts           '/users/:user_id/monitored'
  end

  map.exceptions '/logged_exceptions/:action/:id', :controller => 'logged_exceptions', :action => 'index', :id => nil
end