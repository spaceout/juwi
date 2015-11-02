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
  get 'xbmc' => 'xbmc#index'
  post 'xbmc/play/:id' => 'xbmc#play', as: 'xbmc_play'
  root :to => 'home#index'
  get 'upload_torrent' => 'home#upload_torrent'
  post 'xbmc_update' => 'xbmc#update_library'
  get 'ttdbsearch', to: 'home#ttdbsearch', as: 'ttdbsearch'
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
end
