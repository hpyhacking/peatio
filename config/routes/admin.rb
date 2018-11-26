# encoding: UTF-8
# frozen_string_literal: true

namespace :admin do
  get '/', to: 'dashboard#index', as: :dashboard

  resources :markets, except: %i[edit destroy]
  resources :currencies, except: %i[edit destroy]
  resources :blockchains, except: %i[edit destroy]
  resources :wallets, except: %i[edit destroy] do
    post :show_client_info, on: :collection
  end

  resources :members, only: %i[index show] do
    member do
      post :active
      post :toggle
    end
  end

  resources 'deposits/:currency',  to: AdminDepositsRouter.new,  as: 'deposit'
  resources 'withdraws/:currency', to: AdminWithdrawsRouter.new, as: 'withdraw'

  resources :balance_sheet, only: %i[index]
  %i[liability asset revenue expense].each do |type|
    get "operations/#{type.to_s.pluralize}/(:currency)",
      to: AdminOperationsRouter.new(type),
      as: "#{type}_operations"
  end
end
