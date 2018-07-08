class Blockchain < ActiveRecord::Base

    def explorer=(hash)
        write_attribute(:explorer_address, hash.fetch('address'))
        write_attribute(:explorer_transaction, hash.fetch('transaction'))
    end
end

# == Schema Information
# Schema version: 20180708014826
#
# Table name: blockchains
#
#  id                   :integer          not null, primary key
#  key                  :string(255)
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
#  index_blockchains_on_key  (key) UNIQUE
#
