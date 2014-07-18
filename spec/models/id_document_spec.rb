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
  it "sets member name to same as the document" do
    doc = create(:id_document, name: "Sun Xiaomei", member: create(:member, name: "Xiaomei"))
    expect(doc.member.name).to eql doc.name
  end

  it "sets verified to true by default" do
    expect(create(:id_document, verified: false)).to be_verified
  end
end
