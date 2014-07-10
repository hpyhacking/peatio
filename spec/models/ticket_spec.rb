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

require 'spec_helper'

describe Ticket do
  pending "add some examples to (or delete) #{__FILE__}"
end
