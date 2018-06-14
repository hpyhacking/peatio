# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Withdraws < Grape::API
    helpers APIv2::NamedParams

    before { authenticate! }
    before { withdraws_must_be_permitted! }

    desc 'List your withdraws as paginated collection.', scopes: %w[ history ]
    params do
      optional :currency, type: String,  values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { "Any supported currencies: #{Currency.enabled.codes(bothcase: true).join(',')}." }
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
    end
    get '/withdraws' do
      currency = Currency.find(params[:currency]) if params[:currency].present?

      current_user
        .withdraws
        .order(id: :desc)
        .tap { |q| q.where!(currency: currency) if currency }
        .includes(:currency)
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: APIv2::Entities::Withdraw }
    end
  end
end
