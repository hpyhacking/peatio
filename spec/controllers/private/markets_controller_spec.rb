require 'spec_helper'

describe Private::MarketsController do
  let(:member) { create :member }
  before { session[:member_id] = member.id }

  context "logged in user" do
    describe "GET /markets/btccny" do
      before { get :show, data }

      it { should respond_with :ok }
    end
  end

  context "non-login user" do
    before { session[:member_id] = nil }

    describe "GET /markets/btccny" do
      before { get :show, data }

      it { should respond_with :ok }
      it { expect(assigns(:member)).to be_nil }
    end
  end

  private

  def data
    {
      id: 'btccny',
      market: 'btccny',
      ask: 'btc',
      bid: 'cny'
    }
  end

end
