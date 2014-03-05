require 'spec_helper'

feature 'show account info', js: true do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email  }

  let!(:bid_account) do
    member.get_account('cny').tap { |a| a.update_attributes locked: 12, balance: 1000 }
  end
  let!(:ask_account) do
    member.get_account('btc').tap { |a| a.update_attributes locked: 23, balance: 2000 }
  end

  let!(:ask_order) { create :order_ask, price: '23.6' }
  let!(:bid_order) { create :order_bid, price: '21.3' }
  let!(:ask_name) { I18n.t('currency.name.btc') }

  scenario 'user can ordering successful' do
    login identity
    click_on I18n.t('header.market')

    expect do
      # bid trade panel
      click_on I18n.t('private.markets.show.bid_panel', currency: ask_name)
      fill_in 'order_bid_origin_volume', :with => '4.5'
      expect(page.find('#order_bid_sum')).to be_d ('4.5'.to_d * ask_order.price)
      click_on I18n.t('helpers.submit.order_bid.create')
      expect(page).to have_content(I18n.t('private.markets.show.success'))
    end.to change{ OrderBid.all.size }.from(1).to(2)

    expect do
      # bid trade panel
      click_on I18n.t('private.markets.show.ask_panel', currency: ask_name)
      fill_in 'order_ask_origin_volume', :with => '4.5'
      expect(page.find('#order_ask_sum')).to be_d ('4.5'.to_d * bid_order.price)
      click_on I18n.t('helpers.submit.order_ask.create')
      expect(page).to have_content(I18n.t('private.markets.show.success'))
    end.to change{ OrderAsk.all.size }.from(1).to(2)
  end

  scenario 'user can use default asks or bids first price in ordering' do
    login identity
    click_on I18n.t('header.market')

    # bid trade panel
    click_on I18n.t('private.markets.show.bid_panel', currency: ask_name)
    expect(page.find('#order_bid_price')).to be_d ask_order.price

    # ask trade panel
    click_on I18n.t('private.markets.show.ask_panel', currency: ask_name)
    expect(page.find('#order_ask_price')).to be_d bid_order.price
  end

  scenario 'user can view itself account balance, locked funds in market view' do
    login identity
    click_on I18n.t('header.market')

    # ask trade panel
    click_on I18n.t('private.markets.show.bid_panel', currency: ask_name)
    expect(page.find('.locked-funds').find('span.bid')).to be_d bid_account.locked
    expect(page.find('.available-funds').find('span.bid')).to be_d bid_account.balance
    expect(page.find('.locked-funds').find('span.ask')).to be_d ask_account.locked
    expect(page.find('.available-funds').find('span.ask')).to be_d ask_account.balance

    # ask trade panel
    click_on I18n.t('private.markets.show.ask_panel', currency: ask_name)
    expect(page.find('.locked-funds').find('span.bid')).to be_d bid_account.locked
    expect(page.find('.available-funds').find('span.bid')).to be_d bid_account.balance
    expect(page.find('.locked-funds').find('span.ask')).to be_d ask_account.locked
    expect(page.find('.available-funds').find('span.ask')).to be_d ask_account.balance
  end
end
