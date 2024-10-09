Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :wishes
  resources :likes, only: [:create]
  resources :users, only: [:index, :show] do
    collection do
      get 'action'
      post 'action_plan'
      get 'candidate'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
