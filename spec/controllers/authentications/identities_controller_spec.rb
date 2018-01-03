describe Authentications::IdentitiesController, type: :controller do
  let(:email) { 'xman@xman.com' }
  let(:member) { create(:verified_member, email: email) }
  before { session[:member_id] = member.id }

  describe 'GET new' do
    subject(:do_request) { get :new }
    it { is_expected.to be_success }
    it 'should set the identity' do
      do_request
      expect(assigns(:identity).new_record?).to be true
      expect(assigns(:identity).email).to eq email
    end
  end

  describe 'POST create' do
    let(:password) { '111111' }
    let(:attrs) do
      { identity: { password: password, password_confirmation: password } }
    end

    subject(:do_request) { post :create, attrs }

    it 'should create the ideneity' do
      expect do
        do_request
      end.to change(Identity, :count).by(1)
    end

    it 'should be recirect to settings path with flash' do
      do_request
      expect(response).to redirect_to(settings_path)
      expect(flash[:notice]).to eq I18n.t('authentications.identities.create.success')
    end
  end
end
