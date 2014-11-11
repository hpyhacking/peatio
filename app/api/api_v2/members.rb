module APIv2
  class Members < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get your profile and accounts info.', scopes: %w(profile)
    params do
      use :auth
    end
    get "/members/me" do
      authenticate!
      present current_user, with: APIv2::Entities::Member
    end

  end
end
