require 'resque/server'
require 'market_constraint'
require 'whitelist_constraint'

Peatio::Application.routes.draw do
  if Rails.env == 'development'
    mount Resque::Server.new, :at => "/jobs"
    mount MailsViewer::Engine => '/mails'
  end

  get '/signin' => 'sessions#new', :as => :signin
  get '/signup' => 'identities#new', :as => :signup
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure', :as => :failure
  post '/auth/identity/callback' => 'sessions#create'

  resource :member, :only => [:edit, :update]
  resource :identity, :only => [:edit, :update]

  namespace :verify do
    resource :two_factor, :only => [:new, :create]
  end

  scope :constraints => { id: /[a-zA-Z0-9]{32}/ } do
    resources :reset_passwords
    resources :reset_two_factors
    resources :activations, only: [:new, :edit, :update]
  end

  resources :documents, :only => :show

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :withdraws
    resources :documents
    resource :currency_deposit, :only => [:new, :create]
    resources :members, :only => [:index, :show, :update]

    namespace :statistic do
      resource :members, :only => :show
      resource :orders, :only => :show
      resource :trades, :only => :show
      resource :deposits, :only => :show
      resource :withdraws, :only => :show
    end
  end

  scope module: 'private' do
    get '/settings', to: 'settings#index', as: :settings
    resource :id_document, :only => [:new, :create]
    resource :two_factor, :only => [:new, :create, :edit, :destroy]

    resources :deposits, :only => :index do
      collection do
        get :coin
        get :bank
      end
    end

    resources :withdraws
    resources :withdraw_addresses, :only => [:index, :destroy]
    resources :account_versions, :only => :index

    resources :exchange_assets, :controller => 'assets' do
      member do
        get :partial_tree
      end
    end

    resources :markets, :only => :show, :constraints => MarketConstraint do
      resources :orders, :only => [:index, :destroy]
      resources :order_bids, :only => [:create]
      resources :order_asks, :only => [:create]
    end
  end

  get 'payment_transaction/:currency/:txid', to: 'payment_transaction#create'

  scope module: 'private' do
    post '/pusher/auth', to: 'pusher#auth'
  end

  constraints(WhitelistConstraint.new(JSON.parse(Figaro.env.try(:api_whitelist) || '[]'))) do
    namespace :api, defaults: {format: 'json'}, :constraints => MarketConstraint do
      scope module: :v1 do
        resources :deeps, :only => :show
        resources :trades, :only => :show
        resources :tickers, :only => :show
      end
    end
  end
  
  root 'welcome#index'
end
