require 'spec_helper'

describe 'deposits' do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email  }
  let!(:address) { create :payment_address }

  before do
    object = stub(:empty? => false, :using => address)
    Account.any_instance.stubs(:payment_addresses).returns(object)
  end

  it 'allows user to view his/her SN code' do
    login identity
    click_on I18n.t 'header.deposit'
    within '.deposit-channel-bank' do
      click_on I18n.t('actions.go')
    end
    expect(page).to have_content member.sn
  end
end
