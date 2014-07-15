<<<<<<< HEAD
# == Schema Information
#
# Table name: id_documents
#
#  id         :integer          not null, primary key
#  category   :integer
#  name       :string(255)
#  sn         :string(255)
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  verified   :boolean
#

require 'spec_helper'

describe IdDocument do
  let(:member) { create(:member) }
  subject { member.id_document }

  it { should be_valid }
end
