# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  author_id  :integer
#  ticket_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Comment do
  pending "add some examples to (or delete) #{__FILE__}"
end
