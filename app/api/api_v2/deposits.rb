module APIv2
  class Deposits < Grape::API
    helpers ::APIv2::NamedParams

    before { authenticate! }

    desc 'Get your deposits information'
    params do
      use :auth
      optional :currency, type: String, values: Currency.all.map(&:code), desc: "Currency value contains  #{Currency.all.map(&:code).join(',')}"
    end
    get "/deposits" do
      deposits = current_user.deposits.one_day.recent
      deposits = deposits.with_currency(params[:currency]) if params[:currency]

      present deposits, with: APIv2::Entities::Deposit
    end

    desc 'Get single deposit information'
    params do
      use :auth
      requires :txid
    end
    get "/deposit" do
      deposit = current_user.deposits.find_by(txid: params[:txid])
      raise DepositByTxidNotFoundError, params[:txid] unless deposit

      present deposit, with: APIv2::Entities::Deposit
    end

  end
end
