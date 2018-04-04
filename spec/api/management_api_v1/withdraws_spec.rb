describe ManagementAPIv1::Withdraws, type: :request do
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
      post_json '/management_api/v1/withdraws', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }
    let(:signers) { %i[alex jeff] }
    let(:members) { create_list(:member, 2, :barong) }

    before do
      Withdraw::STATES.tap do |states|
        (states.count * 2).times do
          member      = members.sample
          destination = create(:coin_withdraw_destination, member: member)
          create(:btc_withdraw, member: member, aasm_state: states.sample, destination: destination)

          member      = members.sample
          destination = create(:fiat_withdraw_destination, member: member)
          create(:usd_withdraw, member: member, aasm_state: states.sample, destination: destination)
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
      data.merge!(uid: member.authentications.first.uid)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq member.withdraws.count
    end

    it 'filters by currency' do
      data.merge!(currency: :usd)
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq Withdraw.with_currency(:usd).count
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
      post_json '/management_api/v1/withdraws/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:member) { create(:member, :barong) }
    let(:currency) { Currency.find_by!(code: :btc) }
    let(:amount) { 0.1575 }
    let(:signers) { %i[alex jeff] }
    let :data do
      { uid:      member.authentications.first.uid,
        currency: currency.code,
        amount:   amount,
        rid:      Faker::Bitcoin.address }
    end
    let(:account) { member.accounts.with_currency(currency).first }

    before { account.update!(balance: 1.2) }

    it 'creates new withdraw with state «prepared»' do
      request
      expect(response).to have_http_status(201)
      record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
      expect(record.sum).to eq 0.1575
      expect(record.aasm_state).to eq 'prepared'
      expect(record.rid).to eq data[:rid]
      expect(record.account).to eq account
      expect(record.account.balance).to eq 1.2
      expect(record.account.locked).to eq 0
    end

    it 'creates new withdraw and immediately submits it' do
      data.merge!(state: :submitted)
      request
      expect(response).to have_http_status(201)
      expect(account.reload.balance).to eq(1.2 - amount)
      expect(account.reload.locked).to eq amount
    end

    context 'when creating coin withdraw' do
      it 'creates destination' do
        expect { request }.to change { WithdrawDestination::Coin.count }.by(1)
        expect(response).to have_http_status(201)
        record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
        expect(record.destination.address).to eq record.rid
      end
    end

    context 'when creating fiat withdraw' do
      let(:currency) { Currency.find_by!(code: :usd) }
      let(:klass) { WithdrawDestination::Fiat }
      it 'creates dummy destination' do
        expect { request }.to change { klass.count }.by(1)
        expect(response).to have_http_status(201)
        record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
        keys = klass.fields.keys.map(&:to_s) + ['label']
        expect(record.destination.as_json.slice(*keys).values.uniq).to eq ['dummy']
      end
    end
  end

  describe 'get withdraw' do
    def request
      post_json '/management_api/v1/withdraws/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { { tid: record.tid } }
    let(:record) { create(:btc_withdraw, member: member) }
    let(:member) { create(:member, :barong) }

    it 'returns withdraw by TID' do
      request
      expect(JSON.parse(response.body).fetch('tid')).to eq record.tid
    end
  end

  describe 'update withdraw' do
    def request
      put_json '/management_api/v1/withdraws/state', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:currency) { Currency.find_by!(code: :usd) }
    let(:member) { create(:member, :barong) }
    let(:destination) { create(:fiat_withdraw_destination, currency: currency, member: member) }
    let(:amount) { 160.79 }
    let(:signers) { %i[alex jeff] }
    let(:data) { { tid: record.tid } }
    let(:account) { member.accounts.with_currency(currency).first }
    let(:record) { Withdraws::Fiat.create!(member: member, account: account, sum: amount, destination: destination, currency: currency) }
    let(:balance) { 800.77 }
    before { account.update!(balance: balance) }

    it 'updates from «prepared» to «submitted»' do
      expect(account.balance).to eq balance
      expect(account.locked).to eq 0
      data[:state] = :submitted
      request
      expect(response).to have_http_status(200)
      record = Withdraw.find_by_tid!(JSON.parse(response.body).fetch('tid'))
      expect(record.aasm_state).to eq 'submitted'
      expect(record.account.balance).to eq(balance - amount)
      expect(record.account.locked).to eq(amount)
    end

    it 'doesn\'t allow to submit withdraw twice' do
      record.submit!
      expect(record.aasm_state).to eq 'submitted'
      expect { request }.not_to(change { record.reload.aasm_state })
      expect(response).to have_http_status(422)
      expect(record.account.balance).to eq(balance - amount)
      expect(record.account.locked).to eq(amount)
    end
  end
end
