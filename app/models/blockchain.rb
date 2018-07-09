class Blockchain < ActiveRecord::Base
  has_many :currencies, foreign_key: :blockchain_key, primary_key: :key

  def explorer=(hash)
      write_attribute(:explorer_address, hash.fetch('address'))
      write_attribute(:explorer_transaction, hash.fetch('transaction'))
  end

  def status
    super&.inquiry
  end
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: blockchains
#
#  id                   :integer          not null, primary key
#  key                  :string(255)      not null
#  name                 :string(255)
#  client               :string(255)
#  server               :string(255)
#  height               :integer
#  explorer_address     :string(255)
#  explorer_transaction :string(255)
#  status               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_blockchains_on_key     (key) UNIQUE
#  index_blockchains_on_status  (status)
#
