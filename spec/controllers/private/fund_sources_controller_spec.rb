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

  describe 'POST create' do
    it "should not create fund_source with blank extra" do
      params = { currency: :cny,
                 fund_source: { extra: '',
                                uid: '1234 1234 1234'} }

      expect {
        post :create, params
        response.should be_success
      }.not_to change(FundSource, :count)
    end

    it "should not create fund_source with blank uid" do
      params = { currency: :cny,
                 fund_source: { extra: 'bank_code_1',
                                uid: ''} }

      expect {
        post :create, params
        response.should be_success
      }.not_to change(FundSource, :count)
    end

    it "should create fund_source successful" do
      params = { currency: :cny,
                 fund_source: { extra: 'bank_code_1',
                                uid: '1234 1234 1234'} }

      expect {
        post :create, params
        response.should be_redirect
      }.to change(FundSource, :count).by(1)
    end
  end

  describe 'DELETE' do
    before do
      @fund_source = create(:fund_source, member: member)
    end

    it "should delete fund_source" do
      expect {
        delete :destroy, {currency: @fund_source.currency, id: @fund_source.id}
        response.should be_redirect
      }.to change(FundSource, :count).by(-1)
    end
  end

end
