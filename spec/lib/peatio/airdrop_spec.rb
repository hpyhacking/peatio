# frozen_string_literal: true

RSpec.describe Peatio::Airdrop do
  let(:test_file) { File.read(Rails.root.join('spec', 'resources', 'airdrops', file_name)) }
  let(:file_name) { '1.csv' }
  let(:src_user) { create(:member, role: :admin) }
  let(:uids) { %w[UID120 UID121 UID122 UID123 UID124] }

  before do
    deposit = create(:deposit_btc, member: src_user, amount: 1000)
    deposit.accept!
    deposit.process!
    deposit.dispatch!
    uids.each do |uid|
      create(:member, uid: uid)
    end
  end

  subject(:airdop) { Peatio::Airdrop.new.process(src_user, { file: { tempfile: test_file } }) }

  it 'credited all users' do
    expect { airdop }.to change { Transfer.count }.by(5)
    uids.each do |uid|
      member = Member.find_by_uid(uid)
      expect(member.get_account(:btc).balance).to eq 100
    end
  end

  it 'doesnt create for unexisting user' do
    Member.last.delete
    expect { airdop }.to change { Transfer.count }.by(4)
  end

  it 'doesnt create transfers if src_user has insufficient funds (enough for the part of airdrop)' do
    src_user.get_account(:btc).update(balance: 200)
    expect { airdop }.to change { Transfer.count }.by(0)
  end

  it 'doesnt create transfers if src_user has insufficient funds (zero balance)' do
    src_user.get_account(:btc).update(balance: 0)
    expect { airdop }.to change { Transfer.count }.by(0)
  end
end
