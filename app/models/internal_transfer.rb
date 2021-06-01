class InternalTransfer < ApplicationRecord
  # == Constants ============================================================
  # == Attributes ===========================================================
  # == Extensions ===========================================================

  acts_as_eventable prefix: 'internal_transfer', on: %i[create update]

  # == Relationships ========================================================

  belongs_to :currency
  belongs_to :sender, class_name: :Member, required: true
  belongs_to :receiver, class_name: :Member, required: true

  # == Validations ==========================================================

  validates :currency, :amount, :sender, :receiver, :state, presence: true

  # == Scopes ===============================================================
  # == Callbacks ============================================================

  before_commit on: :create do
    InternalTransfer.transaction do
      liabilities = [
        Operations::Liability.debit!(amount: amount, currency: currency, reference: self, member_id: sender_id),
        Operations::Liability.credit!(amount: amount, currency: currency, reference: self, member_id: receiver_id)
      ]
      liabilities.each { |l| Operations.update_legacy_balance(l) }
    end
  end

  # == Class Methods ========================================================
  # == Instance Methods =====================================================

  enum state: { completed: 1 }

  def direction(user)
    user == sender ? 'out' : 'in'
  end

end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: internal_transfers
#
#  id          :bigint           not null, primary key
#  currency_id :string(255)      not null
#  amount      :decimal(32, 16)  not null
#  sender_id   :bigint           not null
#  receiver_id :bigint           not null
#  state       :integer          default("completed"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
