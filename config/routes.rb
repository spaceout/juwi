Juwi::Application.routes.draw do
  match 'update' => 'home#update'
  match 'episodes' => 'all_episodes#index'
  match 'episodes/missing' => 'all_episodes#missing'
  
  match 'episodes/recently_aired' => 'all_episodes#recently_aired'
  match "episodes/:episode_id" => 'all_episodes#show'
  resources :tvshows, :only => [:index, :show] do
    collection do
      get :forcast
      get :recently_canceled
    end
    resources :episodes, :only => [:index, :show]
    get :missing
  end
  resources :settings, :only => [:index, :show, :edit, :update]  do
    collection do

    end
  end
  root :to => 'home#index'
  match 'rename' => 'home#rename'
  match 'startDaemon' => 'home#startDaemon'
  match 'stopDaemon' => 'home#stopDaemon'
  match 'upload_torrent' => 'home#upload_torrent'
  match 'xbmc_update' => 'home#xbmc_update'
  match 'process_downloads' => 'home#process_downloads'
end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
