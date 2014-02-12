require 'spec_helper'

describe Identity do
  it { should allow_value("pas1Word").for(:password) }
  it { should allow_value("pas1Wo@d").for(:password) }
  it { should allow_value("pas1Wo_d").for(:password) }
  it { should_not allow_value("pas1Wor").for(:password) }
  it { should_not allow_value("pwd").for(:password) }
  it { should_not allow_value("password").for(:password) }
  it { should_not allow_value("passwOrd").for(:password) }

  describe 'after create' do
    it 'creates an activation' do
      id = build(:identity, :inactive)
      expect{
        id.save!
      }.to change(Activation, :count).by(1)

      expect(Activation.last.identity).to eq(id)
    end
  end
end
