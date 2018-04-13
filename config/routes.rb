# Explicitly require "lib/peatio.rb".
# You may be surprised why this line also sits in config/application.rb.
# The same line sits in config/application.rb to allows early access to lib/peatio.rb.
# We duplicate line in config/routes.rb since routes.rb is reloaded when code is changed.
# The implementation of ActiveSupport's require_dependency makes sense to use it only in reloadable files.
# That's why it is here.
require_dependency 'peatio'

Dir['app/models/deposits/**/*.rb'].each { |x| require_dependency x.split('/')[2..-1].join('/') }
Dir['app/models/withdraws/**/*.rb'].each { |x| require_dependency x.split('/')[2..-1].join('/') }

class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Peatio::Application.routes.draw do

  root 'welcome#index'

  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure', :as => :failure
  match '/auth/:provider/callback' => 'sessions#create', via: %i[get post]

  scope module: :private do
    resources :settings, only: [:index]

    resources :withdraw_destinations, only: %i[ create update ]

    resources :funds, only: [:index] do
      collection do
        post :gen_address
      end
    end

    resources 'deposits/:currency', controller: 'deposits', as: 'deposit', only: %i[ destroy ] do
      collection { post 'gen_address' }
    end

    resources 'withdraws/:currency', controller: 'withdraws', as: 'withdraw', only: %i[ create destroy ]

    resources :account_versions, only: :index

    resources :exchange_assets, controller: 'assets'

    get '/history/orders' => 'history#orders', as: :order_history
    get '/history/trades' => 'history#trades', as: :trade_history
    get '/history/account' => 'history#account', as: :account_history

    resources :markets, only: [:show], constraints: MarketConstraint do
      resources :orders, only: %i[ index destroy ] do
        collection do
          post :clear
        end
      end
      resources :order_bids, only: [:create] do
        collection do
          post :clear
        end
      end
      resources :order_asks, only: [:create] do
        collection do
          post :clear
        end
      end
    end

    post '/pusher/auth', to: 'pusher#auth'
  end

  get 'trading/:market_id', to: BlackHoleRouter.new, as: :trading

  scope ['', 'webhooks', ENV['WEBHOOKS_SECURE_URL_COMPONENT'].presence, ':ccy'].compact.join('/'), as: 'webhooks' do
    post 'tx_created', to: 'webhooks#tx_created'
  end

  draw :admin

  get '/swagger', to: 'swagger#index'

  mount APIv2::Mount => APIv2::Mount::PREFIX
  mount ManagementAPIv1::Mount => ManagementAPIv1::Mount::PREFIX
end
