require 'market_constraint'
require 'whitelist_constraint'

Rails.application.eager_load! if Rails.env.development?

Peatio::Application.routes.draw do

  root 'welcome#index'

  if Rails.env.development?
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
    resource :two_factor,  only: [:new, :create]
    resources :sms_tokens, only: [:new, :create]
  end

  scope :constraints => { id: /[a-zA-Z0-9]{32}/ } do
    resources :reset_passwords
    resources :activations, only: [:new, :edit, :update]
  end

  get '/documents/api_v2'
  get '/documents/websocket_api'
  resources :documents, only: [:show]
  resources :refresh_two_factors, only: [:show]

  scope module: 'private' do
    resource  :id_document, only: [:new, :create]

    resources :settings, only: [:index]
    resources :two_factors, only: [:show, :update, :edit, :destroy]
    resources :deposits, only: [:index, :destroy, :update]
    namespace :deposits do
      Deposit.descendants.each do |d|
        resources d.resource_name
      end
    end

    resources :withdraws, except: [:new]
    namespace :withdraws do
      Withdraw.descendants.each do |w|
        resources w.resource_name
      end
    end

    resources :account_versions, :only => :index

    resources :fund_sources, :only => [:index, :destroy]
    resources :exchange_assets, :controller => 'assets' do
      member do
        get :partial_tree
      end
    end

    get '/history/orders' => 'history#orders', as: :order_history
    get '/history/trades' => 'history#trades', as: :trade_history
    get '/history/account' => 'history#account', as: :account_history

    resources :markets, :only => :show, :constraints => MarketConstraint do
      resources :orders, :only => [:index, :destroy]
      resources :order_bids, :only => [:create]
      resources :order_asks, :only => [:create]
    end

    post '/pusher/auth', to: 'pusher#auth'
  end

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :documents
    resource :currency_deposit, :only => [:new, :create]
    resources :members, :only => [:index, :show, :update]
    resources :proofs

    namespace :deposits do
      Deposit.descendants.each do |d|
        resources d.resource_name
      end
    end

    namespace :withdraws do
      Withdraw.descendants.each do |w|
        resources w.resource_name
      end
    end

    namespace :statistic do
      resource :members, :only => :show
      resource :orders, :only => :show
      resource :trades, :only => :show
      resource :deposits, :only => :show
      resource :withdraws, :only => :show
    end
  end

  constraints(WhitelistConstraint.new(JSON.parse(Figaro.env.try(:api_whitelist) || '[]'))) do
    namespace :api, defaults: {format: 'json'}, :constraints => MarketConstraint do
      scope module: :v1 do
        resources :deeps, :only => :show
        resources :trades, :only => :show
        resources :tickers, :only => :show
        resources :prices, :only => :show
      end
    end
  end

  get '/forum' => 'forum#index'

  mount APIv2::Mount => '/'

end
