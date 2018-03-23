module APIv2
  class Solvency < Grape::API

    before { authenticate! }

    desc 'Returns newest liability proof record for given currency.'
    params do
      requires :currency, type: String, values: -> { Currency.coin_codes(bothcase: true) }, desc: "The code of any currency with type 'coin'."
    end
    get '/solvency/liability_proofs/latest' do
      Proof
        .current(params[:currency])
        .tap { |p| present p, with: APIv2::Entities::Solvency::Proof }
    end

    desc 'Returns newest partial tree record for member account of specified currency.'
    params do
      requires :currency, type: String, values: -> { Currency.coin_codes(bothcase: true) }, desc: "The code of any currency with type 'coin'."
    end
    get '/solvency/liability_proofs/partial_tree/mine' do
      current_user
        .get_account(params[:currency])
        .partial_trees
        .first
        .tap { |p| present p, with: APIv2::Entities::Solvency::PartialTree }
    end
  end
end
