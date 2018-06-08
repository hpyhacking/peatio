# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Sessions, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:session_utils) { Class.new { include SessionUtils }.new }
  after { session_utils.destroy_member_sessions(member.id) }

  describe 'POST /sessions' do
    context 'when no token provided' do
      it 'requires authentication' do
        api_post '/api/v2/sessions'
        expect(response.code).to eq '401'
      end
    end

    context 'invalid JWT' do
      let(:token) { jwt_for(member, exp: 10.minutes.ago.to_i) }

      it 'validates JWT and denies access as usual' do
        api_post '/api/v2/sessions'
        expect(response.code).to eq '401'
      end
    end

    it 'saves session in Redis' do
      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
    end

    it 'resets any previous sessions' do
      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1

      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
    end

    it 'created session which is usable with Rails controllers' do
      api_post '/api/v2/sessions', token: token
      expect(response.code).to eq '201'
      expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
      get '/markets/' + Market.enabled.first.id + '.json', nil, 'Cookie' => response.headers['Set-Cookie']
      expect(response.code).to eq '200'
      expect { JSON.parse(response.body) }.to_not raise_error
    end

    context 'token expiring in 60 seconds' do
      let(:token) { jwt_for(member, exp: 60.seconds.from_now.to_i) }

      before do
        Redis::Store.any_instance.expects(:set).at_least_once.with do |key, value, options|
          options[:expire_after] >= 55 && options[:expire_after] <= 60 # Add a little leeway.
        end
      end

      it 'saves session in Redis with TTL of 60 seconds' do
        api_post '/api/v2/sessions', token: token
        expect(response.code).to eq '201'
      end
    end
  end

  describe 'DELETE /sessions' do
    context 'without token' do
      it 'requires authentication' do
        api_delete '/api/v2/sessions'
        expect(response.code).to eq '401'
      end
    end

    context 'with valid token' do
      it 'deletes all session from Redis storage' do
        def sid; response.cookies.fetch('_peatio_session'); end

        session_ids = []
        redis       = Rails.cache.instance_variable_get(:@data)

        # Step 1: Establish user session (but not authenticated).
        get '/funds'
        session_utils.memoize_member_session_id(member.id, sid) # This saves user SID in Redis. Check SessionsController#create for the details.
        expect(response.status).to eq 302 # Redirects to index with flash: "Please, sign in to see this page".

        # Mock member ID directly in session store.
        session = redis.get(sid)
        session_utils.memoize_member_session_id(member.id, sid)
        session_ids << sid
        session['member_id'] = member.id
        redis.set(sid, session)

        # Check that worked.
        get '/funds'
        expect(response.status).to eq 200 # OK. We are really signed in.
        session_utils.memoize_member_session_id(member.id, sid)
        session_ids << sid

        # Again, ensure data really exists at Redis.
        expect(session_ids.map { |sid| redis.get(sid) }.count).to eq session_ids.count
        expect(redis.keys("peatio:sessions:#{member.id}:*")).to_not be_empty

        # Finally, ask API to destroy session.
        api_delete '/api/v2/sessions', token: token
        expect(response.code).to eq '200'

        # Ensure all session stuff is destroyed.
        expect(session_ids.map { |sid| redis.get(sid) }.compact).to be_empty
        expect(redis.keys("peatio:sessions:#{member.id}:*")).to be_empty
      end
    end

    context 'without session established' do
      it 'doesn\'t not fail' do
        api_delete '/api/v2/sessions', token: token
        expect(response.code).to eq '200'
      end
    end
  end

  it 'allows to create and destroy session' do
    api_post '/api/v2/sessions', token: token
    expect(response.code).to eq '201'
    expect(session_utils.fetch_member_session_ids(member.id).count).to be 1
    api_delete '/api/v2/sessions', token: token
    expect(response.code).to eq '200'
    expect(session_utils.fetch_member_session_ids(member.id).count).to be 0
  end
end
