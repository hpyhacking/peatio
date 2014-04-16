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
  let!(:ask_order) { create :order_ask, price: '23.6', member: member }
  let!(:bid_order) { create :order_bid, price: '21.3' }
  let!(:ask_name) { I18n.t('currency.name.btc') }

  scenario 'user can cancel his own order' do
    login identity
    click_on I18n.t('header.market')

    expect(page.all('#orders_wait .order').count).to eq(1) # can only see his order
    expect(page.find('#orders_wait')).to have_content(I18n.t('actions.cancel'))

    AMQPQueue.expects(:enqueue).with(:cancel_order, ask_order.to_matching_attributes)
    click_on I18n.t('actions.cancel')
    sleep 0.5
  end
end
