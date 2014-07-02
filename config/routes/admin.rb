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
