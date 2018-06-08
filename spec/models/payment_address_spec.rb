# encoding: UTF-8
# frozen_string_literal: true

describe PaymentAddress do
  context '.create' do
    let(:member)  { create(:member, :level_3) }
    let!(:account) { member.get_account(:btc) }

    it 'generate address after commit' do
      AMQPQueue.expects(:enqueue)
               .with(:deposit_coin_address, { account_id: account.id }, { persistent: true })
      account.payment_address
    end
  end
end
