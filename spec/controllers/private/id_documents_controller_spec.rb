require 'spec_helper'

describe Private::IdDocumentsController do
  let(:member) { create(:member) }
  before { session[:member_id] = member.id }

  describe 'GET edit' do
    before { get :edit }

    it { should respond_with :ok }
    it { should render_template(:edit) }
  end

  describe 'post update' do
    let(:attrs) {
      {
        id_document: {name: 'foobar'}
      }
    }

    before { put :update, attrs }
    it { should redirect_to(settings_path) }
    it { expect(assigns[:id_document].aasm_state).to eq('verifying') }
  end

end
