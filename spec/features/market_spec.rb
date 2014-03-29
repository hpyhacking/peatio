require 'spec_helper'

feature 'show account info', js: true do
  let!(:identity) { create :identity }
  let!(:member) { create :member, :activated, email: identity.email  }

  let!(:bid_account) do
    member.get_account('cny') { |a|
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

  before { Resque.stubs(:enqueue) }

  scenario 'user can place a buy order by filling in the order form' do
    login identity
    click_on I18n.t('header.market')

    expect do
      # bid trade panel
      click_link I18n.t('private.markets.place_order.bid_panel', currency: ask_name)
      fill_in 'order_bid_price', :with => 22.2
      fill_in 'order_bid_origin_volume', :with => 45
      expect(page.find('#order_bid_sum').value).to be_d (45 * 22.2).to_d

      click_on I18n.t('private.markets.place_order.place_order')
      expect(page).to have_content(I18n.t('private.markets.show.success'))
      expect(page.find('.bids tr[data-order="1"] .price').text).to eq("22.2000")
    end.to change{ OrderBid.all.count }.by(1)
  end

  scenario 'user can place an order by clicking on existing orders from order book' do
    login identity
    click_on I18n.t('header.market')

    # bid trade panel
    click_link I18n.t('private.markets.place_order.bid_panel', currency: ask_name)
    expect(page.find('#order_bid_price')).to be_d ask_order.price

    # ask trade panel
    click_link I18n.t('private.markets.show.ask_panel', currency: ask_name)
    expect(page.find('#order_ask_price')).to be_d bid_order.price
  end

  scenario 'user can view his account balance' do
    login identity
    click_on I18n.t('header.market')

    # account balance panel
    expect(page.find('.available-cash .value').text).to be_d bid_account.balance
    expect(page.find('.available-coin .value').text).to be_d ask_account.balance

    # order panel
    click_link I18n.t('private.markets.place_order.bid_panel', currency: ask_name)
    expect(page.find('.current-balance .value').text).to be_d bid_account.balance
    click_link I18n.t('private.markets.place_order.ask_panel', currency: ask_name)
    expect(page.find('.current-balance .value').text).to be_d ask_account.balance
  end
end
