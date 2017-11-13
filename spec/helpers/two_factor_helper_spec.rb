describe TwoFactorHelper, type: :helper do
  describe '#two_factor_locked?' do
    context 'empty session' do
      subject { helper.two_factor_locked? }

      it { is_expected.to be true }
    end

    context 'locked' do
      subject { helper.two_factor_locked? }
      before do
        session[:two_factor_locked] = false
      end

      it { is_expected.to be true }
    end

    context 'unlock without unlocked_at' do
      subject { helper.two_factor_locked?(expired_at: 5.minutes) }
      before do
        session[:two_factor_unlock] = true
      end

      it { is_expected.to be true }
    end

    context 'unlock and expired' do
      subject { helper.two_factor_locked?(expired_at: 5.minutes) }
      before do
        session[:two_factor_unlock] = true
        session[:two_factor_unlock_at] = 10.minutes.ago
      end

      it { is_expected.to be true }
    end

    context 'unlock and not expired' do
      subject { helper.two_factor_locked?(expired_at: 10.minutes) }
      before do
        session[:two_factor_unlock] = true
        session[:two_factor_unlock_at] = 5.minutes.ago
      end

      it { is_expected.not_to be true }
    end
  end
end
