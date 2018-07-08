class Wallet < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: wallets
#
#  id         :integer          not null, primary key
#  name       :string(64)
#  currency   :string(5)
#  address    :string(255)
#  type       :string(32)
#  nsig       :integer
#  parent     :integer
#  status     :string(32)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
