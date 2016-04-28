Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :todos
  resources :posts
  resources :activities do
    resources :comments
    
    member do 
      get 'my_activities'
      get 'user_details'
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'activities#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'activities/:id' => 'activities#activity'

  get '/finish_activity' => 'activities#finish_activity', as: :finish_activity

  get '/quit_experiment' => 'rewards#quit_experiment'

  get '/start_tetris' => 'rewards#start_tetris'

  # get '/finish_activity' => 'activities#set_activity_id', as: :set_activity_id
  get '/activity_detail/:id' => 'activities#get_activity_detail', as: :get_activity_detail

  get '/start_activity/:id' => 'activities#start_activity', as: :start_activity

  get '/abort_activity/:id' => 'activities#abort_activity', as: :abort_activity

  # secret admin code to set user as an admin
  get '/enable_admin/:code' => 'activities#enable_admin' 

  # set all default activities with admin's current activities
  get '/set_default_activities' => 'activities#set_default_activities', as: :set_default_activities

  get '/export_data' => 'activities#export_data', as: :export_data


  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
