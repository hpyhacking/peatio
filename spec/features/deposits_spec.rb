require 'spec_helper'

describe 'deposits' do
  let!(:member) { create(:member) }
  let!(:identity) { create :identity, member: member }
  let(:address) { create :payment_address }

  before do
    object = stub(:empty? => false, :using => address)
    Account.any_instance.stubs(:payment_addresses).returns(object)
  end

  it 'allows user to view itself SN code' do
    login identity
    click_on I18n.t 'header.deposit'
    click_on 'bank'
    expect(page).to have_content member.sn
  end
end
