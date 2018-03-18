describe APIv2::Sessions, type: :request do
  let(:member) { create(:member, :verified_identity) }
  let(:token) { jwt_for(member) }
  let(:session_utils) { Class.new { include SessionUtils }.new }

  describe 'DELETE /sessions' do
    context 'without token'
      it 'should require authentication' do
        api_delete '/api/v2/sessions'
        expect(response.code).to eq '401'
      end

    context 'with valid token' do
      it 'should delete all session from redis storage' do
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
      it 'should not fail' do
        api_delete '/api/v2/sessions', token: token
        expect(response.code).to eq '200'
      end
    end
  end
end
