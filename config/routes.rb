Rails.application.routes.draw do
  root 'activities#index'

  devise_for :users, :controllers => { registrations: 'registrations' }

  resources :todos
  resources :posts
  resources :activities do
    resources :comments

    collection do
      post :abandon_activity
    end

    member do
      get 'my_activities'
      get 'user_details'
      get 'by_code'
    end
  end

  resources :answers, only: :create

  namespace :admin do
    resources :answers, only: :index
  end

  get 'activities/:id' => 'activities#activity'

  # delete activity with activity ID
  get 'delete_activity/:id' => 'activities#delete_activity', as: :delete_activity
  get '/quit_experiment' => 'rewards#quit_experiment'
  get '/start_tetris' => 'rewards#start_tetris'
  get '/activity_detail/:id' => 'activities#get_activity_detail', as: :get_activity_detail
  post '/start_activity/:id' => 'activities#start_activity', as: :start_activity
  get '/abort_activity/:id' => 'activities#abort_activity', as: :abort_activity

  # secret admin code to set user as an admin
  get '/enable_admin/:code' => 'activities#enable_admin' 

  # set all default activities with admin's current activities
  get '/set_default_activities' => 'activities#set_default_activities', as: :set_default_activities
  get '/export_data' => 'activities#export_data', as: :export_data
  get '/export_user_data' => 'activities#export_user_data', as: :export_user_data
  get '/generate_code/' => 'activities#generate_code', as: :generate_code
  post '/submit_text/' => 'activities#submitText', as: :submitText
end
