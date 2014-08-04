# == Schema Information
#
# Table name: fund_sources
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  currency   :integer
#  extra      :string(255)
#  uid        :string(255)
#  is_locked  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#  bsb        :string(255)
#

class FundSource < ActiveRecord::Base
  include Currencible

  attr_accessor :name

  paranoid

  belongs_to :member

  validates_presence_of :uid, :extra, :member

  def to_s
    "#{uid} @ #{extra}"
  end

  def label
    if currency_obj.try :coin?
      [extra, uid].join('#')
    else
      [I18n.t("banks.#{extra}"), "****#{uid[-4..-1]}"].join('#')
    end
  end
end
