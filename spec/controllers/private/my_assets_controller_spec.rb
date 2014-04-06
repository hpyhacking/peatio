require 'spec_helper'

module Private
  describe MyAssetsController do
    let(:member) { create :verified_member }

    let!(:accepted_deposit) { create(:deposit, member: member, aasm_state: :accepted) }
    let!(:rejected_deposit) { create(:deposit, member: member, aasm_state: :rejected) }
    let!(:others_deposit) { create(:deposit, aasm_state: :accepted) }

    let!(:btc_withdraw) { create(:satoshi_withdraw, member: member, aasm_state: :done) }
    let!(:bank_withdraw) { create(:bank_withdraw, member: member, aasm_state: :done) }
    let!(:canceled_withdraw) { create(:bank_withdraw, member: member, aasm_state: :canceled) }
    let!(:others_withdraw) { create(:bank_withdraw, aasm_state: :done) }

    let!(:buy) { create(:trade, bid_member_id: member.id) }
    let!(:others_buy) { create(:trade, bid_member_id: create(:member).id) }

    let!(:sell) { create(:trade, ask_member_id: member.id) }
    let!(:others_sell) { create(:trade, ask_member_id: create(:member).id) }

    before { session[:member_id] = member.id }

    describe 'GET index' do
      subject(:do_request) { get :index }

      it { should be_success }

      it "assigns @deposits with current user's successfully fulfilled deposit requests" do
        do_request

        deposits = assigns(:deposits)
        expect(deposits).to include(accepted_deposit)
        expect(deposits).to_not include(rejected_deposit)
        expect(deposits).to_not include(others_deposit)
      end

      it "assigns @withdraw with current user's successfully fulfilled withdraw requests" do
        do_request

        withdraws = assigns(:withdraws)
        expect(withdraws).to include(btc_withdraw)
        expect(withdraws).to include(bank_withdraw)
        expect(withdraws).to_not include(canceled_withdraw)
        expect(withdraws).to_not include(others_withdraw)
      end

      it "assigns @buys with trades where current user is the successful bidder" do
        do_request

        buys = assigns(:buys)
        expect(buys).to include(buy)
        expect(buys).to_not include(others_buy)
      end

      it "assigns @sells with trades where current user is the successful asker" do
        do_request

        sells = assigns(:sells)
        expect(sells).to include(sell)
        expect(sells).to_not include(others_sell)
      end
    end
  end
end
