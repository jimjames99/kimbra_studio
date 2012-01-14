KimbraStudio::Application.routes.draw do

  resources :studios

  devise_for :users

  resources :users

  match 'admin' => 'admin/overviews#index'
  match 'login' => 'user_sessions#new'
  match 'logout' => 'user_sessions#destroy'
  match 'signup' => 'studio/registrations#new'

  root :to => "welcome#index"

  resources :countries

  resources :states, :only => [:index]
  resource :about, :only => [:show]
  resources :terms, :only => [:index]

  resources :categories

  namespace :admin do
    namespace :customer do
      resources :emails do
        resources :offers
      end
    end
    namespace :merchandise do
      resources :pieces
    end
  end

  namespace :my_studio do
    resources :clients
    resources :sessions do
      resources :portraits
    end
    resource :overview, :only => [:show]
  end

  namespace :studio do
    resources :registrations, :only => [:new, :create]
    resources :addresses
    resources :users
    resources :clients
    resources :shoots do
      resources :pictures
    end
    resource :overview, :only => [:show]
  end

end
