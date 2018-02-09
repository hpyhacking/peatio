describe Private::IdDocumentsController, type: :controller do
  let(:member) { create(:member) }
  before { session[:member_id] = member.id }

  describe 'GET edit' do
    before { get :edit }

    it { expect(response.status).to eq 200 }
    it { is_expected.to render_template(:edit) }
  end

  describe 'post update' do
    let(:attrs) do
      {
        id_document: { name: 'foobar' }
      }
    end

    before { put :update, attrs }
    it { is_expected.to redirect_to(settings_path) }
    it { expect(assigns[:id_document].aasm_state).to eq('verifying') }
  end
end
