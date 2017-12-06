describe Doorkeeper::AccessToken do
  let(:member) { create(:member) }
  let(:app) do
    Doorkeeper::Application.create!(
      name: 'test',
      uid: 'foo',
      secret: 'bar',
      redirect_uri: 'http://test.host/oauth/callback'
    )
  end

  subject! do
    Doorkeeper::AccessToken.create!(
      application_id: app.id,
      resource_owner_id: member.id,
      scopes: 'identity',
      expires_in: 1.week
    )
  end

  context 'creation' do
    it 'should generate corresponding api token' do
      expect do
        Doorkeeper::AccessToken.create!(
          application_id: app.id,
          resource_owner_id: member.id,
          scopes: 'identity',
          expires_in: 1.week
        )
      end.to change(APIToken, :count).by 1
    end

    it 'should prevent app requesting all scopes' do
      expect do
        Doorkeeper::AccessToken.create!(
          application_id: app.id,
          resource_owner_id: member.id,
          scopes: 'all',
          expires_in: 1.week
        )
      end.to raise_error(RuntimeError, 'Invalid scope: all')
    end

    it 'should set token' do
      expect(subject.token).to eq APIToken.last.to_oauth_token
    end

    it 'should setup api token correctly' do
      api_token = APIToken.last
      expect(api_token.label).to eq app.name
      expect(api_token.scopes).to eq %w[identity]
      expect(api_token.expires_at).not_to be_nil
    end

    it 'should link api token' do
      expect(APIToken.last.oauth_access_token).to eq subject
    end
  end

  context 'when revoking a token' do
    it 'should revoke access token and destroy corresponding api token' do
      subject.revoke
      expect(subject).to be_revoked
      expect(APIToken.find_by_id(subject.api_token.id)).to be_nil
    end
  end

  context 'when deleting' do
    it 'should soft delete record' do
      subject.destroy
      expect(Doorkeeper::AccessToken.find_by_id(subject.id)).to be_nil
      expect(Doorkeeper::AccessToken.with_deleted.find_by_id(subject.id)).to eq subject
    end
  end
end
