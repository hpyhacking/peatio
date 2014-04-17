require 'spec_helper'

describe SmsToken do

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

    before do
      token.expire_at = Time.now
    end

    it { should be_expired }
  end
end
