# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Entities::Member do
  let(:member) { create(:member, :level_3) }

  subject { OpenStruct.new API::V2::Entities::Member.represent(member).serializable_hash }

  it do
    expect(subject.uid).to eq member.uid
    expect(subject.email).to eq member.email
  end
end
