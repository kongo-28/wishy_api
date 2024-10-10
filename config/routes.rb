Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :wishes
  resources :likes, only: [:create]
  resources :chats, only: [:index ,:create]do
    collection do
      post 'candidate'
    end
  end
  resources :users, only: [:index, :show] do
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
