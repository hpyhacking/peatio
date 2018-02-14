describe Private::AssetsController, type: :controller do
  let(:member) { create :member, :verified_identity }
  before { session[:member_id] = member.id }

  context 'logged in user visit' do
    describe 'GET /exchange_assets' do
      before { get :index }

      it { expect(response.status).to eq 200 }
    end
  end

  context 'non-login user visit' do
    before { session[:member_id] = nil }

    describe 'GET /exchange_assets' do
      before { get :index }

      it { expect(response.status).to eq 200 }
      it { expect(assigns(:btc_account)).to be_nil }
      it { expect(assigns(:usd_account)).to be_nil }
    end
  end
end
