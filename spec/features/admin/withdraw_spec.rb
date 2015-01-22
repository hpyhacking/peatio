require 'spec_helper'

describe 'withdraw' do
  let!(:member) { create :member, email: identity_normal.email }
  let!(:admin_member) { create :member, email: identity.email}
  let!(:identity_normal) { create :identity }
  let!(:identity) { create :identity, email: Member.admins.first }

  let!(:account) do
    member.get_account(:cny).tap { |a| a.update_attributes locked: 8000, balance: 10000 }
  end

  let!(:withdraw) { create :bank_withdraw, member: member, sum: 5000, aasm_state: :accepted, account: account}

  before do
    Withdraw.any_instance.stubs(:validate_password).returns(true)
  end

  def visit_admin_withdraw_page
    pending 'skip withdraw dashboard'
    login identity
    click_on I18n.t('header.admin')

    within '.ops' do
      expect(page).to have_content(I18n.t('layouts.admin.menus.items.operating.withdraws'))
      click_on I18n.t('layouts.admin.menus.items.operating.withdraws')
    end
  end

  it 'admin view withdraws' do
    pending 'skip withdraw dashboard'
    visit_admin_withdraw_page

    expect(page).to have_content(withdraw.sn)
    expect(page).to have_content(withdraw.fund_extra)
    expect(page).to_not have_content(withdraw.fund_uid)

    click_on I18n.t('actions.view')
    expect(page).to have_content(withdraw.fund_uid)
    expect(page).to have_content(withdraw.fund_extra)
    expect(page).to have_content(I18n.t('actions.transact'))
    expect(page).to have_content(I18n.t('actions.reject'))
  end

  it 'admin approve withdraw' do
    pending 'skip withdraw dashboard'
    visit_admin_withdraw_page

    click_on I18n.t('actions.view')
    click_on I18n.t('actions.transact')

    expect(current_path).to eq(admin_withdraws_path)

    click_on I18n.t('actions.view')
    click_on I18n.t('actions.transact')

    expect(current_path).to eq(admin_withdraws_path)

    expect(account.reload.locked).to be_d '3000'
    expect(account.reload.balance).to be_d '10000'
  end

  it 'admin reject withdraw' do
    pending 'skip withdraw dashboard'
    visit_admin_withdraw_page

    click_on I18n.t('actions.view')
    click_on I18n.t('actions.reject')

    expect(current_path).to eq(admin_withdraws_path)
    expect(account.reload.locked).to be_d '3000'
    expect(account.reload.balance).to be_d '15000.0000'
  end
end
