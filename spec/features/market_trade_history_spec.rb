feature 'show account info', js: true do
  let(:other_member) { create :member, :verified_identity }
  let(:member) { create :member, :verified_identity }
  let!(:bid_account) do
    member.get_account(:usd).tap { |a| a.update_attributes locked: 400, balance: 1000 }
  end
  let!(:ask_account) do
    member.get_account(:btc).tap { |a| a.update_attributes locked: 400, balance: 2000 }
  end
  let!(:ask_order) { create :order_ask, price: '23.6', member: member }
  let!(:bid_order) { create :order_bid, price: '21.3', member: other_member }
  let!(:ask_name) { I18n.t('currency.name.btc') }

  scenario 'user can cancel his own order' do
    sign_in member
    click_on I18n.t('header.market')

    AMQPQueue.expects(:enqueue).with(:matching, action: 'cancel', order: ask_order.to_matching_attributes)

    page.within_window(windows.last) do
      click_link page.all('#my_orders_wrapper li').first.text
      expect(page.all('#my_orders .order').count).to eq(1) # can only see his order
      accept_confirm { page.all('#my_orders .order').first.click }
      page.reset!
      expect(page).not_to have_selector('#my_orders .order')
    end
  end
end
