module APIv2
  class Withdraws < Grape::API
    before { authenticate! }

    desc 'List your withdraws as paginated collection.', scopes: %w[ history ]
    params do
      currencies = Currency.all.map(&:code).map(&:upcase)
      optional :currency, type: String,  values: currencies + currencies.map(&:downcase), desc: "Any supported currencies: #{currencies.join(',')}."
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
    end
    get '/withdraws' do
      current_user
        .withdraws
        .order(id: :desc)
        .tap { |q| q.where!(currency: params[:currency].downcase) if params[:currency] }
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: APIv2::Entities::Withdraw }
    end
  end
end
