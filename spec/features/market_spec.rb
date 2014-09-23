require 'spec_helper'

feature 'show account info', js: true do
  let!(:identity) { create :identity }
  let!(:member) { create :member, :activated, email: identity.email  }

  let!(:bid_account) do
    member.get_account('cny').tap { |a|
      a.plus_funds 1000
      a.save!
    }
  end
  let!(:ask_account) do
    member.get_account('btc').tap { |a|
      a.plus_funds 2000
      a.save!
    }
  end

  let!(:ask_order) { create :order_ask, price: '23.6' }
  let!(:bid_order) { create :order_bid, price: '21.3' }
  let!(:ask_name) { I18n.t('currency.name.btc') }

  let(:global) { Global[Market.find('btccny')] }

  scenario 'user can place a buy order by filling in the order form' do
    login identity
    click_on I18n.t('header.market')

    expect do
      click_link I18n.t('private.markets.place_order.bid_panel', currency: ask_name)
      fill_in 'order_bid_price', :with => 22.2
      fill_in 'order_bid_origin_volume', :with => 45
      expect(page.find('#order_bid_total').value).to be_d (45 * 22.2).to_d

      click_button I18n.t('private.markets.place_order.bid_panel', currency: ask_name)
      sleep 0.1 # sucks :(
      expect(page.find('#bid_panel span.label-success').text).to eq I18n.t('private.markets.show.success')
    end.to change{ OrderBid.all.count }.by(1)
  end

  scenario 'user can place a sell order by filling in the order form' do
    login identity
    click_on I18n.t('header.market')

    expect do
      click_link I18n.t('private.markets.place_order.ask_panel', currency: ask_name)
      fill_in 'order_ask_price', :with => 22.2
      fill_in 'order_ask_origin_volume', :with => 45
      expect(page.find('#order_ask_total').value).to be_d (45 * 22.2).to_d

      click_button I18n.t('private.markets.place_order.ask_panel', currency: ask_name)
      sleep 0.1 # sucks :(
      expect(page.find('#ask_panel span.label-success').text).to eq I18n.t('private.markets.show.success')
    end.to change{ OrderAsk.all.count }.by(1)
  end

  scenario 'user can fill order form by clicking on an existing orders in the order book' do
    global.stubs(:asks).returns([[ask_order.price, ask_order.volume]])
    global.stubs(:bids).returns([[bid_order.price, bid_order.volume]])
    Global.stubs(:[]).returns(global)

    login identity
    click_on I18n.t('header.market')

    page.find('.asks tr[data-order="0"]').click
    expect(find('#order_bid_price').value).to be_d ask_order.price
    expect(find('#order_bid_origin_volume').value).to be_d ask_order.volume

    page.find('.bids tr[data-order="0"]').click
    expect(find('#order_ask_price').value).to be_d bid_order.price
    expect(find('#order_ask_origin_volume').value).to be_d bid_order.volume
  end

  scenario 'user can view his account balance' do
    login identity
    click_on I18n.t('header.market')

    # account balance at place order panel
    click_link I18n.t('private.markets.place_order.bid_panel', currency: ask_name)
    expect(page.find('.current-balance .value').text).to be_d bid_account.balance
    click_link I18n.t('private.markets.place_order.ask_panel', currency: ask_name)
    expect(page.find('.current-balance .value').text).to be_d ask_account.balance
  end
end
