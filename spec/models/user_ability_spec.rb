# frozen_string_literal: true

describe UserAbility do

  context 'abilities for member' do
    let(:member) { create(:member, role: 'member') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for superadmin' do
    let(:member) { create(:member, role: 'superadmin') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for admin' do
    let(:member) { create(:member, role: 'admin') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for compliance' do
    let(:member) { create(:member, role: 'compliance') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for support' do
    let(:member) { create(:member, role: 'support') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for technical' do
    let(:member) { create(:member, role: 'technical') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for reporter' do
    let(:member) { create(:member, role: 'reporter') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for accountant' do
    let(:member) { create(:member, role: 'accountant') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for broker' do
    let(:member) { create(:member, role: 'broker') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for trader' do
    let(:member) { create(:member, role: 'trader') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'abilities for maker' do
    let(:member) { create(:member, role: 'maker') }
    subject(:ability) { UserAbility.new(member) }

    it { is_expected.to be_able_to(:manage, :all) }
  end
end
