# encoding: UTF-8
# frozen_string_literal: true

describe Operations do
  describe '.build_account_number' do
    it 'works' do
      expect(Operations.build_account_number(currency_id: :usd, account_code: 101, member_uid: "UID123")).to eq "usd-101-UID123"
    end

    it 'works if UID not given' do
      expect(Operations.build_account_number(currency_id: :usd, account_code: 101)).to eq "usd-101"
    end
  end
end
