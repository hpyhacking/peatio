# frozen_string_literal: true

describe API::V2::Public::Webhooks, type: :request do
  describe 'GET /webhooks/:adapter/:event' do
    let(:member) { create(:member) }

    context 'deposit' do
      context 'deposit wallet doesnt exist' do
        it do
          expect {
            api_post '/api/v2/public/webhooks/opendax_cloud/deposit'
          }.not_to change { Deposit.count }

          expect(Wallet.active_retired.where(kind: :deposit, gateway: 'opendax_cloud').count).to eq 0
        end
      end

      context 'deposit wallet exist' do
        let!(:deposit_wallet) { create(:wallet, :eth_opendax_cloud_deposit) }

        context 'transactions doesnt exist' do
          before do
            WalletService.any_instance.stubs(:trigger_webhook_event).returns([])
          end

          it do
            expect {
              api_post '/api/v2/public/webhooks/opendax_cloud/deposit'
            }.not_to change { Deposit.count }
          end
        end

        context 'there is no JWT' do
          it do
            api_post '/api/v2/public/webhooks/opendax_cloud/deposit'

            expect(response.status).to eq 422
            expect(response).to include_api_error('public.webhook.cannot_perfom_opendax_cloud_deposit')
          end
        end

        context 'transactions exist' do
          let(:transaction) do
            Peatio::Transaction.new(
              currency_id: :eth,
              hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
              amount: 0.5,
              to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
              block_number: 16880960,
              txout: 0,
              status: :success
            )
          end

          context 'accepted deposits exist' do
            before do
              WalletService.any_instance.stubs(:trigger_webhook_event).returns([transaction])
            end

            context 'there is no payment address' do
              it do
                expect {
                  api_post '/api/v2/public/webhooks/opendax_cloud/deposit'
                }.not_to change { Deposit.count }
              end
            end

            context 'there is payment address' do
              before do
                # disable first deposit wallet for eth to have ability to use opendax cloud deposit wallet
                Wallet.deposit_wallets(transaction.currency_id)[0].update(status: 'disabled') if Wallet.deposit_wallets(transaction.currency_id)[0].gateway == 'geth'
                PaymentAddress.create(member: member, wallet: deposit_wallet, address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84')
              end

              it do
                expect {
                  api_post '/api/v2/public/webhooks/opendax_cloud/deposit'
                }.to change { Deposit.count }.by(1)
              end
            end
          end

          context 'with options' do
            context 'tid options' do
              let(:transaction) do
                Peatio::Transaction.new(
                  currency_id: :eth,
                  hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
                  amount: 0.5,
                  to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
                  block_number: 16880960,
                  txout: 0,
                  status: :success,
                  options: {
                    tid: 'TID9493F6CD41',
                  }
                )
              end

              before do
                # disable first deposit wallet for eth to have ability to use opendax cloud deposit wallet
                Wallet.deposit_wallets(transaction.currency_id)[0].update(status: 'disabled') if Wallet.deposit_wallets(transaction.currency_id)[0].gateway == 'geth'
                PaymentAddress.create(member: member, wallet: deposit_wallet, address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84')
                WalletService.any_instance.stubs(:trigger_webhook_event).returns([transaction])
              end

              let!(:deposit) { create(:deposit, :deposit_eth, tid: 'TID9493F6CD41', txid: nil)}

              it do
                expect {
                  api_post '/api/v2/public/webhooks/opendax_cloud/deposit'
                }.not_to change { Deposit.count }
                deposit.reload
                expect(deposit.tid).to eq 'TID9493F6CD41'
                expect(deposit.txid).to eq '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac'
              end
            end
          end
        end
      end
    end

    context 'withdraw' do
      context 'hot wallet doesnt exist' do
        it do
          expect {
            api_post '/api/v2/public/webhooks/opendax_cloud/withdraw'
          }.not_to change { Withdraw.count }

          expect(Wallet.active_retired.where(kind: :hot, gateway: 'opendax_cloud').count).to eq 0
        end
      end

      context 'hot wallet exist' do
        let!(:hot_wallet) { create(:wallet, :eth_opendax_cloud_hot) }

        context 'transactions doesnt exist' do
          before do
            WalletService.any_instance.stubs(:trigger_webhook_event).returns([])
          end

          it do
            api_post '/api/v2/public/webhooks/opendax_cloud/withdraw'
            expect(response.status).to eq 200
          end
        end

        context 'transactions exist' do
          context 'without options' do
            let(:transaction) do
              Peatio::Transaction.new(
                currency_id: :eth,
                hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
                amount: 0.5,
                to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
                block_number: 16880960,
                txout: 0,
                status: :success
              )
            end

            let(:params) do
              {
                adapter: 'opendax_cloud',
                event: 'withdraw'
              }
            end


            before do
              member.touch_accounts
              member.accounts.map { |a| a.update(balance: 500) }
              WalletService.any_instance.stubs(:trigger_webhook_event).returns([transaction])
            end

            let!(:withdraw) { create(:eth_withdraw, :with_beneficiary, aasm_state: :prepared, member: member, txid: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac')}

            before do
              withdraw.accept!
              withdraw.process!
              withdraw.dispatch!
            end

            it do
              api_post '/api/v2/public/webhooks/opendax_cloud/withdraw'
              expect(response.status).to eq 200

              withdraw.reload
              expect(withdraw.aasm_state).to eq 'succeed'
            end

            context 'failed transaction' do
              let(:transaction) do
                Peatio::Transaction.new(
                  currency_id: :eth,
                  hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
                  amount: 0.5,
                  to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
                  block_number: 16880960,
                  txout: 0,
                  status: :failed
                )
              end

              it do
                api_post '/api/v2/public/webhooks/opendax_cloud/withdraw'
                expect(response.status).to eq 200

                withdraw.reload
                expect(withdraw.aasm_state).to eq 'failed'
              end
            end
          end
        end
      end
    end

    context 'deposit address' do
      context 'deposit wallet doesnt exist' do
        it do
          api_post '/api/v2/public/webhooks/opendax_cloud/deposit_address'
          expect(response.status).to eq 200

          expect(Wallet.active_retired.where(kind: :deposit, gateway: 'opendax_cloud').count).to eq 0
        end
      end

      context 'deposit wallet exists' do
        let!(:deposit_wallet) { create(:wallet, :eth_opendax_cloud_deposit) }

        context 'event doesnt exist' do
          before do
            WalletService.any_instance.stubs(:trigger_webhook_event).returns([])
          end

          it do
            api_post '/api/v2/public/webhooks/opendax_cloud/deposit_address'
            expect(response.status).to eq 200
          end
        end

        context 'event exists' do
          let(:event) do
            {
              address: 'Address',
              currency_id: 'eth',
              address_id: 12,
            }
          end

          before do
            # disable first deposit wallet for eth to have ability to use opendax cloud deposit wallet
            Wallet.deposit_wallets('eth')[0].update(status: 'disabled') if Wallet.deposit_wallets('eth')[0].gateway == 'geth'
            WalletService.any_instance.stubs(:trigger_webhook_event).returns(event)
          end

          let!(:payment_address) { PaymentAddress.create(member: member, wallet: deposit_wallet, address: nil, details: { address_id: 12}) }

          it do
            api_post '/api/v2/public/webhooks/opendax_cloud/deposit_address'
            expect(response.status).to eq 200
            payment_address.reload
            expect(payment_address.address).to eq event[:address].downcase
          end
        end
      end
    end

    context 'generic' do
      context 'deposit wallet doesnt exist' do
        it do
          expect {
            api_post '/api/v2/public/webhooks/opendax_cloud/generic'
          }.not_to change { Deposit.count }

          expect(Wallet.where(status: :active, kind: :deposit, gateway: 'opendax_cloud').count).to eq 0
        end
      end

      context 'deposit wallet exist' do
        let!(:deposit_wallet) { create(:wallet, :eth_opendax_cloud_deposit) }

        context 'process deposits' do
          context 'transactions doesnt exist' do
            before do
              WalletService.any_instance.stubs(:trigger_webhook_event).returns([])
            end

            it do
              expect {
                api_post '/api/v2/public/webhooks/opendax_cloud/generic'
              }.not_to change { Deposit.count }
            end
          end

          context 'transactions exist' do
            let(:transaction) do
              Peatio::Transaction.new(
                currency_id: :eth,
                hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
                amount: 0.5,
                to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
                block_number: 16880960,
                txout: 0,
                status: :success
              )
            end

            context 'accepted deposits exist' do
              before do
                WalletService.any_instance.stubs(:trigger_webhook_event).returns([transaction])
              end

              context 'there is no payment address' do
                it do
                  expect {
                    api_post '/api/v2/public/webhooks/opendax_cloud/generic'
                  }.not_to change { Deposit.count }
                end
              end

              context 'there is payment address' do
                before do
                  # disable first deposit wallet for eth to have ability to use opendax cloud deposit wallet
                  Wallet.deposit_wallets(transaction.currency_id)[0].update(status: 'disabled') if Wallet.deposit_wallets(transaction.currency_id)[0].gateway == 'geth'
                  PaymentAddress.create(member: member, wallet: deposit_wallet, address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84')
                end

                it do
                  expect {
                    api_post '/api/v2/public/webhooks/opendax_cloud/generic'
                  }.to change { Deposit.count }.by(1)
                end
              end
            end

            context 'with options' do
              context 'remote_id options' do
                let(:transaction) do
                  Peatio::Transaction.new(
                    currency_id: :eth,
                    hash: nil,
                    amount: 0.5,
                    to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
                    block_number: 16880960,
                    txout: 0,
                    status: :pending,
                    options: {
                      remote_id: 'TID9493F6CD41',
                    }
                  )
                end

                before do
                  # disable first deposit wallet for eth to have ability to use opendax cloud deposit wallet
                  Wallet.deposit_wallets(transaction.currency_id)[0].update(status: 'disabled') if Wallet.deposit_wallets(transaction.currency_id)[0].gateway == 'geth'
                  PaymentAddress.create(member: member, wallet: deposit_wallet, address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84')
                  WalletService.any_instance.stubs(:trigger_webhook_event).returns([transaction])
                end

                it do
                  expect {
                    api_post '/api/v2/public/webhooks/opendax_cloud/generic'
                  }.not_to change { Deposit.count }
                end
              end
            end
          end
        end

        context 'process withdraws' do
          context 'transaction exists' do
            let(:transaction) do
              Peatio::Transaction.new(
                currency_id: :eth,
                hash: '0xa049b0202ba078caa723c6b59594247b0c9f33e24878950f8537cedff9ea20ac',
                amount: 0.5,
                to_address: '0x1ef338196bd0207ba4852ba7a6847eed59331b84',
                block_number: 16880960,
                txout: 0,
                status: :success,
                options: {
                  remote_id: 'd123123-123123-12313'
                }
              )
            end

            let(:params) do
              {
                adapter: 'opendax_cloud',
                event: 'generic'
              }
            end


            before do
              member.touch_accounts
              member.accounts.map { |a| a.update(balance: 500) }
              WalletService.any_instance.stubs(:trigger_webhook_event).returns([transaction])
            end

            let!(:withdraw) { create(:eth_withdraw, :with_beneficiary, aasm_state: :prepared, member: member, remote_id: 'd123123-123123-12313')}

            before do
              withdraw.accept!
              withdraw.process!
              withdraw.review!
            end

            it do
              api_post '/api/v2/public/webhooks/opendax_cloud/generic'
              expect(response.status).to eq 200

              withdraw.reload
              expect(withdraw.aasm_state).to eq 'succeed'
            end
          end
        end
      end
    end
  end
end
