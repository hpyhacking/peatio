class FundSource < ActiveRecord::Base
  include Currencible

  attr_accessor :name

  paranoid

  belongs_to :member

  validates_presence_of :uid, :extra, :member

  def label
    if currency_obj.try :coin?
      "#{uid} (#{extra})"
    else
      [extra, "****#{uid[-4..-1]}"].join('#')
    end
  end

  def as_json(options = {})
    super(options).merge({label: label})
  end
end

# == Schema Information
# Schema version: 20180215144645
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
#
