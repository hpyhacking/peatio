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

require 'spec_helper'

describe PartialTree do
  pending "add some examples to (or delete) #{__FILE__}"
end
