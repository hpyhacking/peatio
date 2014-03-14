require 'spec_helper'

describe 'withdraw' do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email  }

  let(:radio_label) do
    "#{member.name} @ #{identity.email}"
  end

  before do
    Withdraw.any_instance.stubs(:examine).returns(true)
    account = member.get_account(:cny)
    account.update_attributes balance: 1000
  end

  it 'allows user to add a CNY withdraw address, withdraw CNY' do
    login identity
    create_withdraw_address

    expect(page).to have_content identity.email
    expect(find('.account-cny .available').text).to eq("1000.0")
    expect(find('.account-cny .locked').text).to eq("0.0")

    # submit withdraw request
    submit_withdraw_request 600

    form = find('.simple_form')
    expect(form).to have_text(I18n.t('enumerize.withdraw.state.submitting'))
    expect(form).to have_text('600.0')
    expect(form).to have_text('0.0')

    click_on t('actions.confirm')

    expect(find('.account-cny .available').text).to eq("400.0")
    expect(find('.account-cny .locked').text).to eq("600.0")

    expect(current_path).to eq(new_withdraw_path)
    expect(page).to have_text(I18n.t('private.withdraws.update.request_accepted'))
  end

  it 'allow user to see their current position in the withdraw process queue' do
    admin_identity = create :identity, email: Member.admins.first
    deposit admin_identity, member, 1500

    # sign out admin
    find('#sign_out').click

    login identity
    create_withdraw_address

    # 1st withdraw
    submit_withdraw_request 800
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraw_path)
    expect(find('.account-cny .available').text).to eq("1700.0")
    expect(find('.account-cny .locked').text).to eq("800.0")
    expect(find('tbody tr:last-of-type .position_in_queue').text).to eq("1")

    # 2nd withdraw
    submit_withdraw_request 800
    click_on t('actions.confirm')
    expect(current_path).to eq(new_withdraw_path)
    expect(find('.account-cny .available').text).to eq("900.0")
    expect(find('.account-cny .locked').text).to eq("1600.0")
    expect(find('tbody tr:last-of-type .position_in_queue').text).to eq("2")

    submit_withdraw_request 600
    click_on t('actions.confirm')
    expect(find('.account-cny .available').text).to eq("300.0")
    expect(find('.account-cny .locked').text).to eq("2200.0")
    expect(current_path).to eq(new_withdraw_path)

    within('tbody tr:last-of-type') do
      click_link t('actions.view')
    end
    click_on t('actions.cancel')
    expect(current_path).to eq(new_withdraw_path)

    expect(find('.account-cny .available').text).to eq("900.0")
    expect(find('.account-cny .locked').text).to eq("1600.0")
  end

  private

  def create_withdraw_address
    visit root_path
    click_on I18n.t 'header.withdraw'

    # add withdraw address
    click_on I18n.t 'helpers.submit.withdraw_address.create'

    fill_in 'withdraw_address_label', with: member.name
    fill_in 'withdraw_address_address', with: identity.email
    select I18n.t('enumerize.withdraw.address_type.bank'), from: 'withdraw_address_category'
    click_on I18n.t 'helpers.submit.withdraw_address.create'
  end

  def submit_withdraw_request amount
    select radio_label, from: 'Withdraw address'
    fill_in 'withdraw_sum', with: amount
    click_on I18n.t 'helpers.submit.withdraw.new'
  end
end
