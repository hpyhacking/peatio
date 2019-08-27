# frozen_string_literal: true

module Bench
  module Factories
    class << self
      def create(model, options = {})
        "#{self.name}/#{model}"
          .camelize
          .constantize
          .new(options)
          .create
      end

      def create_list(model, number, options = {})
        "#{self.name}/#{model}"
          .camelize
          .constantize
          .new(options)
          .create_list(number)
      end
    end

    class Member
      def initialize(options)
        @options = options
      end

      def create
        ::Member.create!(construct_member)
      end

      def create_list(number)
        Array.new(number) { create }
      end

      def construct_member
        { email: unique_email,
          uid: "U#{Faker::Number.number(9)}",
          level: 3,
          role:  'member',
          state: 'active' }.merge(@options)
      end

      def unique_email
        @used_emails ||= ::Member.pluck(:email)
        loop do
          email = Faker::Internet.unique.email
          unless @used_emails.include?(email)
            @used_emails << email
            return email
          end
        end
      end
    end

    class Deposit
      DEFAULT_DEPOSIT_AMOUNT = 1_000_000_000
      def initialize(options)
        @options = options
        @currency = Currency.find(options[:currency_id])
      end

      def create
        if @currency.fiat?
          ::Deposit.create!(construct_fiat_deposit).tap(&:charge!)
        else
          ::Deposit.create!(construct_coin_deposit).tap { |d| d.with_lock { d.accept! } }
        end
      end

      def construct_fiat_deposit
        { amount: DEFAULT_DEPOSIT_AMOUNT,
          type:   'Deposits::Fiat' }.merge(@options)
      end

      def construct_coin_deposit
        { amount:  DEFAULT_DEPOSIT_AMOUNT,
          address: Faker::Blockchain::Bitcoin.address,
          txid:    Faker::Lorem.characters(64),
          txout:   0,
          type:    'Deposits::Coin' }.merge(@options)
      end
    end
  end
end
