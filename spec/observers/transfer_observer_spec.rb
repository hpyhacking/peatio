require 'spec_helper'

describe TransferObserver do
  describe "#after_update" do
    let!(:member) { create(:member) }
    let!(:deposit) { create(:deposit, aasm_state: 'submitted')}
    before do
      TransferObserver.any_instance.stubs(:current_user).returns(member)
    end

    subject { deposit.update_attributes(aasm_state: 'accepted')}

    it "should create the audit log" do
      expect { subject }.to change{ Audit::TransferAuditLog.count }.by(1)

    end
  end
end
