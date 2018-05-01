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

    desc '[DEPRECATED] Create withdraw.', scopes: %w[ withdraw ]
    params do
      requires :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: -> { "Any supported currency: #{Currency.codes(bothcase: true).join(',')}." }
      requires :amount,   type: BigDecimal, desc: 'Withdraw amount without fees.'
      requires :rid,      type: String, desc: 'The shared recipient ID.'
    end
    post '/withdraws' do
      currency = Currency.find_by!(code: params[:currency])
      withdraw = "withdraws/#{currency.type}".camelize.constantize.new \
        rid:       params[:rid],
        sum:       params[:amount],
        member_id: current_user.id,
        currency:  currency
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
