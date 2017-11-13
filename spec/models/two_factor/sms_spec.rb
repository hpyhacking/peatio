describe TwoFactor::Sms do
  subject(:two_factor) do
    member = create :member
    member.sms_two_factor
  end

  context 'when send code phase with empty country code' do
    let(:phone_number) { '0412789194' }

    before do
      two_factor.send_code_phase = true
      two_factor.phone_number = phone_number
    end

    it { is_expected.not_to be_valid }
  end

  context 'when send code phase with valid country code' do
    let(:phone_number) { '0412789194' }
    let(:country) { 'AU' }

    before do
      two_factor.send_code_phase = true
      two_factor.phone_number = phone_number
      two_factor.country = country
    end

    it { should be_valid }
  end

  describe '#sms_message' do
    subject { two_factor.sms_message }
    it { is_expected.not_to be_blank }
  end

  describe '#phone_number' do
    let(:phone_number) { '123-1234-1234' }
    subject { two_factor.member.phone_number }

    context 'after sending otp' do
      before { two_factor.send_otp }
      it { is_expected.not_to be_blank }
    end

    context 'when assigned' do
      before { two_factor.member.update(phone_number: phone_number) }

      it 'is assigned' do
        expect(two_factor.member.phone_number).to eq(phone_number)
      end
    end
  end

  describe '#verify?' do
    subject { two_factor.verify? }

    context 'when invalid code' do
      before { two_factor.update(otp: 'foobar') }
      it { is_expected.to be false }
    end

    context 'when verify succeed' do
      before { two_factor.update(otp: two_factor.otp_secret) }
      it { is_expected.to be true }
    end
  end

  describe '#otp_secret' do
    subject { two_factor.otp_secret }

    it { is_expected.to match /^\d{6}$/ }

    context 'after refreshing' do
      let!(:orig_otp_secret) { two_factor.otp_secret.clone }
      before { two_factor.refresh! }

      it 'differs from previous secret' do
        expect(subject).not_to eq(orig_otp_secret)
      end
    end
  end

  describe '#activated?' do
    subject { two_factor.activated? }

    context 'when two factor is active' do
      before { two_factor.active! }
      it { is_expected.to be true }
    end

    context 'when two factor is not active' do
      before { two_factor.deactive! }
      it { is_expected.to be false }
    end
  end
end
