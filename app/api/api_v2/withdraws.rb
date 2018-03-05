module APIv2
  class Withdraws < Grape::API
    helpers APIv2::NamedParams

    before { authenticate! }
    before { identity_must_be_verified! }

    desc 'List your withdraws as paginated collection.', scopes: %w[ history ]
    params do
      optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: -> { "Any supported currencies: #{Currency.codes(bothcase: true).join(',')}." }
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
    end
    get '/withdraws' do
      if params[:currency].present?
        currency = Currency.find_by!(code: params[:currency])
      end

      current_user
        .withdraws
        .order(id: :desc)
        .tap { |q| q.where!(currency: currency) if currency }
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: APIv2::Entities::Withdraw }
    end

    desc 'List your withdraw addresses as paginated collection.', scopes: %w[ history ]
    params do
      optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: -> { "Any supported currency: #{Currency.codes(bothcase: true).join(',')}." }
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
    end
    get '/withdraws/addresses' do
      current_user
        .fund_sources
        .order(id: :desc)
        .tap { |q| q.where!(currency: Currency.find_by!(code: params[:currency])) if params[:currency].present? }
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: APIv2::Entities::WithdrawAddress }
    end

    desc 'Create withdraw address.', scopes: %w[ withdraw ]
    params do
      requires :currency, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'Currency code. Both upcase (BTC) and downcase (btc) are supported.'
      requires :label,    type: String, desc: 'The label associated with wallet.'
      requires :address,  type: String, desc: 'The destination wallet address.'
    end
    post '/withdraws/addresses' do
      currency = Currency.find_by!(code: params[:currency])
      order = FundSource.create! \
        member_id:  current_user.id,
        currency:   currency,
        extra:      params[:label],
        uid:        params[:address]
      present order, with: APIv2::Entities::WithdrawAddress
    end

    desc 'Delete withdraw address.', scopes: %w[ withdraw ]
    delete '/withdraws/addresses/:id' do
      withdraw_address = FundSource.find(params[:id])

      if withdraw_address.destroy
        status 200
      else
        status 422
      end
    end

    desc 'Create withdraw.', scopes: %w[ withdraw ]
    params do
      requires :currency,   type: String,  values: -> { Currency.codes(bothcase: true) }, desc: -> { "Any supported currency: #{Currency.codes(bothcase: true).join(',')}." }
      requires :amount,     type: BigDecimal, desc: 'Withdraw amount without fees.'
      requires :address_id, type: Integer, desc: 'Stored withdraw address ID. You should create withdraw address before.'
    end
    post '/withdraws' do
      currency = Currency.find_by!(code: params[:currency])
      withdraw = "withdraws/#{currency.key}".camelize.constantize.new \
        fund_source_id: params[:address_id],
        sum:            params[:amount],
        member_id:      current_user.id,
        currency:       currency

      if withdraw.save
        withdraw.submit!
        present withdraw, with: APIv2::Entities::Withdraw
      else
        body errors: withdraw.errors.full_messages
        status 422
      end
    end
  end
end
