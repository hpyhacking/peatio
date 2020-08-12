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

  describe 'list operations' do
    def request(op_type)
      post_json "/api/v2/management/#{op_type}", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    def optional_request(op_type, data)
      post_json "/api/v2/management/#{op_type}", multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    Operations::Account::PLATFORM_TYPES.each do |op_type|
      context op_type do
        let(:data) { {} }
        let(:signers) { %i[alex] }
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

          it 'returns second page of operations' do
            expect(response).to have_http_status(200)
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

    Operations::Account::MEMBER_TYPES.each do |op_type|
      context op_type do
        let(:data) { {} }
        let(:signers) { %i[alex] }
        let(:operations_number) { 15 }
        let!(:operations) { create_list(op_type, operations_number, :with_member) }

        before do
          request(op_type.to_s.pluralize)
        end

        it { expect(response).to have_http_status(200) }

        context 'filter by currency' do
          let(:data) { { currency: :btc } }

          it 'returns operations by currency' do
            expect(response).to have_http_status(200)
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

          it 'returns operations by member UID' do
            expect(response).to have_http_status(200)
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

        context 'filter by reference type' do
          let(:deposit_data) { { reference_type: 'deposit' } }
          let(:trade_data) { { reference_type: 'trade' } }
          let(:order_data) { { reference_type: 'order' } }

          it { expect(response).to have_http_status(200) }

          def equal_amount!(response, optional_field, op_type)
            operations = "operations/#{op_type}"
                           .camelize
                           .constantize
                           .where(optional_field)
            expect(JSON.parse(response.body).count).to eq operations.count
          end

          it 'returns operations by reference type deposit' do
            optional_request(op_type.to_s.pluralize, deposit_data)
            equal_amount!(response, deposit_data, op_type)
          end

          it 'returns operations by reference type trade' do
            optional_request(op_type.to_s.pluralize, trade_data)
            equal_amount!(response, trade_data, op_type)
          end

          it 'returns operations by reference type order' do
            optional_request(op_type.to_s.pluralize, order_data)
            equal_amount!(response, order_data, op_type)
          end
        end

        context 'time range' do
          let(:time_from) { 2.days.ago }
          let(:time_to) { 1.day.ago }

          let(:data) { { time_from: time_from.to_i, time_to: time_to.to_i } }

          it { expect(response).to have_http_status(200) }

          it 'returns operations between 48h and 24h ago' do
            request(op_type.to_s.pluralize)
            operations = "operations/#{op_type}"
                           .camelize
                           .constantize
                           .where('created_at >= ?', time_from)
                           .where('created_at < ?', time_to)
            expect(JSON.parse(response.body).count).to eq operations.count
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

  describe 'create operation' do
    def request(op_type)
      post_json "/api/v2/management/#{op_type}/new", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    Operations::Account::PLATFORM_TYPES.each do |op_type|
      context op_type do
        let(:currency) { Currency.coins.sample }
        let(:signers) { %i[alex jeff] }
        let(:data) do
          { currency: currency.code,
            code:     Operations::Account.find_by(type: op_type, currency_type: currency.type).code}
        end

        context 'credit' do
          let(:amount) { '0.2515' }
          before do
            data[:credit] = amount
            request(op_type.to_s.pluralize)
          end

          it 'returns operation' do
            expect(response).to have_http_status 200
            expect(JSON.parse(response.body)['currency']).to eq currency.code.to_s
            expect(JSON.parse(response.body)['credit'].to_d).to eq amount.to_d
            expect(JSON.parse(response.body)['code']).to \
              eq Operations::Account.find_by(type: op_type,
                                            kind: :main,
                                            currency_type: currency.type).code
          end

          it 'saves operation' do
            op_klass = "operations/#{op_type}"
                         .camelize
                         .constantize
            expect { request(op_type.to_s.pluralize) }.to \
              change(op_klass, :count).by(1)
          end

          context 'wrong account code' do
            before do
              data[:code] = (::Operations::Account.pluck(:code) - [data[:code]]).sample
              request(op_type.to_s.pluralize)
            end

            it { expect(response).to have_http_status 422 }
          end
        end

        context 'debit' do
          let(:amount) { '0.1545' }
          before do
            # Create credit operation to avoid negative balance.
            create(op_type, credit: amount)
            data[:debit] = amount
            request(op_type.to_s.pluralize)
          end

          it 'returns operation' do
            expect(response).to have_http_status 200
            expect(JSON.parse(response.body)['currency']).to eq currency.code.to_s
            expect(JSON.parse(response.body)['debit'].to_d).to eq amount.to_d
            expect(JSON.parse(response.body)['code']).to \
              eq Operations::Account.find_by(type: op_type,
                                            kind: :main,
                                            currency_type: currency.type).code
          end

          it 'saves operation' do
            op_klass = "operations/#{op_type}"
                         .camelize
                         .constantize
            expect { request(op_type.to_s.pluralize) }.to \
              change(op_klass, :count).by(1)
          end
        end
      end
    end

    Operations::Account::MEMBER_TYPES.each do |op_type|
      context op_type do
        let(:currency) { Currency.coins.sample }
        let(:signers) { %i[alex jeff] }
        let(:member) { create(:member, :barong) }
        let(:data) do
          { currency: currency.code,
            code:     Operations::Account.find_by(type: op_type, currency_type: currency.type, kind: :main).code,
            uid:      member.uid }
        end

        context 'credit' do
          let(:amount) { '0.2515' }
          before do
            data[:credit] = amount
            request(op_type.to_s.pluralize)
          end

          it 'returns operation' do
            expect(response).to have_http_status 200
            expect(JSON.parse(response.body)['uid']).to eq member.uid
            expect(JSON.parse(response.body)['currency']).to eq currency.code.to_s
            expect(JSON.parse(response.body)['credit'].to_d).to eq amount.to_d
            expect(JSON.parse(response.body)['code']).to \
              eq Operations::Account.find_by(type: op_type,
                                            kind: :main,
                                            currency_type: currency.type).code
          end

          it 'saves operation' do
            op_klass = "operations/#{op_type}"
                         .camelize
                         .constantize
            expect { request(op_type.to_s.pluralize) }.to \
              change(op_klass, :count).by(1)
          end

          it 'updates legacy balance' do
            currency_id = JSON.parse(response.body)['currency']
            expect(member.get_account(currency_id).balance).to \
              eq JSON.parse(response.body)['credit'].to_d
          end

          context 'wrong account code' do
            before do
              data[:code] = 999
              request(op_type.to_s.pluralize)
            end

            it { expect(response).to have_http_status 422 }
          end
        end

        context 'debit' do
          let(:amount) { '0.1545' }
          before do
            # Create credit operation to avoid negative balance.
            create(op_type, :with_member, credit: amount,
                   member: member, currency: currency)
            data[:debit] = amount
            request(op_type.to_s.pluralize)
          end

          it 'returns operation' do
            expect(response).to have_http_status 200
            expect(JSON.parse(response.body)['uid']).to eq member.uid
            expect(JSON.parse(response.body)['currency']).to eq currency.code.to_s
            expect(JSON.parse(response.body)['debit'].to_d).to eq amount.to_d
            expect(JSON.parse(response.body)['code']).to \
              eq Operations::Account.find_by(type: op_type,
                                            kind: :main,
                                            currency_type: currency.type).code
          end

          it 'saves operation' do
            # Create one more credit operation to avoid negative balance.
            # So we can create one more debit operation.
            create(op_type, :with_member, credit: amount, member: member, currency: currency)
            op_klass = "operations/#{op_type}"
                         .camelize
                         .constantize
            expect { request(op_type.to_s.pluralize) }.to \
              change(op_klass, :count).by(1)
          end

          it 'updates legacy balance' do
            currency_id = JSON.parse(response.body)['currency']
            expect(member.get_account(currency_id).balance).to \
              eq 0.to_d
          end
        end
      end
    end
  end
end
