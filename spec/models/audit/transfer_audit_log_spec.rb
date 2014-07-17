# == Schema Information
#
# Table name: audit_logs
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  operator_id    :integer
#  created_at     :datetime
#  updated_at     :datetime
#  auditable_id   :integer
#  auditable_type :string(255)
#  source_state   :string(255)
#  target_state   :string(255)
#

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
