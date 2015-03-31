module APIv2
  class Deposits < Grape::API
    helpers ::APIv2::NamedParams

    before { authenticate! }

    desc 'Get your deposits history.'
    params do
      use :auth
      optional :currency, type: String, values: Currency.all.map(&:code), desc: "Currency value contains  #{Currency.all.map(&:code).join(',')}"
    end
    get "/deposits" do
      deposits = current_user.deposits.one_day.recent
      deposits = deposits.with_currency(params[:currency]) if params[:currency]

      present deposits, with: APIv2::Entities::Deposit
    end

    desc 'Get details of specific deposit.'
    params do
      use :auth
      requires :txid
    end
    get "/deposit" do
      deposit = current_user.deposits.find_by(txid: params[:txid])
      raise DepositByTxidNotFoundError, params[:txid] unless deposit

      present deposit, with: APIv2::Entities::Deposit
    end

    desc 'Where to deposit. The address field could be empty when a new address is generating (e.g. for bitcoin), you should try again later in that case.'
    params do
      use :auth
      requires :currency, type: String, values: Currency.all.map(&:code), desc: "The account to which you want to deposit. Available values: #{Currency.all.map(&:code).join(', ')}"
    end
    get "/deposit_address" do
      current_user.ac(params[:currency]).payment_address.to_json
    end
  end
end
