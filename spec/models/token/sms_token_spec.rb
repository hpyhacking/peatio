require 'spec_helper'

describe Token::SmsToken do

  describe "validates" do
    it "allow blank phone_number" do
      token = build :sms_token
      expect(token).to be_valid
    end

    it "validates phone_number" do
      valid_numbers = [
        '12345678901',
        '123 1234 1234',
        '123-1234-1234',
        '123.1234.1234'
      ].each do |number|
        token = build :sms_token, phone_number: number
        expect(token).to be_valid
      end
    end

    it "invalid phone numbers" do
      [
        '123',
        '1234-1234',
        '123-1234-1234-1',
        '123 123 1234'
      ].each do |number|
        token = build :sms_token, phone_number: number
        expect(token).not_to be_valid
      end
    end
  end

  describe '.for_member' do
    let(:member) { create :member }

    context 'do not have token exists' do
      it "create token for member if not exist" do
        expect(Token::SmsToken.for_member(member)).to be_is_a(Token::SmsToken)
      end
    end

    context 'member have token but not expired' do
      let(:token) { create :sms_token }
      let(:member) { token.member }

      it "should retrieve unexpired token" do
        expect(Token::SmsToken.for_member(member)).to eq(token)
      end
    end

    context 'member have expired token' do
      let(:token) { create :sms_token }
      let(:member) { token.member }

      before { token.update expire_at: Time.now }

      it 'should create a new token for member' do
        expect(Token::SmsToken.for_member(member)).not_to be_nil
        expect(Token::SmsToken.for_member(member)).to be_is_a(Token::SmsToken)
      end
    end
  end

  describe "#generate_token" do
    let(:member) { create :member }
    let(:token) { create :sms_token, member: member }

    it "generate token before save" do
      expect(token.token).not_to be_blank
    end

    it "generate 6-dig number token" do
      expect(token.token.length).to eq(6)
    end
  end

  describe '#expired?' do
    subject(:token) { create :sms_token }

    before { token.expire_at = Time.now }

    it { should be_expired }
  end

  describe '#update_phone_number' do
    let(:token) { create :sms_token }

    before do
      token.phone_number = '123.1234.1234'
      token.update_phone_number
    end

    it "should update member's phone_number" do
      expect(token.member.phone_number).to eq('+1 (231) 234-1234')
    end
  end

  describe '#sms_message' do
    let(:token) { create :sms_token }

    it "sms_message should not be blank" do
      expect(token.sms_message).not_to be_blank
    end
  end

  describe '#verify?' do
    let(:token) { create :sms_token }

    describe 'invalid code' do
      before { token.verify_code = 'wrong code' }

      it { expect(token).not_to be_verify }
    end

    describe 'verify succeed' do
      before { token.verify_code = token.token }

      it { expect(token).to be_verify }
    end
  end

  describe '#verified!' do
    let(:token) { create :sms_token }
    let(:member) { token.member }
    let(:mail) { ActionMailer::Base.deliveries.last }

    before { token.verified! }

    it { expect(member.sms_two_factor).to be_activated }
    it { expect(mail.subject).to match('Your phone number verified') }
  end
end
