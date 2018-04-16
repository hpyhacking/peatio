feature 'Withdraw', js: true do
  let!(:member) { create(:member, :verified_identity) }
  let!(:admin_member) { create(:member, :verified_identity, email: Member.admins.first) }
  let!(:usd_account) { member.get_account(:usd).tap { |a| a.update!(locked: 8000, balance: 10_000) } }
  let!(:btc_account) { member.get_account(:btc).tap { |a| a.update!(locked: 10, balance: 50) } }
  let!(:usd_withdraw) { create(:usd_withdraw, member: member, sum: 5000, aasm_state: :accepted, account: usd_account) }
  let!(:btc_withdraw) { create(:btc_withdraw, member: member, sum: 10, aasm_state: :accepted, account: btc_account) }

  def visit_admin_withdraw_page
    sign_in admin_member
    click_link admin_member.email
    click_on I18n.t('header.admin')
    within '#dashboard-index' do
      expect(page).to have_content(I18n.t('layouts.admin.menus.items.operating.withdraws'))
      click_on I18n.t('layouts.admin.menus.items.operating.withdraws')
    end
  end

  it 'allows admin to view USD withdraws' do
    visit_admin_withdraw_page
    click_link usd_withdraw.currency.code.upcase
    expect(page).to have_content(usd_withdraw.rid)
    expect(page).to have_content(usd_withdraw.amount)
    click_link I18n.t('actions.view')
    page.within_window windows.last do
      expect(page).to have_content(I18n.t('actions.process'))
      expect(page).to have_content(I18n.t('actions.reject'))
    end
  end

  it 'allows admin to process USD withdraw' do
    visit_admin_withdraw_page
    click_link usd_withdraw.currency.code.upcase
    click_link I18n.t('actions.view')
    page.within_window windows.last do
      click_on I18n.t('actions.process')
      expect(current_path).to eq(admin_withdraw_path(currency: usd_account.currency.code, id: usd_account.id))
    end
    expect(usd_account.reload.locked).to be_d '3000'
    expect(usd_account.reload.balance).to be_d '10000'
  end

  it 'allows admin to reject USD withdraw' do
    visit_admin_withdraw_page
    click_link usd_withdraw.currency.code.upcase
    click_on I18n.t('actions.view')
    page.within_window windows.last do
      click_on I18n.t('actions.reject')
      expect(current_path).to eq(admin_withdraw_path(currency: usd_account.currency.code, id: usd_account.id))
    end
    expect(usd_account.reload.locked).to be_d '3000'
    expect(usd_account.reload.balance).to be_d '15000.0000'
  end

  it 'allows admin to view BTC withdraws' do
    visit_admin_withdraw_page
    click_link btc_withdraw.currency.code.upcase
    expect(page).to have_content(btc_withdraw.rid.truncate(22))
    expect(page).to have_content(btc_withdraw.amount)
    click_link I18n.t('actions.view')
    page.within_window windows.last do
      expect(page).to have_content(I18n.t('actions.process'))
      expect(page).to have_content(I18n.t('actions.reject'))
    end
  end

  it 'allows admin to process BTC withdraw' do
    visit_admin_withdraw_page
    click_link btc_withdraw.currency.code.upcase
    click_link I18n.t('actions.view')
    page.within_window windows.last do
      click_on I18n.t('actions.process')
      expect(current_path).to eq(admin_withdraw_path(currency: btc_account.currency.code, id: btc_account.id))
    end
    expect(btc_account.reload.locked).to be_d '10'
    expect(btc_account.reload.balance).to be_d '50'
    expect(btc_withdraw.reload.processing?).to be true
  end

  it 'allows admin to reject BTC withdraw' do
    visit_admin_withdraw_page
    click_link btc_withdraw.currency.code.upcase
    click_on I18n.t('actions.view')
    page.within_window windows.last do
      click_on I18n.t('actions.reject')
      expect(current_path).to eq(admin_withdraw_path(currency: btc_withdraw.currency.code, id: btc_withdraw.id))
    end
    expect(btc_account.reload.locked).to be_d '0'
    expect(btc_account.reload.balance).to be_d '60'
    expect(btc_withdraw.reload.rejected?).to be true
  end
end
