require 'spec_helper'

module Audit
  describe TransferAuditLog do
    describe ".audit!" do
      let(:deposit) { create(:deposit) }
      let(:member) { create(:member) }

      subject { TransferAuditLog.audit!(deposit, member) }

      before do
        deposit.stubs(:aasm_state_was).returns('submitted')
        deposit.stubs(:aasm_state).returns('accepted')
      end

      it "should create the TransferAuditLog record" do
        expect { subject }.to change{ TransferAuditLog.count }.by(1)
      end

      its(:operator) { should == member }
      its(:auditable) { should == deposit }
      its(:source_state) { should == 'submitted' }
      its(:target_state) { should == 'accepted' }

    end
  end

end
