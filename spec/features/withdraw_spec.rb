require 'spec_helper'

describe 'withdraw' do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email  }

  let(:radio_label) do
    "#{member.name} @ #{identity.email}"
  end

  before do
    Withdraw.any_instance.stubs(:examine).returns(true)
    btc_account = member.get_account(:btc)
    btc_account.update_attributes balance: 1000
    cny_account = member.get_account(:cny)
    cny_account.update_attributes balance: 100000

    @label = 'command address'
    @btc_addr = create :btc_withdraw_address, account: btc_account, label: @label
    @cny_addr = create :cny_withdraw_address, account: cny_account, label: @label
  end

  it 'allows user to add a BTC withdraw address, withdraw BTC' do
    login identity

    expect(page).to have_content identity.email

    visit new_withdraw_path
    expect(page).to have_text("1000.0")

    # submit withdraw request
    submit_withdraw_request 600

    form = find('.simple_form')
    expect(form).to have_text('600.0')
    expect(form).to have_text('0.0')

    click_on t('actions.confirm')

    expect(page).to have_text("400.0")
    #expect(find('.account-cny .locked').text).to eq("600.0")

    expect(current_path).to eq(new_withdraw_path)
    expect(page).to have_text(I18n.t('private.withdraws.update.request_accepted'))
  end

  it 'allow user to see their current position in the withdraw process queue' do
    admin_identity = create :identity, email: Member.admins.first
    deposit admin_identity, member, 2500

    # sign out admin
    find('#sign_out').click

    login identity

    visit new_withdraw_path(currency: 'cny')

    # 1st withdraw
    submit_withdraw_request 800
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraw_path)
    expect(page).to have_text("1700.0")
    #expect(find('.account-cny .locked').text).to eq("800.0")
    expect(find('tbody tr:first-of-type .position_in_queue').text).to eq("1")

    # 2nd withdraw
    submit_withdraw_request 800
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraw_path)
    expect(page).to have_text("900.0")
    #expect(find('.account-cny .locked').text).to eq("1600.0")
    expect(find('tbody tr:first-of-type .position_in_queue').text).to eq("2")

    submit_withdraw_request 600
    click_on t('actions.confirm')
    expect(page).to have_text("300.0")
    #expect(find('.account-cny .locked').text).to eq("2200.0")
    expect(current_path).to eq(new_withdraw_path)

    within('tbody tr:last-of-type') do
      click_link t('actions.cancel')
    end
    expect(current_path).to eq(new_withdraw_path)

    expect(page).to have_text("1100.0")
    #expect(find('.account-cny .locked').text).to eq("1600.0")
  end

  private

  def submit_withdraw_request amount
    select @label, from: 'withdraw_address'
    fill_in 'withdraw_address_label', with: 'withdraw address'
    fill_in 'withdraw_sum', with: amount
    click_on I18n.t 'helpers.submit.withdraw.new'
  end
end
