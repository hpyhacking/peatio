module APIv2
  class Deposits < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get your deposits information'
    params do
      use :auth
    end
    get "/deposits" do
      authenticate!
      present current_user.deposits, with: APIv2::Entities::Deposit
    end
  end
end