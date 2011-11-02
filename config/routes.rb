Massfollow::Application.routes.draw do
  get "twitter/index"
  
  match "/auth/twitter/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  
  controller :sessions do
    delete 'logout' => :destroy
  end
  
  match "/twitter/search" => "twitter#search", :as => "search"
  match "/twitter/follow" => "twitter#follow", :as => "follow_user"
  match "/twitter/unfollow" => "twitter#unfollow", :as => "unfollow_user"
  match "/twitter/logout" => "twitter#logout", :as => "logout_user"

  root :to => 'twitter#index'
end
