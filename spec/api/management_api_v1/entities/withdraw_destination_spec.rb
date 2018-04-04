describe ManagementAPIv1::Entities::WithdrawDestination do
  context 'fiat' do
    let(:record) { create(:fiat_withdraw_destination, member: create(:member, :barong)) }

    subject { OpenStruct.new ManagementAPIv1::Entities::WithdrawDestination.represent(record).serializable_hash }

    it { expect(subject.id).to eq record.id }
    it { expect(subject.currency).to eq record.currency.code }
    it { expect(subject.uid).to eq record.member.authentications.barong.first.uid }
    it { expect(subject.label).to eq record.label }
    it { expect(subject.type).to eq 'fiat' }
    it { expect(subject.bank_name).to eq record.bank_name }
    it { expect(subject.bank_branch_name).to eq record.bank_branch_name }
    it { expect(subject.bank_branch_address).to eq record.bank_branch_address }
    it { expect(subject.bank_identifier_code).to eq record.bank_identifier_code }
    it { expect(subject.bank_account_number).to eq record.bank_account_number }
    it { expect(subject.bank_account_holder_name).to eq record.bank_account_holder_name }
    it { expect(subject.respond_to?(:address)).to be_falsey }
  end

  context 'coin' do
    let(:record) { create(:coin_withdraw_destination, member: create(:member, :barong)) }

    subject { OpenStruct.new ManagementAPIv1::Entities::WithdrawDestination.represent(record).serializable_hash }

    it { expect(subject.id).to eq record.id }
    it { expect(subject.currency).to eq record.currency.code }
    it { expect(subject.uid).to eq record.member.authentications.barong.first.uid }
    it { expect(subject.label).to eq record.label }
    it { expect(subject.type).to eq 'coin' }
    it { expect(subject.respond_to?(:bank_name)).to be_falsey }
    it { expect(subject.respond_to?(:bank_branch_name)).to be_falsey }
    it { expect(subject.respond_to?(:bank_branch_address)).to be_falsey }
    it { expect(subject.respond_to?(:bank_identifier_code)).to be_falsey }
    it { expect(subject.respond_to?(:bank_account_number)).to be_falsey }
    it { expect(subject.respond_to?(:bank_account_holder_name)).to be_falsey }
    it { expect(subject.address).to eq record.address }
  end
end
