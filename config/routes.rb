require 'sidekiq/web'
Rails.application.routes.draw do
  post '/rate' => 'rater#create', :as => 'rate'
  mount Sidekiq::Web => '/sidekiq'
  mount Resque::Server, :at => "/resque"
  resources :histories

  post 'functions/show_device'

  post 'functions/update_device'

  post 'functions/show_history'

  post 'functions/show_tracking'

  post 'functions/send_command'

  post 'functions/update_device_config'

  post  'functions/get_storyInfo'

  post 'functions/get_userInfo'

  post 'functions/activate_device'

  post 'functions/bind_device'

  post 'functions/send_voice_file'

  post 'functions/voice_file_list'

  get 'functions/play_voice_file'

  post 'functions/baby_health_info'

  post 'functions/flower_reward'

  resources :user_devices

  namespace :admin do
    resources :manage_users
  end

  namespace :admin do
    resources :logins, only: [:new, :create, :destroy]
    get 'logins/activate_socket'
    root 'logins#new'
  end

  resources :devices

  resources :users

  get 'auths/send_captcha'

  post 'auths/check_captcha'

  post 'auths/register'

  post 'auths/check_device'

  post 'auths/login'

  post 'auths/reset_password'

  post 'auths/is_registered'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

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
