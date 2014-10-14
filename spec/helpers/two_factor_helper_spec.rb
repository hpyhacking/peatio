require 'spec_helper'

describe TwoFactorHelper do

  describe '#two_factor_locked?' do
    context 'empty session' do
      subject { helper.two_factor_locked? }

      it { should be_true }
    end

    context 'locked' do
      subject { helper.two_factor_locked? }
      before {
        session[:two_factor_locked] = false
      }

      it { should be_true }
    end

    context 'unlock without unlocked_at' do
      subject { helper.two_factor_locked?(expired_at: 5.minutes) }
      before {
        session[:two_factor_unlock] = true
      }

      it { should be_true }
    end

    context 'unlock and expired' do
      subject { helper.two_factor_locked?(expired_at: 5.minutes) }
      before {
        session[:two_factor_unlock] = true
        session[:two_factor_unlock_at] = 10.minutes.ago
      }

      it { should be_true }
    end

    context 'unlock and not expired' do
      subject { helper.two_factor_locked?(expired_at: 10.minutes) }
      before {
        session[:two_factor_unlock] = true
        session[:two_factor_unlock_at] = 5.minutes.ago
      }

      it { should_not be_true }
    end
  end

end
