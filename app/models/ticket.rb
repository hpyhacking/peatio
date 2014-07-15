# == Schema Information
#
# Table name: tickets
#
#  id         :integer          not null, primary key
#  content    :text
#  state      :string(255)
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Ticket < ActiveRecord::Base
  include AASM
  include AASM::Locking
  acts_as_readable on: :created_at

  validates_with TicketValidator

  has_many :comments
  belongs_to :author, class_name: 'Member', foreign_key: 'author_id'

  scope :open, -> { where(aasm_state: :open) }
  scope :close, -> { where(aasm_state: :closed) }

  aasm whiny_transitions: false do
    state :open
    state :closed

    event :close do
      transitions from: :open, to: :closed
    end

    event :reopen do
      transitions from: :closed, to: :open
    end
  end

  def title_for_display(n = 60)
    title.blank? ? content.truncate(n) : title.truncate(n)
  end

end
