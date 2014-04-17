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
    let(:sms_token) { create :sms_token, member: member }

    it "generate token before save" do
      expect(sms_token.token).not_to be_blank
    end

    it "generate 6-dig number token" do
      expect(sms_token.token.length).to eq(6)
    end
  end

end
