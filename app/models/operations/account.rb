# frozen_string_literal: true

# TODO: Add admin rubric for Account.
module Operations
  class Account < ApplicationRecord
    SCOPES = %w[member platform].freeze

    MEMBER_TYPES = %w[liability].freeze
    PLATFORM_TYPES = %w[asset expense revenue].freeze
    TYPES = (MEMBER_TYPES + PLATFORM_TYPES).freeze

    validates :code, presence: true, uniqueness: true
    validates :type, presence: true, inclusion: { in: TYPES }
    validates :kind, presence: true, uniqueness: { scope: %i[type currency_type code] }
    validates :currency_type, presence: true, inclusion: { in: Currency.types.map(&:to_s) }
    validates :scope, presence: true, inclusion: { in: SCOPES }

    def self.table_name_prefix
      'operations_'
    end

    # Type column reserved for STI.
    self.inheritance_column = nil

    # Allows dynamically check scopes.
    #   scope.platform?
    def scope
      super&.inquiry
    end

    # Allows dynamically check kinds.
    #   kind.main?
    def kind
      super&.inquiry
    end
  end
end

# == Schema Information
# Schema version: 20210805134633
#
# Table name: operations_accounts
#
#  id            :bigint           not null, primary key
#  code          :integer          not null
#  type          :string(10)       not null
#  kind          :string(30)       not null
#  currency_type :string(10)       not null
#  description   :string(100)
#  scope         :string(10)       not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_operations_accounts_on_code                          (code) UNIQUE
#  index_operations_accounts_on_currency_type                 (currency_type)
#  index_operations_accounts_on_scope                         (scope)
#  index_operations_accounts_on_type                          (type)
#  index_operations_accounts_on_type_kind_currency_type_code  (type,kind,currency_type,code)
#
