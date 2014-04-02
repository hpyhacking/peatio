class PartialTree < ActiveRecord::Base

  belongs_to :account
  belongs_to :proof

  validates_presence_of :proof_id, :account_id, :json

end
