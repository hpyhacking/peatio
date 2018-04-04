describe TransferObserver do
  describe '#after_update' do
    let!(:member) { create(:member, :verified_identity) }
    let!(:deposit) { create(:deposit_btc, aasm_state: 'submitted') }
    before do
      TransferObserver.any_instance.stubs(:current_user).returns(member)
    end

    subject { deposit.update_attributes(aasm_state: 'accepted') }

    it 'should create the audit log' do
      expect { subject }.to change { Audit::TransferAuditLog.count }.by(1)
    end
  end
end
