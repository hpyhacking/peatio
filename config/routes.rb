Rails.application.eager_load! if Rails.env.development?

class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Peatio::Application.routes.draw do
  use_doorkeeper

  root 'welcome#index'

  if Rails.env.development?
    mount MailsViewer::Engine => '/mails'
  end

  get '/signin' => 'sessions#new', :as => :signin
  get '/signup' => 'identities#new', :as => :signup
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure', :as => :failure
  match '/auth/:provider/callback' => 'sessions#create', via: [:get, :post]

  resource :member, :only => [:edit, :update]
  resource :identity, :only => [:edit, :update]

  namespace :verify do
    resource :sms_auth,    only: [:show, :update]
    resource :google_auth, only: [:show, :update, :edit, :destroy]
  end

  namespace :authentications do
    resources :emails, only: [:new, :create]
    resources :identities, only: [:new, :create]
    resource :weibo_accounts, only: [:destroy]
  end

  scope :constraints => { id: /[a-zA-Z0-9]{32}/ } do
    resources :reset_passwords
    resources :activations, only: [:new, :edit, :update]
  end

  get '/documents/api_v2'
  get '/documents/websocket_api'
  get '/documents/oauth'
  resources :documents, only: [:show]
  resources :two_factors, only: [:show, :index, :update]

  scope module: :private do
    resource  :id_document, only: [:edit, :update]

    resources :settings, only: [:index]
    resources :api_tokens do
      member do
        delete :unbind
      end
    end

    resources :fund_sources, only: [:create, :update, :destroy]

    resources :funds, only: [:index] do
      collection do
        post :gen_address
      end
    end

    namespace :deposits do
      Deposit.descendants.each do |d|
        resources d.resource_name do
          collection do
            post :gen_address
          end
        end
      end
    end

    namespace :withdraws do
      Withdraw.descendants.each do |w|
        resources w.resource_name
      end
    end

    resources :account_versions, :only => :index

    resources :exchange_assets, :controller => 'assets' do
      member do
        get :partial_tree
      end
    end

    get '/history/orders' => 'history#orders', as: :order_history
    get '/history/trades' => 'history#trades', as: :trade_history
    get '/history/account' => 'history#account', as: :account_history

    resources :markets, :only => :show, :constraints => MarketConstraint do
      resources :orders, :only => [:index, :destroy] do
        collection do
          post :clear
        end
      end
      resources :order_bids, :only => [:create] do
        collection do
          post :clear
        end
      end
      resources :order_asks, :only => [:create] do
        collection do
          post :clear
        end
      end
    end

    post '/pusher/auth', to: 'pusher#auth'

    resources :tickets, only: [:index, :new, :create, :show] do
      member do
        patch :close
      end
      resources :comments, only: [:create]
    end
  end

  draw :admin

  mount APIv2::Mount => APIv2::Mount::PREFIX

end
