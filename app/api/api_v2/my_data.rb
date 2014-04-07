module APIv2
  class MyData < Grape::API

    desc 'Get your profile and accounts info.'
    get "/my/info" do
      present current_user, with: APIv2::Entities::Member
    end

  end
end
