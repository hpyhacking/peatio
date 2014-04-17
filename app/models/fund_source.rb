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
