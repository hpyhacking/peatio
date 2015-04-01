require 'spec_helper'

describe Private::FundSourcesController do
  let(:member) { create(:member) }
  before { session[:member_id] = member.id }

  describe 'POST create' do
    it "should not create fund_source with blank extra" do
      params = { currency: :cny,
                 fund_source: { extra: '',
                                uid: '1234 1234 1234'} }

      expect {
        post :create, params
        expect(response).not_to be_ok
      }.not_to change(FundSource, :count)
    end

    it "should not create fund_source with blank uid" do
      params = { currency: :cny,
                 fund_source: { extra: 'bank_code_1',
                                uid: ''} }

      expect {
        post :create, params
        expect(response).not_to be_ok
      }.not_to change(FundSource, :count)
    end

    it "should create fund_source successful" do
      params = { currency: :cny,
                 fund_source: { extra: 'bank_code_1',
                                uid: '1234 1234 1234'} }

      expect {
        post :create, params
        expect(response).to be_ok
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
        expect(response).to be_ok
      }.to change(FundSource, :count).by(-1)
    end
  end

end

describe 'routes for FundSources', type: :routing do
  it { expect(post: '/fund_sources').to be_routable }
  it { expect(delete: '/fund_sources/1').to be_routable }
end
