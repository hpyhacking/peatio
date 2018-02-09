module Audit
  describe TransferAuditLog do
    describe '.audit!' do
      let(:deposit) { create(:deposit) }
      let(:member) { create(:member) }
      let(:log) { TransferAuditLog.audit!(deposit, member) }

      before do
        deposit.stubs(:aasm_state_was).returns('submitted')
        deposit.stubs(:aasm_state).returns('accepted')
      end

      it 'should create the TransferAuditLog record' do
        expect { log }.to change { TransferAuditLog.count }.by(1)
      end

      it 'operator' do
        expect(log.operator).to eq member
      end

      it 'auditable' do
        expect(log.auditable).to eq deposit
      end

      it 'source_state' do
        expect(log.source_state).to eq 'submitted'
      end

      it 'target_state' do
        expect(log.target_state).to eq 'accepted'
      end
    end
  end
end
