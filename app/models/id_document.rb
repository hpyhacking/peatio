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
  include AASM
  include AASM::Locking

  belongs_to :member

  validates_presence_of :sn, :category, :name, allow_nil: true
  validates_uniqueness_of :member

  enumerize :category, in: {id_card: 0, passport: 1, driver_license: 2}
  enumerize :id_bill_type, in: {bank_statement: 0, tax_bill: 1}

  alias_attribute :full_name, :name

  aasm do
    state :unapproved, initial: true
    state :pending_approve
    state :approved

    event :submit do
      transitions from: :unapproved,      to: :pending_approve
    end

    event :approve do
      transitions from: :pending_approve, to: :approved
    end

    event :reject do
      transitions from: :pending_approve, to: :unapproved
    end
  end
end
