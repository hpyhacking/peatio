module APIv2
  class Sessions < Grape::API
    helpers { include SessionUtils }

    before { authenticate! }

    desc 'Delete all user sessions.'
    delete '/sessions' do
      destroy_member_sessions(current_user.id)
      status 200
    end
  end
end
