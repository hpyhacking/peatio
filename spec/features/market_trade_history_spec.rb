require 'spec_helper'

feature 'show account info', js: true do
  let(:identity) { create :identity }
  let(:other_member) { create :member }
  let(:member) { create :member, email: identity.email}
  let!(:bid_account) do
    member.get_account('cny').tap { |a| a.update_attributes locked: 400, balance: 1000 }
  end
  let!(:ask_account) do
    member.get_account('btc').tap { |a| a.update_attributes locked: 400, balance: 2000 }
  end
  let!(:ask_name) { I18n.t('currency.name.btc') }

  scenario 'user can cancel self orders' do
    bid_order = create :order_bid, member: member

    login identity
    click_on I18n.t('header.market')
    click_on I18n.t('private.markets.show.bid_panel', currency: ask_name)
    expect(page.find('.orders-wait')).to have_content(I18n.t('actions.cancel'))

    Resque.expects(:enqueue).with(Job::Matching, 'cancel', bid_order.to_matching_attributes)
    click_on I18n.t('actions.cancel')
    sleep 0.5
  end

  scenario 'user can not view other orders' do
    bid_order = create :order_bid, member: other_member

    login identity
    click_on I18n.t('header.market')
    click_on I18n.t('private.markets.show.bid_panel', currency: ask_name)
    expect(page.find('.orders-wait')).to_not have_content(I18n.t('actions.cancel'))
  end
end
