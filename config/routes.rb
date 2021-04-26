Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'submissions/received'
  get 'submissions/duplicate'
  get 'sessions/new'
  get 'contact' => "test#contact"
  get 'documentation' => "test#documentation"
	post '/feedback' => 'submissions#feedback'
  resources :users
  resources :questions, only: [:new, :create, :edit, :update, :destroy, :show]
  resources :assessments
  resources :submissions, only: [:new, :create, :edit, :update, :destroy, :show]
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  get 'index' => "test#index"
  root 'test#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
	match '*path' => redirect('/'), via: :get
end


