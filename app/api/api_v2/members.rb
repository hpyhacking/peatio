module APIv2
  class Members < Grape::API

    desc 'Get your profile and accounts info.'
    get "/members/me" do
      authenticate!
      present current_user, with: APIv2::Entities::Member
    end

  end
end
