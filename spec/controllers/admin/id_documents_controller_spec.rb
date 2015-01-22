require 'spec_helper'

describe Admin::IdDocumentsController do
  let(:member) { create(:admin_member) }
  before {
    session[:member_id] = member.id
    two_factor_unlocked
  }

  describe 'GET index' do
    before { get :index }

    it { should respond_with :ok }
    it { should render_template(:index) }
  end

end
