class WithdrawDestination < ActiveRecord::Base
  include Currencible

  serialize :details, JSON

  validates :label, :member, :currency, presence: true
  validate { errors.add(:details, :invalid) unless Hash === details }

  has_many :withdraws, -> { order(id: :desc) }, foreign_key: 'destination_id'
  belongs_to :member

  class << self
    def nested_attr(*names)
      names.each do |name|
        name_string = name.to_s
        define_method(name)              { details[name_string] }
        define_method(name_string + '?') { details[name_string].present? }
        define_method(name_string + '=') { |value| details[name_string] = value }
        define_method(name_string + '!') { details.fetch!(name_string) }
      end
    end
  end

  # Generic withdraw fields.
  nested_attr \
    :label # Unique label used to identify withdraw destination.

  class << self
    def fields
      {}
    end
  end

  def as_json(options = {})
    super(options.merge!(except: :details)).merge!(details).merge!(currency: currency.code)
  end
end

# == Schema Information
# Schema version: 20180305111648
#
# Table name: withdraw_destinations
#
#  id          :integer          not null, primary key
#  type        :string(30)       not null
#  member_id   :integer          not null
#  currency_id :integer          not null
#  details     :string(4096)     default({}), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_withdraw_destinations_on_currency_id  (currency_id)
#  index_withdraw_destinations_on_member_id    (member_id)
#  index_withdraw_destinations_on_type         (type)
#
