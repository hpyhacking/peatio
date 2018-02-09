describe IdDocument do
  let(:member) { create(:member) }

  it { is_expected.to be_valid }

  context 'aasm_state' do
    describe 'default state' do
      it 'default' do
        expect(member.id_document.aasm_state).to eq 'unverified'
      end
    end

    describe '#submit' do
      subject { member.id_document.aasm_state }
      before { member.id_document.submit! }

      it { is_expected.to eq 'verifying' }
    end

    context 'when aasm state changed' do
      subject { member.id_document.aasm_state }

      before do
        member.id_document.submit!
        member.id_document.approve!
      end

      it { is_expected.to eq 'verified' }
    end

    describe '#reject' do
      before do
        member.id_document.submit!
        member.id_document.reject!
      end

      it 'rejected' do
        expect(member.id_document.aasm_state).to eq 'unverified'
      end
    end
  end
end
