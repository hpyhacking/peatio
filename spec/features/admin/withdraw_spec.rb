require 'spec_helper'

describe 'withdraw' do
  let!(:member) { create :member, email: identity_normal.email }
  let!(:admin_member) { create :member, email: identity.email}
  let!(:identity_normal) { create :identity }
  let!(:identity) { create :identity, email: Member.admins.first }

  let!(:account) do
    member.get_account(:btc).tap { |a| a.update_attributes locked: 100, balance: 100 }
  end

  before do
    Withdraw.any_instance.stubs(:validate_password).returns(true)
  end

  let!(:withdraw) { create :withdraw, member: member, state: :examined, account: account}

  def visit_admin_withdraw_page
    login identity
    click_on I18n.t('header.admin')

    within '.ops' do
      expect(page).to have_content(I18n.t('layouts.admin.menus.items.operating.withdraws'))
      click_on I18n.t('layouts.admin.menus.items.operating.withdraws')
    end
  end

  it 'admin view withdraws' do
    visit_admin_withdraw_page

    expect(page).to have_content(withdraw.sn)
    expect(page).to have_content(withdraw.address_label)
    expect(page).to_not have_content(withdraw.address)

    click_on I18n.t('actions.view')
    expect(page).to have_content(withdraw.address)
    expect(page).to have_content(withdraw.address_label)
    expect(page).to have_content(I18n.t('actions.transact'))
    expect(page).to have_content(I18n.t('actions.reject'))
  end

  it 'admin approve withdraw' do
    visit_admin_withdraw_page

    click_on I18n.t('actions.view')
    click_on I18n.t('actions.transact')

    expect(current_path).to eq(admin_withdraws_path)
    expect(account.reload.locked).to be_d '90'

    expect(account.reload.balance).to be_d '100'
  end

  it 'admin reject withdraw' do
    visit_admin_withdraw_page

    click_on I18n.t('actions.view')
    click_on I18n.t('actions.reject')

    expect(current_path).to eq(admin_withdraws_path)
    expect(account.reload.locked).to be_d '90'
    expect(account.reload.balance).to be_d '110.0000'
  end
end
