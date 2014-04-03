require 'spec_helper'

feature 'my assets page' do
  let!(:identity) { create :identity }
  let!(:member) { create :member, :activated, email: identity.email  }

  let!(:cny_account) do
    member.get_account('cny').tap { |a| a.update_attributes locked: 400, balance: 1000 }
  end
  let!(:btc_account) do
    member.get_account('btc').tap { |a| a.update_attributes locked: 40, balance: 200 }
  end

  scenario 'user can view his account balance, including available and locked assets' do
    login identity
    click_on I18n.t('header.my_assets')

    expect(page.find('.cny .available').text).to be_d cny_account.balance
    expect(page.find('.cny .locked').text).to be_d cny_account.locked
    expect(page.find('.btc .available').text).to be_d btc_account.balance
    expect(page.find('.btc .locked').text).to be_d btc_account.locked
  end
end
