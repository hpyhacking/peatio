# encoding: UTF-8
# frozen_string_literal: true

module AccountFactory
  def create_account(*arguments)
    currency   = Symbol === arguments.first ? arguments.first : :usd
    attributes = arguments.extract_options!
    attributes.delete(:member) { create(:member) }.ac(currency).tap do |account|
      account.update!(attributes)
    end
  end
end

RSpec.configure { |config| config.include AccountFactory }
