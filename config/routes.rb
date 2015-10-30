Juwi::Application.routes.draw do

  resources :torrents do
    get :active
    member do
      post :remove
      post :start
      post :stop
      resources :tfiles do
        member do
          post :rename
        end
      end
    end
  end

  resources :name_deviations

  match 'update' => 'home#update'
  match 'episodes' => 'episodes#all'
  match 'episodes/missing' => 'episodes#missing'
  match 'episodes/recently_aired' => 'episodes#recently_aired'
  match "episodes/:episode_id" => 'episodes#show2'
  resources :tvshows  do
    collection do
      get :forcast
      get :recently_canceled
    end
    resources :episodes, :only => [:index, :show]
    resources :name_deviations
    get :missing
  end
  resources :settings
  root :to => 'home#index'
  match 'rename' => 'home#rename'
  match 'start_daemon' => 'daemons#start_daemon'
  match 'stop_daemon' => 'daemons#stop_daemon'
  match 'upload_torrent' => 'home#upload_torrent'
  match 'xbmc_update' => 'home#xbmc_update'
  match 'process_downloads' => 'home#process_downloads'
  get 'ttdbsearch', to: 'home#ttdbsearch', as: 'ttdbsearch'
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
end
