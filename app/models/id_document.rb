# == Schema Information
#
# Table name: id_documents
#
#  id                 :integer          not null, primary key
#  id_document_type   :integer
#  name               :string(255)
#  id_document_number :string(255)
#  member_id          :integer
#  created_at         :datetime
#  updated_at         :datetime
#  verified           :boolean
#  birth_date         :date
#  address            :text
#  city               :string(255)
#  country            :string(255)
#  zipcode            :string(255)
#  id_bill_type       :integer
#  aasm_state         :string(255)
#

class IdDocument < ActiveRecord::Base
  extend Enumerize
  include AASM
  include AASM::Locking

  has_one :id_document_file, class_name: 'Asset::IdDocumentFile', as: :attachable
  accepts_nested_attributes_for :id_document_file

  has_one :id_bill_file, class_name: 'Asset::IdBillFile', as: :attachable
  accepts_nested_attributes_for :id_bill_file

  belongs_to :member

  validates_presence_of :name, :id_document_type, :id_document_number, allow_nil: true
  validates_uniqueness_of :member

  enumerize :id_document_type, in: {id_card: 0, passport: 1, driver_license: 2}
  enumerize :id_bill_type,     in: {bank_statement: 0, tax_bill: 1}

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
