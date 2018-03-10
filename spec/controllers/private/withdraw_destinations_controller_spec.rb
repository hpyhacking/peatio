describe Private::WithdrawDestinationsController, type: :controller do
  let(:member) { create(:member, :verified_identity) }
  before { session[:member_id] = member.id }

  describe 'POST create' do
    it 'should not create withdraw_destination with blank label' do
      params = { label: '', currency: :btc, address: '1234 1234 1234' }

      expect do
        post :create, params
        expect(response).not_to be_ok
      end.not_to change(WithdrawDestination, :count)
    end

    it 'should not create withdraw_destination with blank address' do
      params = { label: 'bank_code_1', currency: :btc, address: '' }

      expect do
        post :create, params
        expect(response).not_to be_ok
      end.not_to change(WithdrawDestination, :count)
    end

    it 'should create withdraw_destination successful' do
      params = { label: 'bank_code_1', currency: :btc, address: '1234 1234 1234' }

      expect do
        post :create, params
        expect(response).to be_ok
      end.to change(WithdrawDestination, :count).by(1)
    end
  end

  describe 'UPDATE' do
    let!(:withdraw_destination) { create(:withdraw_destination, member: member) }
    let!(:account) { member.get_account(:btc) }

    it 'update default_withdraw_destination to account' do
      put :update, id: withdraw_destination.id
      expect(account.reload.default_withdraw_destination_id).to eq(withdraw_destination.id)
    end
  end
end

describe 'routes for WithdrawDestinationsController', type: :routing do
  it { expect(post: '/withdraw_destinations').to be_routable }
  it { expect(put: '/withdraw_destinations/1').to be_routable }
end
