# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Transfers, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
      read_transfers:  { permitted_signers: %i[alex jeff],       mandatory_signers: %i[alex] },
      write_transfers: { permitted_signers: %i[alex jeff james], mandatory_signers: %i[alex jeff] }
    }
  end

  describe 'create operation' do
    def request
      post_json '/api/v2/management/transfers/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:currency) { Currency.coins.sample }
    let(:signers) { %i[alex jeff] }
    let(:data) do
      { key:  generate(:transfer_key),
        category: Transfer::CATEGORIES.sample,
        description: "Referral program payoffs (#{Time.now.to_date})",
        operations: operations }
    end

    let(:valid_operation) do
      { currency: :btc,
        amount: '0.0001',
        account_src: {
          code: 102
        },
        account_dst: {
          code: 102
        } }
    end

    context 'automatically creates an account, if transfer will be send' do
      let!(:sender_member) { create(:member, :level_3) }
      let!(:receiver_member) { create(:member, :level_3) }
      let!(:deposit) { create(:deposit_btc, member: sender_member, amount: 1) }

      let(:operation) do
        {
          currency: :btc,
          amount: '0.5',
          account_src: {
            code: 202,
            uid: sender_member.uid
          },
          account_dst: {
            code: 202,
            uid: receiver_member.uid
          }
        }
      end

      let(:operations) { [operation] }

      before do
        deposit.accept!
        deposit.process!
        deposit.dispatch!
      end

      it do
        expect(receiver_member.accounts.count).to eq(0)

        request
        expect(response).to have_http_status(201)
        expect(receiver_member.accounts.count).to eq(1)
      end
    end

    context 'empty key' do
      let(:operations) { [valid_operation] }

      before do
        data.delete(:key)
        request
      end

      it do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/key is missing/i)
      end
    end

    context 'empty category' do
      let(:operations) {[valid_operation]}

      before do
        data.delete(:category)
        request
      end

      it do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/category is missing/i)
      end
    end

    context 'empty description' do
      let(:operations) {[valid_operation]}

      before do
        data.delete(:description)
        request
      end

      it { expect(response).to have_http_status(201) }
    end

    context 'empty operations' do
      let(:operations) {[]}

      before { request }

      it do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/operations is empty/i)
      end
    end

    context 'invalid account code' do
      let(:operations) do
        valid_operation[:account_src][:code] = 999
        [valid_operation]
      end
      before { request }

      it do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/does not have a valid value/i)
      end
    end

    context 'invalid currency' do
      let(:operations) do
        valid_operation[:currency] = :neo
        [valid_operation]
      end
      before { request }

      it do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/does not have a valid value/i)
      end
    end

    context 'invalid amount' do
      let(:operations) do
        valid_operation[:amount] = -1
        [valid_operation]
      end
      before { request }

      it do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/does not have a valid value/i)
      end
    end

    context 'existing transfer key' do
      let(:operations) {[valid_operation]}
      before do
        t = create(:transfer)
        data[:key] = t.key
        request
      end

      it do
        expect(response).to have_http_status 422
        expect(response.body).to match(/key has already been taken/i)
      end
    end

    context 'debit liability on account with insufficient balance' do
      let!(:sender_member) { create(:member, :level_3) }
      let!(:receiver_member) { create(:member, :level_3) }

      let!(:deposit) { create(:deposit_btc, member: sender_member, amount: 1) }
      let(:operation) do
        {
          currency: :btc,
          amount:   '1.1',
          account_src: {
            code: 202,
            uid:  sender_member.uid
          },
          account_dst: {
            code: 202,
            uid:  receiver_member.uid
          }
        }
      end
      let(:operations) {[operation]}

      before { request }

      it do
        expect(response).to have_http_status 422
        expect(response.body).to match(/account balance is insufficient/i)
      end
    end

    context 'referral program story' do
      # In case of referral program some fees received by platform
      # during trading are returned to the referrer once per 4h for example.
      # We debit Revenue account balance and credit member Liabilities.

      before do
        # Credit Revenue accounts.
        create(:revenue, currency_id: base_unit,
               code: coin_revenues_code, credit: 10)
        create(:revenue, currency_id: quote_unit,
               code: fiat_revenues_code, credit: 100)
      end

      let(:referrer1) { create(:member, :barong) }
      let(:referrer2) { create(:member, :barong) }
      let(:referrer3) { create(:member, :barong) }

      let(:base_unit) { Currency.coins.ids.sample }
      let(:quote_unit) { Currency.fiats.ids.sample }

      let(:coin_liabilities_code) { 202 }
      let(:fiat_liabilities_code) { 201 }

      let(:coin_revenues_code) { 302 }
      let(:fiat_revenues_code) { 301 }

      # Consider we have BTC/USD market
      # Return all BTC/USD fees for 4h in single batch.
      # Balance changes:
      # Liability:
      #   referrer1:
      #     base_unit:  0.0001 + 0.0003
      #     quote_unit: 0
      #   referrer2:
      #     base_unit:  0.00015
      #     quote_unit: 0.05
      #   referrer3:
      #     base_unit:  0
      #     quote_unit: 0.075
      # Revenue:
      #   base_unit: -(0.0001 + 0.0003 + 0.00015)
      #   quote_unit -(0.05 + 0.075)
      let(:operations) do
        [
          {
            currency: base_unit,
            amount:   '0.0001',
            account_src: {
              code: coin_revenues_code
            },
            account_dst: {
              code: coin_liabilities_code,
              uid: referrer1.uid
            }
          },
          {
            currency: base_unit,
            amount:   '0.00015',
            account_src: {
              code: coin_revenues_code
            },
            account_dst: {
              code: coin_liabilities_code,
              uid: referrer2.uid
            }
          },
          {
            currency: base_unit,
            amount:   '0.0003',
            account_src: {
              code: coin_revenues_code
            },
            account_dst: {
              code: coin_liabilities_code,
              uid: referrer1.uid
            }
          },
          {
            currency: quote_unit,
            amount:   '0.075',
            account_src: {
              code: fiat_revenues_code
            },
            account_dst: {
              code: fiat_liabilities_code,
              uid: referrer3.uid
            }
          },
          {
            currency: quote_unit,
            amount:   '0.05',
            account_src: {
              code: fiat_revenues_code
            },
            account_dst: {
              code: fiat_liabilities_code,
              uid: referrer2.uid
            }
          }
        ]
      end

      it do
        request
        expect(response).to have_http_status 201
      end

      it 'returns transfer with operations' do
        request
        expect(JSON.parse(response.body)['key']).to eq data[:key]
        expect(JSON.parse(response.body)['category']).to eq data[:category]
        expect(JSON.parse(response.body)['description']).to eq data[:description]
        expect(JSON.parse(response.body)['liabilities'].size).to eq operations.size
        expect(JSON.parse(response.body)['revenues'].size).to eq operations.size
      end

      it 'saves liabilities' do
        expect { request }.to change(::Operations::Liability, :count).by(operations.size)
      end

      it 'saves revenues' do
        expect { request }.to change(::Operations::Revenue, :count).by(operations.size)
      end

      it 'updates legacy balances' do
        expect { request }.to change{ referrer1.get_account(base_unit).balance }.by(0.0001 + 0.0003).and \
                              change{ referrer2.get_account(base_unit).balance }.by(0.00015).and \
                              change{ referrer2.get_account(quote_unit).balance }.by(0.05).and \
                              change{ referrer3.get_account(quote_unit).balance }.by(0.075)
      end

      context 'wrong account code' do
        let(:operations) do
          [
            {
              currency: base_unit,
              amount:   '0.0001',
              account_src: {
                code: fiat_revenues_code  # Wrong code because base_unit is coin.
              },
              account_dst: {
                code: coin_liabilities_code,
                uid: referrer2.uid
              }
            },
            {
              currency: quote_unit,
              amount:  '0.05',
              account_src: {
                code: fiat_revenues_code
              },
              account_dst: {
                code: coin_liabilities_code, # Wrong code because quote_unit is fiat.
                uid: referrer2.uid
              }
            }
          ]
        end

        it do
          request
          expect(response).to have_http_status 422
        end

        it 'doesn\'t save transfer' do
          expect { request }.to_not change(Transfer, :count)
        end

        it 'doesn\'t save liabilities' do
          expect { request }.to_not change(::Operations::Liability, :count)
        end

        it 'doesn\'t save revenues' do
          expect { request }.to_not change(::Operations::Revenue, :count)
        end
      end
    end

    context 'token distribution story' do
      # In token distribution story we credit member token balance
      # once member is signed in for the first time.
      before do
        # Add token-distribution Liabilities account.
        Rails.configuration.x.chart_of_accounts << coin_distribution_account
        create(:operations_account, coin_distribution_account)
      end

      before do
        #   1. Credit main Assets account.
        #   2. Credit token-distribution Liabilities account.
        # So we keep Balance Sheet equal Income Statement.
        create(:asset, currency_id: coin,
               code: coin_assets_code, credit: 1000)
        create(:liability, currency_id: coin,
               code: coin_distribution_account_code, credit: 1000, member_id: nil)
      end

      let(:member1) { create(:member, :barong) }
      let(:member2) { create(:member, :barong) }

      let(:coin) { :trst }

      let(:coin_assets_code) { 102 }

      let(:coin_liabilities_code) { 202 }
      let(:coin_distribution_account_code) do
        coin_distribution_account[:code]
      end
      let(:coin_distribution_account) do
        { code:           292,
          type:           :liability,
          kind:           'token-distribution',
          currency_type:  :coin,
          description:    'Token Distributions Liabilities Account',
          scope:          :platform
        }
      end

      # Balance changes:
      # Liability-main:
      #   member1:
      #     coin:  10
      #   member2:
      #     coin:  5
      # Liability-token-distribution:
      #   coin: -15
      let(:operations) do
        [
          {
            currency: coin,
            amount:   10,
            account_src: {
              code: coin_distribution_account_code
            },
            account_dst: {
              code: coin_liabilities_code,
              uid: member1.uid
            }
          },
          {
            currency: coin,
            amount:   5,
            account_src: {
              code: coin_distribution_account_code
            },
            account_dst: {
              code: coin_liabilities_code,
              uid: member2.uid
            }
          }
        ]
      end

      it do
        request
        expect(response).to have_http_status 201
      end

      it 'returns transfer with liabilities' do
        request
        expect(JSON.parse(response.body)['key']).to eq data[:key]
        expect(JSON.parse(response.body)['category']).to eq data[:category]
        expect(JSON.parse(response.body)['description']).to eq data[:description]
        # Two liability operation for each token-distribution operation.
        expect(JSON.parse(response.body)['liabilities'].size).to eq operations.size * 2
      end

      it 'saves liabilities' do
        expect { request }.to change(::Operations::Liability, :count).by(operations.size * 2)
      end

      it 'updates legacy balance' do
        expect { request }.to change{ member1.get_account(coin).balance }.by(10).and \
                              change{ member2.get_account(coin).balance }.by(5)
      end
    end
  end
end
