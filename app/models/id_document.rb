class IdDocument < ActiveRecord::Base
  extend Enumerize

  belongs_to :member
  validates_presence_of :category, :name, :sn
  validates :name, chinese_name: true, if: Proc.new { |r| r.category == "id_card" }
  validates :sn, chinese_id_card_num: true, if: Proc.new { |r| r.category == "id_card" }
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
