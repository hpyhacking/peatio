# == Schema Information
#
# Table name: fund_sources
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  currency   :integer
#  extra      :string(255)
#  uid        :string(255)
#  channel_id :integer
#  is_locked  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class FundSource < ActiveRecord::Base
  include Currencible

  attr_accessor :name

  paranoid

  belongs_to :member

  validates_presence_of :uid, :extra, :member

  scope :with_channel, -> (channel_id) { where channel_id: channel_id }

  def to_s
    "#{uid} @ #{extra}"
  end
end
