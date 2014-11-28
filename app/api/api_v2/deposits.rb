module APIv2
  class Deposits < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get your deposits information'
    params do
      use :auth
      requires :currency, type: String, values: Currency.all.map(&:code)
    end
    get "/deposits" do
      authenticate!
      present current_user.deposits.with_currency(params[:currency]), with: APIv2::Entities::Deposit
    end
  end
end
