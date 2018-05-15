# encoding: UTF-8
# frozen_string_literal: true

module FeeChargeable
  extend ActiveSupport::Concern

  included do
    before_validation(on: :create) { calc_fee }

    validates :fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end
end
