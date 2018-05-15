# encoding: UTF-8
# frozen_string_literal: true

namespace :admin do
  get '/', to: 'dashboard#index', as: :dashboard

  resources :proofs
  resources :markets, except: %i[edit destroy]
  resources :currencies, except: %i[edit destroy]

  resources :members, only: %i[index show] do
    member do
      post :active
      post :toggle
    end
  end

  resources 'deposits/:currency',  to: AdminDepositsRouter.new,  as: 'deposit'
  resources 'withdraws/:currency', to: AdminWithdrawsRouter.new, as: 'withdraw'
end
