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
  validates_presence_of :sn, :category, :name
  validates_uniqueness_of :member

  enumerize :category, in: {id_card: 0, passport: 1}

  before_create :set_verified
  after_commit :set_member_name

  private
  def set_verified
    self.verified = true
  end

  def set_member_name
    self.member.update_attribute(:name, self.name)
  end
end
