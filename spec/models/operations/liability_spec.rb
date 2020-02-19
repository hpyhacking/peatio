# encoding: UTF-8
# frozen_string_literal: true

describe Operations::Liability do
  context :after_commit do
    let(:member) { create(:member, :level_3, :barong) }

    let(:deposit) { create(:deposit_usd, member: member, amount: 0.1) }

    let(:expected_message) do
      { subject: :operation,
        payload: {
          code:           201,
          currency:       'usd',
          member_id:      member.id,
          reference_id:   deposit.id,
          reference_type: 'deposit',
          debit:          '0.0'.to_d,
          credit:         '0.1'.to_d
        }
      }
    end

    before { AMQP::Queue.expects(:enqueue).with(:events_processor, expected_message) }

    it 'publishes message to rabbitmq' do
      # Accept deposit for creation of liability.
      expect(deposit.accept!).to be_truthy
    end
  end
end
