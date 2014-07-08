# == Schema Information
#
# Table name: partial_trees
#
#  id         :integer          not null, primary key
#  proof_id   :integer          not null
#  account_id :integer          not null
#  json       :text             not null
#  created_at :datetime
#  updated_at :datetime
#  sum        :string(255)
#

class PartialTree < ActiveRecord::Base

  belongs_to :account
  belongs_to :proof

  serialize :json, JSON
  validates_presence_of :proof_id, :account_id, :json

end
