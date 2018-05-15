# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Sessions < Grape::API
    helpers { include SessionUtils }

    before { authenticate! }

    use ActionDispatch::Session::RedisStore, \
        key:          '_peatio_session',
        expire_after: ENV.fetch('SESSION_LIFETIME').to_i

    helpers do
      def session
        env.fetch('rack.session')
      end
    end

    desc 'Create new user session.'
    post '/sessions' do
      session.destroy # This is used here to initialize SID.
      destroy_member_sessions(current_user.id)

      # We assume everything is OK with authentication.
      jwt = JSON.parse(JWT::Decode.base64url_decode(headers['Authorization'].split('.')[1]))
      session_lifetime = jwt['exp'].to_i - Time.now.to_i

      if session_lifetime > 0
        env['api_v2.session_lifetime'] = session_lifetime
        session[:member_id] = current_user.id
        memoize_member_session_id(current_user.id, session.id, expire_after: session_lifetime)
        status 201
      else
        status 422
      end
    end

    desc 'Delete all user sessions.'
    delete '/sessions' do
      session.destroy
      destroy_member_sessions(current_user.id)
      status 200
    end
  end
end
