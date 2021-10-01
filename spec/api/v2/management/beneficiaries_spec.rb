# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Beneficiaries, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_beneficiaries: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_beneficiaries: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  describe 'beneficiary list' do
    def request
      post_json '/api/v2/management/beneficiaries/list', multisig_jwt_management_api_v1({ data: beneficiary_data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:member) { create(:member, :level_3) }
    let(:beneficiary_data) do
      {
        uid: member.uid,
      }
    end

    let!(:pending_beneficiaries_for_member) do
      create_list(:beneficiary, 2, member: member, state: :pending)
    end

    let!(:active_beneficiaries_for_member) do
      create_list(:beneficiary, 3, member: member, state: :active)
    end

    let!(:archived_beneficiaries_for_member) do
      create_list(:beneficiary, 2, member: member, state: :archived)
    end

    let!(:other_member_beneficiaries) do
      create_list(:beneficiary, 5)
    end

    context 'missing required params' do
      it do
        beneficiary_data.except!(:uid)
        request
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['error']).to match(/uid is missing/i)
      end
    end

    context 'without currency and state' do
      it do
        request
        expect(response.status).to eq 200
        total_for_member = pending_beneficiaries_for_member.count + active_beneficiaries_for_member.count
        expect(response_body.size).to eq total_for_member
      end
    end

    context 'non-existing currency' do
      it do
        beneficiary_data.merge!(currency: :uah)
        request
        expect(response.status).to eq 422
        expect(response.body).to match(/management.currency.doesnt_exist/i)
      end
    end

    context 'existing currency' do
      let!(:btc_beneficiaries_for_member) do
        create_list(:beneficiary, 3, member: member)
      end

      it do
        beneficiary_data.merge!(currency: :btc)
        request
        expect(response.status).to eq 200
        expect(response_body.all? { |b| b['currency'] == 'btc' }).to be_truthy
      end

      context 'fiat currency' do
        let!(:usd_beneficiary_for_member) { create(:beneficiary, currency: Currency.find('usd'), member: member) }

        it do
          beneficiary_data.merge!(currency: :usd)
          request
          expect(response.status).to eq 200
          expect(response_body.all? { |b| b['currency'] == 'usd' }).to be_truthy
          expect(usd_beneficiary_for_member.id).to eq response_body.first['id']
          expect(usd_beneficiary_for_member.data[:account_number]).to eq response_body.first['data']['account_number']
        end
      end
    end

    context 'invalid state' do
      it do
        beneficiary_data.merge!(state: :invalid)
        request
        expect(response.status).to eq 422
        expect(response.body).to match(/management.beneficiary.invalid_state/i)
      end
    end

    context 'existing state' do
      it do
        beneficiary_data.merge!(state: :pending)
        request
        expect(response.status).to eq 200
        expect(response_body.all? { |b| b['state'] == 'pending' }).to be_truthy
      end
    end

    context 'blockchain_key' do
      it do
        beneficiary_data.merge!(blockchain_key: 'eth-rinkeby')
        request
        expect(response.status).to eq 200
        expect(response_body.all? { |b| b['blockchain_key'] == 'eth-rinkeby' }).to be_truthy
      end
    end

    context 'both currency and state' do
      let!(:active_btc_beneficiaries_for_member) do
        create_list(:beneficiary, 3, member: member, state: :active)
      end

      it do
        beneficiary_data.merge!(currency: :btc, state: :active)
        request
        expect(response.status).to eq 200
        expect(response_body.all? { |b| b['currency'] == 'btc' && b['state'] == 'active' }).to be_truthy
      end
    end
  end

  describe 'create beneficiary' do
    def request
      post_json '/api/v2/management/beneficiaries', multisig_jwt_management_api_v1({ data: beneficiary_data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:member) { create(:member, :level_3) }
    let(:beneficiary_data) do
      {
        currency: :btc,
        name: 'Personal Bitcoin wallet',
        description: 'Multisignature Bitcoin Wallet',
        blockchain_key: 'btc-testnet',
        uid: member.uid,
        state: 'active',
        data: {
          address: Faker::Blockchain::Bitcoin.address
        }
      }
    end

    context 'invalid params' do
      context 'missing required params' do
        %i[currency name data uid].each do |rp|
          context rp do
            it do
              beneficiary_data.except!(rp)
              request
              expect(response.status).to eq 422
              expect(JSON.parse(response.body)['error']).to match(/#{rp} is missing/i)
            end
          end
        end
      end

      context 'unknown network' do
        let(:currency) { Currency.find_by(id: 'btc') }
        before do
          currency.update(default_network_id: nil)
        end

        it do
          beneficiary_data.merge!(blockchain_key: 'eth-kovan')
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.beneficiary.network_not_found/i)
        end
      end

      context 'currency doesn\'t exist' do
        it do
          beneficiary_data.merge!(currency: :uah)
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.currency.doesnt_exist/i)
        end
      end

      context 'name is too long' do
        it do
          beneficiary_data.merge!(name: Faker::Lorem.sentence(500))
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.beneficiary.too_long_name/i)
        end
      end

      context 'invalid state' do
        it do
          beneficiary_data.merge!(state: 'test')
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.beneficiary.invalid_state/i)
        end
      end

      context 'description is too long' do
        it do
          beneficiary_data.merge!(description: Faker::Lorem.sentence(500))
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.beneficiary.too_long_description/i)
        end
      end

      context 'data has invalid type' do
        it do
          beneficiary_data.merge!(data: 'data')
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.beneficiary.non_json_data/i)
        end
      end

      context 'data has invalid type' do
        it do
          beneficiary_data.merge!(blockchain_key: 'invalid')
          request
          expect(response.status).to eq 422
          expect(response.body).to match(/management.beneficiary.blockchain_key_doesnt_exist/i)
        end
      end

      context 'crypto beneficiary' do
        context 'nil address in data' do
          it do
            beneficiary_data[:data][:address] = nil
            request
            expect(response.status).to eq 422
            expect(response.body).to match(/management.beneficiary.missing_address_in_data/i)
          end
        end

        context 'data without address' do
          it do
            beneficiary_data[:data].delete(:address)
            beneficiary_data[:data][:memo] = :memo

            request
            expect(response.status).to eq 422
            expect(response.body).to match(/management.beneficiary.missing_address_in_data/i)
          end
        end

        context 'disabled withdrawal for currency' do
          let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: 'btc') }
          before do
            blockchain_currency.update(withdrawal_enabled: false)
          end
          it do
            request
            expect(response.status).to eq 422
            expect(response.body).to match(/management.currency.withdrawal_disabled/i)
          end
        end

        context 'invalid character in address' do
          before do
            beneficiary_data[:data][:address] = "'" + Faker::Blockchain::Bitcoin.address
          end
          it do
            request
            expect(response.status).to eq 422
            expect(response.body).to match(/management.beneficiary.failed_to_create/i)
          end
        end

        context 'duplicated address' do
          context 'same currency' do
            before do
              create(:beneficiary,
                     member: member,
                     blockchain_key: beneficiary_data[:blockchain_key],
                     currency_id: beneficiary_data[:currency],
                     data: {address: beneficiary_data.dig(:data, :address)})
            end

            it do
              request
              expect(response.status).to eq 422
              expect(response.body).to match(/management.beneficiary.duplicate_address/i)
            end
          end

          context 'different currencies' do
            before do
              create(:beneficiary,
                     member: member,
                     blockchain_key: 'eth-rinkeby',
                     currency_id: :eth,
                     data: {address: beneficiary_data.dig(:data, :address)})
            end

            it do
              request
              expect(response.status).to eq 201
            end
          end

          context 'truncates spaces in address' do
            let(:address) { Faker::Blockchain::Bitcoin.address }

            before do
              beneficiary_data[:data][:address] = " " + address + " "
            end
            it do
              request
              expect(response.status).to eq 201

              result = JSON.parse(response.body)
              expect(Beneficiary.find(result['id']).data['address']).to eq(address)
            end
          end
        end

        context 'destination tag in address' do
          before do
            beneficiary_data[:data][:address] = Faker::Blockchain::Bitcoin.address + "?dt=4"
          end
          it do
            request
            expect(response.status).to eq 201

            result = JSON.parse(response.body)

            expect(result['blockchain_key']).to eq beneficiary_data[:blockchain_key]
            expect(Beneficiary.find(result['id']).data['address']).to eq(beneficiary_data[:data][:address])
          end
        end

        context 'fiat beneficiary' do
          let(:beneficiary_data) do
            {
              currency: :usd,
              uid: member.uid,
              name: Faker::Bank.name,
              blockchain_key: 'fiat',
              description: Faker::Company.catch_phrase,
              data: generate(:fiat_beneficiary_data)
            }
          end

          context 'nil address in data' do
            it do
              beneficiary_data[:data].except!(:address)
              request
              expect(response.status).to eq 201
              expect(response_body['blockchain_key']).to eq 'fiat'
              expect(response_body['data']).to eq beneficiary_data[:data].with_indifferent_access
            end
          end

          context 'nil data' do
            it do
              beneficiary_data[:data] = nil
              request
              expect(response.status).to eq 422
              expect(JSON.parse(response.body)['error']).to match(/data is empty/i)
            end
          end

          context 'duplicated address' do
            context 'same currency' do
              before do
                create(:beneficiary,
                       member: member,
                       blockchain_key: 'fiat',
                       currency_id: beneficiary_data[:currency],
                       data: beneficiary_data[:data])
              end

              it do
                request
                expect(response.status).to eq 201
              end
            end
          end
        end
      end
    end

    context 'valid params' do
      it 'creates beneficiary for member' do
        expect do
          request
        end.to change{ member.beneficiaries.count }.by(1)
      end

      it 'creates beneficiary with active state' do
        request
        expect(response.status).to eq 201
        id = response_body['id']
        expect(Beneficiary.find_by!(id: id).state).to eq 'active'
        expect(Beneficiary.find_by!(id: id).data).to eq response_body['data']
      end
    end
  end
end
