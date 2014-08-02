require 'spec_helper'

describe Private::FundSourcesController do
  let(:member) { create(:member) }
  before { session[:member_id] = member.id }

  describe 'GET index' do
    before { get :index, { currency: :btc } }

    it { should respond_with :ok }
    it { should render_template(:index) }
    it { expect(assigns(:currency)).to be_present }
  end

  describe 'GET new' do
    before { get :new, { currency: :btc } }

    it { should respond_with :ok }
    it { should render_template(:new) }
    it { expect(assigns(:currency)).to be_present }
    it { expect(assigns(:fund_source)).to be_present }
  end

end
