require 'spec_helper'

describe TwoFactor do

  describe 'self.fetch_by_type' do
    it "return nil for wrong type" do
      expect(TwoFactor.by_type(:foobar)).to be_nil
    end

    it "create new one by type" do
      expect(TwoFactor.by_type(:app)).not_to be_nil
    end

    it "find exist one by tyep" do
      two_factor = TwoFactor::App.create
      expect(TwoFactor.by_type(:app)).to eq(two_factor)
    end
  end

  describe 'self.activiated' do
    before { create :member, :two_factor_activated }

    it "should has activated" do
      expect(TwoFactor.activated?).to be_true
    end
  end

  describe '#active!' do
    subject { create :two_factor }
    before { subject.active! }

    its(:activated?) { should be_true }
  end

  describe '#inactive!' do
    subject { create :two_factor, activated: true }
    before { subject.inactive! }

    its(:activated?) { should_not be_true }
  end

end
