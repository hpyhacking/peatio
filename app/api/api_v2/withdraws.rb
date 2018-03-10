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

    desc 'List your withdraw destinations as paginated collection.', scopes: %w[ history ]
    params do
      optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: -> { "Any supported currency: #{Currency.codes(bothcase: true).join(',')}." }
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
    end
    get '/withdraws/destinations' do
      current_user
        .withdraw_destinations
        .order(id: :desc)
        .tap { |q| q.where!(currency: Currency.find_by!(code: params[:currency])) if params[:currency].present? }
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: APIv2::Entities::WithdrawDestination }
    end

    desc 'Create withdraw destination.', scopes: %w[ withdraw ]
    params do
      requires :currency, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'Currency code. Both upcase (BTC) and downcase (btc) are supported.'
      requires :label,    type: String, desc: 'The label associated with withdraw destination.'
      %w[ Fiat Coin ].each do |type|
        "WithdrawDestination::#{type}".constantize.fields.each { |key, desc| optional key, desc: desc }
      end
    end
    post '/withdraws/destinations' do
      ccy = Currency.find_by(code: params[:currency])
      next status 422 unless ccy

      klass    = "withdraw_destination/#{ccy.type}".camelize.constantize
      record   = klass.new({ member: current_user, currency: ccy }.merge!(params.slice(:label, *klass.fields.keys)))
      if record.save
        present record, with: APIv2::Entities::WithdrawDestination
      else
        body errors: record.errors.full_messages
        status 422
      end
    end

    desc 'Delete withdraw destination.', scopes: %w[ withdraw ]
    delete '/withdraws/destinations/:id' do
      record = WithdrawDestination.find(params[:id])

      if record.destroy
        status 200
      else
        status 422
      end
    end

    desc 'Create withdraw.', scopes: %w[ withdraw ]
    params do
      requires :currency,       type: String,  values: -> { Currency.codes(bothcase: true) }, desc: -> { "Any supported currency: #{Currency.codes(bothcase: true).join(',')}." }
      requires :amount,         type: BigDecimal, desc: 'Withdraw amount without fees.'
      requires :destination_id, type: Integer, desc: 'Stored withdraw destination ID. You should create withdraw destination before.'
    end
    post '/withdraws' do
      currency = Currency.find_by!(code: params[:currency])
      withdraw = "withdraws/#{currency.key}".camelize.constantize.new \
        destination_id: params[:destination_id],
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
