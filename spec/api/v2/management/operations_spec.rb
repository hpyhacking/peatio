# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Operations, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_operations:  { permitted_signers: %i[alex jeff],       mandatory_signers: %i[alex] },
        write_operations: { permitted_signers: %i[alex jeff james], mandatory_signers: %i[alex jeff] }
    }
  end

  def request(op_type)
    post_json "/api/v2/management/#{op_type}", multisig_jwt_management_api_v1({ data: data }, *signers)
  end

  describe 'list operations' do
    Operation::PLATFORM_TYPES.each do |op_type|
      context op_type do
        let(:data) { {} }
        let(:signers) { %i[alex jeff] }
        let(:operations_number) { 15 }
        let!(:operations) { create_list(op_type, operations_number) }

        before do
          request(op_type.to_s.pluralize)
        end

        it { expect(response).to have_http_status(200) }

        context 'filter by currency' do
          let(:data) { { currency: :btc } }
          it { expect(response).to have_http_status(200) }

          it 'returns operations by currency' do
            operations = "operations/#{op_type}"
                            .camelize
                            .constantize
                            .where(currency_id: :btc)
            expect(JSON.parse(response.body).count).to eq operations.count
            expect(JSON.parse(response.body).map { |h| h['currency'] }).to\
              eq operations.pluck(:currency_id)
          end
        end

        context 'pagination' do
          let(:data) { { page: 2, limit: 8 } }

          it { expect(response).to have_http_status(200) }

          it 'returns second page of operations' do
            expect(JSON.parse(response.body).count).to eq 7
            credits = "operations/#{op_type}"
                        .camelize
                        .constantize
                        .order(id: :desc)
                        .pluck(:credit)

            # Consider that credit sequence is unique.
            expect(JSON.parse(response.body).map { |h| h['credit'].to_d }).to eq credits[8..15]
          end
        end
      end
    end

    Operation::MEMBER_TYPES.each do |op_type|
      context op_type do
        let(:data) { {} }
        let(:signers) { %i[alex jeff] }
        let(:operations_number) { 15 }
        let!(:operations) { create_list(op_type, operations_number) }

        before do
          request(op_type.to_s.pluralize)
        end

        it { expect(response).to have_http_status(200) }

        context 'filter by currency' do
          let(:data) { { currency: :btc } }
          it { expect(response).to have_http_status(200) }

          it 'returns operations by currency' do
            operations = "operations/#{op_type}"
                           .camelize
                           .constantize
                           .where(currency_id: :btc)
            expect(JSON.parse(response.body).count).to eq operations.count
            expect(JSON.parse(response.body).map { |h| h['currency'] }).to\
              eq operations.pluck(:currency_id)
          end
        end

        context 'filter by uid' do
          let(:member) { create(:member, :barong) }
          let!(:member_operations) do
            create_list(op_type, operations_number, member_id: member.id)
          end
          let(:data) { { uid: member.uid } }
          it { expect(response).to have_http_status(200) }

          it 'returns operations by member UID' do
            request(op_type.to_s.pluralize)
            operations = "operations/#{op_type}"
                           .camelize
                           .constantize
                           .where(member: member)
            expect(JSON.parse(response.body).count).to eq operations.count
            expect(JSON.parse(response.body).map { |h| h['uid'] }).to\
              eq [member.uid] * operations_number
          end
        end

        context 'pagination' do
          let(:data) { { page: 2, limit: 8 } }

          it { expect(response).to have_http_status(200) }

          it 'returns second page of operations' do
            expect(JSON.parse(response.body).count).to eq 7
            credits = "operations/#{op_type}"
                        .camelize
                        .constantize
                        .order(id: :desc)
                        .pluck(:credit)

            # Consider that credit sequence is unique.
            expect(JSON.parse(response.body).map{ |h| h['credit'].to_d }).to eq credits[8..15]
          end
        end
      end
    end
  end


  # describe 'create withdraw' do
  #   def request
  #     post_json '/api/v2/management/withdraws/new', multisig_jwt_management_api_v1({ data: data }, *signers)
  #   end
  #
  #   let(:member) { create(:member, :barong) }
  #   let(:currency) { Currency.find(:btc) }
  #   let(:amount) { 0.1575 }
  #   let(:signers) { %i[alex jeff] }
  #   let :data do
  #     { uid:      member.uid,
  #       currency: currency.code,
  #       amount:   amount,
  #       rid:      Faker::Bitcoin.address }
  #   end
  #   let(:account) { member.accounts.with_currency(currency).first }
  #   let(:balance) { 1.2 }
  #   before { account.plus_funds(balance) }
  #
  #   context 'crypto withdraw' do
  #     it 'creates new withdraw and immediately submits it' do
  #       request
  #       expect(response).to have_http_status(201)
  #       record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #       expect(record.sum).to eq 0.1575
  #       expect(record.aasm_state).to eq 'submitted'
  #       expect(record.rid).to eq data[:rid]
  #       expect(record.account).to eq account
  #       expect(record.account.balance).to eq (1.2 - amount)
  #       expect(record.account.locked).to eq amount
  #     end
  #
  #     context 'action: :process' do
  #       it 'creates new withdraw and immediately submits it' do
  #         data.merge!(action: 'process')
  #         request
  #         expect(response).to have_http_status(201)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.sum).to eq 0.1575
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(record.rid).to eq data[:rid]
  #         expect(record.account).to eq account
  #         expect(record.account.balance).to eq (1.2 - amount)
  #         expect(record.account.locked).to eq amount
  #       end
  #     end
  #   end
  #
  #   context 'extremely precise values' do
  #     before { Currency.any_instance.stubs(:withdraw_fee).returns(BigDecimal(0)) }
  #     before { Currency.any_instance.stubs(:precision).returns(16) }
  #     it 'keeps precision for amount' do
  #       currency.update!(precision: 16)
  #       data.merge!(amount: '0.0000000123456789')
  #       request
  #       expect(response).to have_http_status(201)
  #       expect(Withdraw.last.sum.to_s).to eq data[:amount]
  #     end
  #   end
  #
  #   context 'fiat withdraw' do
  #     let(:currency) { Currency.find(:usd) }
  #     let(:amount) { 5 }
  #     let(:balance) { 20 }
  #
  #     it 'creates new withdraw with state set to «submitted»' do
  #       request
  #       expect(response).to have_http_status(201)
  #       expect(account.reload.balance).to eq(15)
  #       expect(account.reload.locked).to eq 5
  #       expect(Withdraw.last.aasm_state).to eq 'submitted'
  #     end
  #
  #     context 'action: :process' do
  #       it 'creates new withdraw with state set to «submitted»' do
  #         data.merge!(action: :process)
  #         request
  #         expect(response).to have_http_status(201)
  #         expect(account.reload.balance).to eq(15)
  #         expect(account.reload.locked).to eq 0
  #         expect(Withdraw.last.aasm_state).to eq 'succeed'
  #       end
  #     end
  #   end
  # end

  # describe 'get withdraw' do
  #   def request
  #     post_json '/api/v2/management/withdraws/get', multisig_jwt_management_api_v1({ data: data }, *signers)
  #   end
  #
  #   let(:signers) { %i[alex jeff] }
  #   let(:data) { { tid: record.tid } }
  #   let(:record) { create(:btc_withdraw, member: member) }
  #   let(:member) { create(:member, :barong) }
  #
  #   it 'returns withdraw by TID' do
  #     request
  #     expect(JSON.parse(response.body).fetch('tid')).to eq record.tid
  #   end
  # end

  # describe 'update withdraw' do
  #   def request
  #     put_json '/api/v2/management/withdraws/action', multisig_jwt_management_api_v1({ data: data }, *signers)
  #   end
  #
  #   let(:currency) { Currency.find(:usd) }
  #   let(:member) { create(:member, :barong) }
  #   let(:amount) { 160.79 }
  #   let(:signers) { %i[alex jeff] }
  #   let(:data) { { tid: record.tid } }
  #   let(:account) { member.accounts.with_currency(currency).first }
  #   let(:record) { "Withdraws::#{currency.type.camelize}".constantize.create!(member: member, account: account, sum: amount, rid: Faker::Bank.iban, currency: currency) }
  #   let(:balance) { 800.77 }
  #   before { account.plus_funds(balance) }
  #
  #   context 'crypto withdraws' do
  #     let(:currency) { Currency.find(:btc) }
  #
  #     context 'action: :process' do
  #       before { data[:action] = :process }
  #
  #       it 'processes prepared withdraws' do
  #         expect(record.aasm_state).to eq 'prepared'
  #         expect(account.reload.balance).to eq balance
  #         expect(account.reload.locked).to eq 0
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(record.account.balance).to eq (balance - amount)
  #         expect(record.account.locked).to eq amount
  #       end
  #
  #       it 'processes submitted withdraws' do
  #         record.submit!
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(record.account.balance).to eq (balance - amount)
  #         expect(record.account.locked).to eq amount
  #       end
  #
  #       it 'processes accepted withdraws' do
  #         record.submit!
  #         record.accept!
  #         expect(record.aasm_state).to eq 'accepted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'accepted'
  #         expect(record.account.balance).to eq (balance - amount)
  #         expect(record.account.locked).to eq amount
  #       end
  #     end
  #
  #     context 'action: :cancel' do
  #       before { data[:action] = :cancel }
  #
  #       it 'cancels prepared withdraws' do
  #         expect(record.aasm_state).to eq 'prepared'
  #         expect(account.reload.balance).to eq balance
  #         expect(account.reload.locked).to eq 0
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'canceled'
  #         expect(record.account.balance).to eq balance
  #         expect(record.account.locked).to eq 0
  #       end
  #
  #       it 'cancels submitted withdraws' do
  #         record.submit!
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'canceled'
  #         expect(record.account.balance).to eq balance
  #         expect(record.account.locked).to eq 0
  #       end
  #
  #       it 'cancels accepted withdraws' do
  #         record.submit!
  #         record.accept!
  #         expect(record.aasm_state).to eq 'accepted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'canceled'
  #         expect(record.account.balance).to eq balance
  #         expect(record.account.locked).to eq 0
  #       end
  #     end
  #   end
  #
  #   context 'fiat withdraws' do
  #     context 'action: :process' do
  #       before { data[:action] = :process }
  #       before { Withdraw.any_instance.expects(:quick?).returns(true) }
  #
  #       it 'processes prepared withdraws' do
  #         expect(record.aasm_state).to eq 'prepared'
  #         expect(account.reload.balance).to eq balance
  #         expect(account.reload.locked).to eq 0
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'succeed'
  #         expect(record.account.balance).to eq (balance - amount)
  #         expect(record.account.locked).to eq 0
  #       end
  #
  #       it 'processes submitted withdraws' do
  #         record.submit!
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'succeed'
  #         expect(record.account.balance).to eq (balance - amount)
  #         expect(record.account.locked).to eq 0
  #       end
  #
  #       it 'processes accepted withdraws' do
  #         record.submit!
  #         record.accept!
  #         expect(record.aasm_state).to eq 'accepted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'succeed'
  #         expect(record.account.balance).to eq (balance - amount)
  #         expect(record.account.locked).to eq 0
  #       end
  #     end
  #
  #     context 'action: :cancel' do
  #       before { data[:action] = :cancel }
  #
  #       it 'cancels prepared withdraws' do
  #         expect(record.aasm_state).to eq 'prepared'
  #         expect(account.reload.balance).to eq balance
  #         expect(account.reload.locked).to eq 0
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'canceled'
  #         expect(record.account.balance).to eq balance
  #         expect(record.account.locked).to eq 0
  #       end
  #
  #       it 'cancels submitted withdraws' do
  #         record.submit!
  #         expect(record.aasm_state).to eq 'submitted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'canceled'
  #         expect(record.account.balance).to eq balance
  #         expect(record.account.locked).to eq 0
  #       end
  #
  #       it 'cancels accepted withdraws' do
  #         record.submit!
  #         record.accept!
  #         expect(record.aasm_state).to eq 'accepted'
  #         expect(account.reload.balance).to eq (balance - amount)
  #         expect(account.reload.locked).to eq amount
  #         request
  #         expect(response).to have_http_status(200)
  #         record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
  #         expect(record.aasm_state).to eq 'canceled'
  #         expect(record.account.balance).to eq balance
  #         expect(record.account.locked).to eq 0
  #       end
  #     end
  #   end
  # end
end
