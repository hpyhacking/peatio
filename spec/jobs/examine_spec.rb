require 'spec_helper'

describe Job::Examine do
  let(:member) { create(:member) }
  let(:account) { create(:account, balance: 100.to_d) }
  let(:withdraw) { create(:withdraw) }

  before do
    Account.any_instance.stubs(:examine).returns(true)
    Withdraw.any_instance.stubs(:account).returns(account)
    Withdraw.any_instance.stubs(:member).returns(member)
    Withdraw.any_instance.stubs(:validate_password).returns(true)
  end

  describe "wait state" do
    it "should be change state to examing" do
      expect { Job::Examine.perform(withdraw.id) }.to \
        change { withdraw.reload.state.to_sym }.from(:wait).to(:examined)
    end
  end

  describe "examined warning" do
    before do
      Account.any_instance.stubs(:examine).returns(false)
    end

    it "should be change state to examing" do
      expect { Job::Examine.perform(withdraw.id) }.to \
        change { withdraw.reload.state.to_sym }.from(:wait).to(:examined_warning)
    end
  end

  describe "done state" do
    let(:withdraw) { create(:withdraw, state: :done) }
    it "should not be change state" do
      expect { Job::Examine.perform(withdraw.id) }.to_not \
        change { withdraw.reload.state.to_sym }
    end
  end
end
