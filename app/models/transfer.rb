# encoding: UTF-8
# frozen_string_literal: true

class Transfer < ApplicationRecord

  extend Enumerize

  CATEGORIES = %w[wire refund purchases commission].freeze
  CATEGORIES_MAPPING = { wire: 1, refund: 2, purchases: 3, commission: 4 }.freeze
  enumerize :category, in: CATEGORIES_MAPPING, scope: true

  # Define has_many relation with Operations::{Asset,Expense,Liability,Revenue}.
  ::Operations::Account::TYPES.map(&:pluralize).each do |op_t|
    has_many op_t.to_sym,
             class_name: "::Operations::#{op_t.to_s.singularize.camelize}",
             as: :reference
  end

  validates :key, uniqueness: true, presence: true
  validates :category, presence: true
end

# == Schema Information
# Schema version: 20190905050444
#
# Table name: transfers
#
#  id          :integer          not null, primary key
#  key         :string(30)       not null
#  category    :integer          not null
#  description :string(255)      default("")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_transfers_on_key  (key) UNIQUE
#
