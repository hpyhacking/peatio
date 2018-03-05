class FundSource < ActiveRecord::Base
  include Currencible

  attr_accessor :name

  paranoid

  belongs_to :member

  validates_presence_of :uid, :extra, :member, :currency

  def label
    if currency.try :coin?
      "#{uid} (#{extra})"
    else
      [extra, "****#{uid[-4..-1]}"].join('#')
    end
  end

  def as_json(options = {})
    super(options).merge(label: label, currency: currency.code)
  end
end

# == Schema Information
# Schema version: 20180227163417
#
# Table name: fund_sources
#
#  id          :integer          not null, primary key
#  member_id   :integer
#  currency_id :integer
#  extra       :string(255)
#  uid         :string(255)
#  is_locked   :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#
# Indexes
#
#  index_fund_sources_on_currency_id  (currency_id)
#
