require 'spec_helper'

describe 'withdraw' do
  let!(:identity) { create :identity }
  let!(:member) { create :verified_member, email: identity.email}

  let(:radio_label) do
    "#{member.name} @ #{identity.email}"
  end

  before do
    Withdraw.any_instance.stubs(:examine).returns(true)
    CoinRPC.any_instance.stubs(:validateaddress).returns({isvalid: true, ismine: false})

    btc_account = member.get_account(:btc)
    btc_account.update_attributes balance: 1000
    cny_account = member.get_account(:cny)
    #cny_account.update_attributes balance: 0

    @label = 'common address'
    @bank = 'bc'
    @btc_addr = create :btc_fund_source, extra: @label, uid: '1btcaddress', member: member
    @cny_addr = create :cny_fund_source, extra: @bank, uid: '1234566890', member: member
  end

  it 'allows user to add a BTC withdraw address, withdraw BTC' do
    login identity

    expect(page).to have_content identity.email

    visit new_withdraws_satoshi_path
    expect(page).to have_text("1000.0")

    # submit withdraw request
    submit_satoshi_withdraw_request 600

    form = find('.simple_form')
    expect(form).to have_text('600.0')
    expect(form).to have_text('0.0')

    click_on t('actions.confirm')

    expect(current_path).to eq(new_withdraws_satoshi_path)
    expect(page).to have_text(I18n.t('private.withdraws.satoshis.update.notice'))
    expect(page).to have_text("400.0")
  end

  it 'allow user to see their current position in the withdraw process queue' do
    pending 'withdraw dashboard'
    admin_identity = create :identity, email: Member.admins.first
    deposit admin_identity, member, 2500

    # sign out admin
    find('#sign_out').click

    login identity

    visit new_withdraws_bank_path

    # 1st withdraw
    submit_bank_withdraw_request 800
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraws_bank_path)
    expect(page).to have_text("1700.0")
    expect(find('tbody tr:first-of-type .position_in_queue').text).to eq("1")

    # 2nd withdraw
    submit_bank_withdraw_request 800
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraws_bank_path)
    expect(page).to have_text("900.0")
    expect(find('tbody tr:first-of-type .position_in_queue').text).to eq("2")

    submit_bank_withdraw_request 600
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraws_bank_path)
    expect(page).to have_text("300.0")

    within('tbody tr:last-of-type') do
      click_link t('actions.cancel')
    end
    expect(current_path).to eq(new_withdraws_bank_path)
    expect(page).to have_text("1100.0")
  end

  it 'prevents withdraws that the account has no sufficient balance' do
    login identity

    visit new_withdraws_bank_path

    submit_bank_withdraw_request 800
    expect(current_path).to eq(withdraws_banks_path)
    expect(page).to have_text(I18n.t('activerecord.errors.models.withdraws/bank.attributes.sum.poor'))
  end

  private

  def submit_bank_withdraw_request amount
    select 'Bank of China', from: 'withdraw_fund_extra'
    select @bank, from: 'withdraw_fund_uid'
    fill_in 'withdraw_sum', with: amount
    click_on I18n.t 'actions.submit'
  end

  def submit_satoshi_withdraw_request amount
    select @label, from: 'withdraw_fund_uid'
    fill_in 'withdraw_fund_extra', with: @label
    fill_in 'withdraw_sum', with: amount
    click_on I18n.t 'actions.submit'
  end
end
