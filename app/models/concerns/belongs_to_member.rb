# encoding: UTF-8
# frozen_string_literal: true

module BelongsToMember
  extend ActiveSupport::Concern

  included do
    belongs_to :member, required: true
    validate do
      if try(:account) && member && account.member != member
        errors.add(:member, :invalid)
        errors.add(:account, :invalid)
      end
    end
  end
end
