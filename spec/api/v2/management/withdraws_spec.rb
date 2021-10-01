# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Withdraws, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_withdraws:  { permitted_signers: %i[alex jeff],       mandatory_signers: %i[alex] },
        write_withdraws: { permitted_signers: %i[alex jeff james], mandatory_signers: %i[alex jeff] }
      }
  end

  describe 'list withdraws' do
    def request
      post_json '/api/v2/management/withdraws', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }
    let(:signers) { %i[alex jeff] }
    let(:blockchain_key) { 'btc-testnet' }
    let(:members) { create_list(:member, 2, :barong) }

    before do
      Withdraw::STATES.tap do |states|
        (states.count * 2).times do
          create(:btc_withdraw, :with_deposit_liability, sum: 1, member: members.sample, aasm_state: states.sample, rid: Faker::Blockchain::Bitcoin.address)
          create(:usd_withdraw, :with_deposit_liability, sum: 1, member: members.sample, aasm_state: states.sample, rid: Faker::Bank.iban)
        end
      end
    end

    it 'returns withdraws' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('tid') }).to eq Withdraw.order(id: :desc).pluck(:tid)
    end

    it 'filters by member' do
      member = members.last
      data.merge!(uid: member.uid)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq member.withdraws.count
    end

    it 'filters by blockchain key' do
      data.merge!(blockchain_key: blockchain_key)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq Withdraw.where(blockchain_key: blockchain_key).count
    end

    it 'filters by currency' do
      data.merge!(currency: :usd)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq Withdraw.where(currency_id: :usd).count
    end

    it 'filters by state' do
      Withdraw::STATES.each do |state|
        data.merge!(state: state)
        request
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body).count).to eq Withdraw.where(aasm_state: state).count
      end
    end

    it 'paginates' do
      ids = Withdraw.order(id: :desc).pluck(:tid)
      data.merge!(page: 1, limit: 4)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('tid') }).to eq ids[0...4]
      data.merge!(page: 3, limit: 4)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('tid') }).to eq ids[8...12]
    end
  end

  describe 'create withdraw' do
    def request
      post_json '/api/v2/management/withdraws/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:member) { create(:member, :barong) }
    let(:currency) { Currency.find(:btc) }
    let(:blockchain_key) { 'btc-testnet' }
    let(:amount) { 0.1575 }
    let(:signers) { %i[alex jeff] }
    let :data do
      { uid:      member.uid,
        currency: currency.code,
        amount:   amount.to_s,
        blockchain_key: blockchain_key,
        rid:      Faker::Blockchain::Bitcoin.address }
    end
    let(:account) { member.get_account(currency) }
    let(:balance) { 1.2 }
    before { account.plus_funds(balance) }

    context 'crypto withdraw' do
      it 'creates new withdraw and immediately submits it' do
        request
        expect(response).to have_http_status(201)
        record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
        expect(record.sum).to eq 0.1575
        expect(record.aasm_state).to eq 'accepted'
        expect(record.rid).to eq data[:rid]
        expect(record.account).to eq account
        expect(record.account.balance).to eq (1.2 - amount)
        expect(record.account.locked).to eq amount
        expect(response_body['transfer_type']).to eq 'crypto'
        expect(response_body['blockchain_key']).to eq blockchain_key
      end

      context 'disabled currency' do
        before do
          BlockchainCurrency.find_by(currency_id: currency.id).update(withdrawal_enabled: false)
        end

        it 'returns error for disabled withdrawal' do
          request
          expect(response).to have_http_status(422)
          expect(response).to include_api_error('management.currency.withdrawal_disabled')
        end
      end

      context 'withdrawal with beneficiary' do
        let(:beneficiary) { create(:beneficiary, blockchain_key: 'btc-testnet', state: :active, currency: currency) }
        let(:data) do
          { uid:      member.uid,
            currency: currency.code,
            amount:   amount.to_s,
            beneficiary_id: beneficiary.id }
        end

        it 'creates new withdraw and immediately submits it' do
          request
          expect(response).to have_http_status(201)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.sum).to eq 0.1575
          expect(record.aasm_state).to eq 'accepted'
          expect(record.rid).to eq beneficiary.rid
          expect(record.account).to eq account
          expect(record.account.balance).to eq (1.2 - amount)
          expect(record.account.locked).to eq amount
          expect(record.blockchain_key).to eq beneficiary.blockchain_key
        end

        context 'pending beneficiary' do
          before do
            beneficiary.update(state: :pending)
          end

          it 'returns error for pending beneficiary' do
            request
            expect(response).to have_http_status(422)
            expect(response).to include_api_error('management.beneficiary.invalid_state_for_withdrawal')
          end
        end

        context 'withdrawal with note' do
          let(:member) { create(:member, :barong) }
          let(:currency) { Currency.find(:btc) }
          let(:amount) { 0.1575 }
          let(:signers) { %i[alex jeff] }
          let :data do
            { uid:      member.uid,
              currency: currency.code,
              amount:   amount.to_s,
              blockchain_key: blockchain_key,
              rid:      Faker::Blockchain::Bitcoin.address,
              note:     'Withdraw money'
            }
          end

          it 'returns new withdraw with correct note' do
            request
            expect(JSON.parse(response.body)['note']).to eq 'Withdraw money'
          end
        end

        context 'withdrawal with transfer_type' do
          let(:member) { create(:member, :barong) }
          let(:currency) { Currency.find(:btc) }
          let(:amount) { 0.1575 }
          let(:signers) { %i[alex jeff] }
          let :data do
            { uid:      member.uid,
              currency: currency.code,
              blockchain_key: blockchain_key,
              amount:   amount.to_s,
              rid:      Faker::Blockchain::Bitcoin.address,
              transfer_type:   'card'
            }
          end

          it 'returns new withdraw with correct transfer_type' do
            request
            expect(JSON.parse(response.body)['transfer_type']).to eq 'card'
          end
        end
      end

      context 'action: :review' do
        it 'creates new withdraw with under_review state' do
          data.merge!(action: 'review')
          request
          expect(response).to have_http_status(201)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.sum).to eq 0.1575
          expect(record.aasm_state).to eq 'under_review'
          expect(record.rid).to eq data[:rid]
          expect(record.account).to eq account
          expect(record.account.balance).to eq (1.2 - amount)
          expect(record.account.locked).to eq amount
          expect(record.blockchain_key).to eq blockchain_key
        end
      end

      context 'action: :process' do
        it 'creates new withdraw and immediately submits it' do
          data.merge!(action: 'process')
          request
          expect(response).to have_http_status(201)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.sum).to eq 0.1575
          expect(record.aasm_state).to eq 'accepted'
          expect(record.rid).to eq data[:rid]
          expect(record.account).to eq account
          expect(record.account.balance).to eq (1.2 - amount)
          expect(record.account.locked).to eq amount
          expect(record.blockchain_key).to eq blockchain_key
        end
      end

      context 'invalid withdraw' do
        before do
          data[:action] = :process
          data[:amount] = '1000'
        end
        it 'validates enough balance' do
          request
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)).to eq("errors"=>["Account balance is insufficient"])
        end
      end
    end

    context 'extremely precise values' do
      before { BlockchainCurrency.any_instance.stubs(:withdraw_fee).returns(BigDecimal(0)) }
      before { Currency.any_instance.stubs(:precision).returns(16) }
      before { BlockchainCurrency.any_instance.stubs(:subunits).returns(16) }
      it 'keeps precision for amount' do
        data.merge!(amount: '0.0000000123456789')
        request
        expect(response).to have_http_status(201)
        expect(Withdraw.last.sum.to_s).to eq data[:amount]
      end
    end

    context 'fiat withdraw' do
      let(:currency) { Currency.find(:usd) }
      let(:blockchain_key) { 'fiat' }
      let(:amount) { 5 }
      let(:balance) { 20 }

      it 'creates new withdraw with state set to «submitted»' do
        request
        expect(response).to have_http_status(201)
        expect(account.reload.balance).to eq(15)
        expect(account.reload.locked).to eq 5
        expect(Withdraw.last.aasm_state).to eq 'accepted'
      end

      context 'action: :review' do
        it 'creates new withdraw with «under_review» state' do
          data.merge!(action: :review)
          request
          expect(response).to have_http_status(201)
          expect(account.reload.balance).to eq 15
          expect(account.reload.locked).to eq 5
          expect(Withdraw.last.aasm_state).to eq 'under_review'
        end
      end

      context 'action: :process' do
        it 'creates new withdraw with state set to «submitted»' do
          data.merge!(action: :process)
          request
          expect(response).to have_http_status(201)
          expect(account.reload.balance).to eq(15)
          expect(account.reload.locked).to eq 0
          expect(Withdraw.last.aasm_state).to eq 'succeed'
        end
      end
    end
  end

  describe 'get withdraw' do
    def request
      post_json '/api/v2/management/withdraws/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { { tid: record.tid } }
    let(:record) { create(:btc_withdraw, :with_deposit_liability, member: member) }
    let(:member) { create(:member, :barong) }

    it 'returns withdraw by TID' do
      request
      expect(JSON.parse(response.body).fetch('tid')).to eq record.tid
      expect(JSON.parse(response.body).fetch('blockchain_key')).to eq record.blockchain_key
    end
  end

  describe 'update withdraw' do
    def request
      put_json '/api/v2/management/withdraws/action', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:currency) { Currency.find(:usd) }
    let(:member) { create(:member, :barong) }
    let(:amount) { 160.79 }
    let(:signers) { %i[alex jeff] }
    let(:data) { { tid: record.tid } }
    let(:account) { member.get_account(currency) }
    let(:balance) { 800.77 }
    before { account.plus_funds(balance) }

    context 'crypto withdraws' do
      let(:currency) { Currency.find(:btc) }
      let!(:record) { "Withdraws::Coin".constantize.create!(member: member, blockchain_key: 'btc-testnet', sum: amount, rid: Faker::Bank.iban, currency: currency) }

      context 'action: :process' do
        before { data[:action] = :process }

        it 'processes prepared withdraws' do
          expect(record.aasm_state).to eq 'prepared'
          expect(account.reload.balance).to eq balance
          expect(account.reload.locked).to eq 0
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'accepted'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq amount
        end

        it 'processes submitted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'accepted'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq amount
        end

        it 'processes accepted withdraws' do
          record.accept!
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'accepted'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq amount
        end
      end

      context 'action: :cancel' do
        before { data[:action] = :cancel }

        it 'cancels prepared withdraws' do
          expect(record.aasm_state).to eq 'prepared'
          expect(account.reload.balance).to eq balance
          expect(account.reload.locked).to eq 0
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'canceled'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'cancels submitted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'canceled'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'cancels accepted withdraws' do
          record.accept!
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'canceled'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end
      end

      context 'action: :reject' do
        before { data[:action] = :reject }

        it 'rejects accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'rejected'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'rejects withdraws with under_review state' do
          record.accept!
          record.process!
          record.review!
          expect(record.aasm_state).to eq 'under_review'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'rejected'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end
      end
    end

    context 'fiat withdraws' do
      let!(:record) { "Withdraws::Fiat".constantize.create!(member: member, blockchain_key: 'fiat', sum: amount, rid: Faker::Bank.iban, currency: currency) }

      context 'action: :process' do
        before { data[:action] = :process }

        it 'processes prepared withdraws' do
          expect(record.aasm_state).to eq 'prepared'
          expect(account.reload.balance).to eq balance
          expect(account.reload.locked).to eq 0
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'succeed'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq 0
        end

        it 'processes accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'succeed'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq 0
        end

        it 'processes accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'succeed'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq 0
        end
      end

      context 'action: :cancel' do
        before { data[:action] = :cancel }

        it 'cancels prepared withdraws' do
          expect(record.aasm_state).to eq 'prepared'
          expect(account.reload.balance).to eq balance
          expect(account.reload.locked).to eq 0
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'canceled'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'cancels accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'canceled'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'cancels accepted withdraws' do
          record.accept!
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'canceled'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end
      end

      context 'action: :reject' do
        before { data[:action] = :reject }

        it 'rejects accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'rejected'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'rejects withdraws with under_review state' do
          record.accept!
          record.process!
          record.review!
          expect(record.aasm_state).to eq 'under_review'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'rejected'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end
      end

      context 'action: :review' do
        before { data[:action] = :review }

        it 'sets under_review state for prepared withdraws' do
          expect(record.aasm_state).to eq 'prepared'
          expect(account.reload.balance).to eq balance
          expect(account.reload.locked).to eq 0
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'under_review'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq amount
        end

        it 'sets under_review state for accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'under_review'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq amount
        end
      end

      context 'action: :success' do
        before { data[:action] = :success }

        it 'doesnt change prepared withdraws' do
          expect(record.aasm_state).to eq 'prepared'
          expect(account.reload.balance).to eq balance
          expect(account.reload.locked).to eq 0
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'prepared'
          expect(record.account.balance).to eq balance
          expect(record.account.locked).to eq 0
        end

        it 'doesnt change accepted withdraws' do
          record.accept!
          expect(record.aasm_state).to eq 'accepted'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'accepted'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq amount
        end

        it 'successfully withdraws in under_review state' do
          record.accept!
          record.process!
          record.review!
          expect(record.aasm_state).to eq 'under_review'
          expect(account.reload.balance).to eq (balance - amount)
          expect(account.reload.locked).to eq amount
          request
          expect(response).to have_http_status(200)
          record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
          expect(record.aasm_state).to eq 'succeed'
          expect(record.account.balance).to eq (balance - amount)
          expect(record.account.locked).to eq 0
        end
      end
    end
  end
end
