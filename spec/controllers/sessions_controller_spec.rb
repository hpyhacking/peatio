describe SessionsController, type: :controller do
  %i[ google_oauth2 auth0 barong ].each do |provider|
    normalized_provider = provider.to_s.gsub(/(?:_|oauth2)+\z/i, '')

    describe "sign in using #{provider} provider" do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider]
      end

      after do
        request.env['omniauth.auth'] = nil
      end

      it 'should successfully create a member' do
        expect {
          post :create, provider: provider
        }.to change { Member.count }.by(1)
      end

      it 'should successfully create a session' do
        expect(session[:member_id]).to be_nil
        post :create, provider: provider
        expect(session[:member_id]).to_not be_nil
      end

      context 'when no redirect URL is specified' do
        before { ENV.delete("#{normalized_provider.upcase}_OAUTH2_REDIRECT_URL") }

        it 'should redirect the member to the settings URL' do
          post :create, provider: provider
          expect(response).to redirect_to settings_url
        end
      end

      context 'when redirect URL is specified in environment' do
        let(:redirect_url) { 'https://foo.bar' }
        before { ENV["#{normalized_provider.upcase}_OAUTH2_REDIRECT_URL"] = redirect_url }

        it 'should redirect the member to the specified URL' do
          post :create, provider: provider
          if provider == :barong
            expect(response).to redirect_to "#{redirect_url}?#{request.env['omniauth.auth']['credentials'].to_query}"
          else
            expect(response).to redirect_to redirect_url
          end

        end
      end

      it 'should successfully destroy a session' do
        post :create, provider: provider
        post :destroy
        expect(session[:member_id]).to be_nil
      end
    end
  end
end
