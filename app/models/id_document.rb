# == Schema Information
#
# Table name: id_documents
#
#  id         :integer          not null, primary key
#  category   :integer
#  name       :string(255)
#  sn         :string(255)
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  verified   :boolean
#

class IdDocument < ActiveRecord::Base
  extend Enumerize

  belongs_to :member

  validates_presence_of :sn, :category, :name, allow_nil: true
  validates_uniqueness_of :member

  enumerize :category, in: {id_card: 0, passport: 1}

  before_create :set_verified

  alias_attribute :full_name, :name

  private

  def set_verified
    self.verified = true
  end
end
