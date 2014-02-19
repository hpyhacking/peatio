require 'spec_helper'

describe 'member tags' do
  let(:member) { create :member }
  let(:identity) { create :identity, member: member }

  before do
    member.tag_list = 'hero'
  end

  it 'user can view self tags in settings index' do
    login identity
    click_on identity.email
    expect(page).to have_content 'Hero Member'
  end
end
