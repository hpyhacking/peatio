describe APIv2::Entities::Account do
  let(:account) { create(:account_btc) }

  subject { OpenStruct.new APIv2::Entities::Account.represent(account).serializable_hash }

  it { expect(subject.currency).to eq Currency.find_by!(code: :btc).code }
  it { expect(subject.balance).to eq '100.0' }
  it { expect(subject.locked).to eq '0.0' }
end
