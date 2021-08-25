# frozen_string_literal: true

describe Jobs::Cron::WithdrawWatcher do
  class AbstractWallet < Peatio::Wallet::Abstract
    def initialize(_opts = {}); end
    def configure(settings = {}); end

    def supported_wallet_kinds
      ['hot']
    end

    def fetch_blockchain_transaction_id(_remote_id)
      '0x1762873161782YD121ui'
    end

    def fetch_withdraw_status(_remote_id)
      'success'
    end
  end

  subject { Jobs::Cron::WithdrawWatcher }

  before(:all) do
    Peatio::Wallet.registry[:abstract] = AbstractWallet
  end

  context :under_review_withdraws do
    let!(:hot_wallet) { Wallet.active.joins(:currencies).find_by(currencies: { id: 'btc' }, kind: :hot).tap {|w| w.update(gateway: 'abstract')} }
    let!(:btc_withdraw) do
      create(:btc_withdraw, :with_deposit_liability, remote_id: 'id12345451')
        .tap(&:accept!)
        .tap(&:process!)
        .tap(&:review!)
    end

    context :success do
      it 'successfully dispatch ' do
        expect(btc_withdraw.aasm_state).to eq 'under_review'
        expect(btc_withdraw.txid).to eq nil
        subject.process_under_review_withdrawals

        btc_withdraw.reload
        expect(btc_withdraw.aasm_state).to eq 'confirming'
        expect(btc_withdraw.txid).to eq '0x1762873161782YD121ui'
      end

      context :skip do
        it 'skip withdraw if remote_id does not exists ' do
          btc_withdraw.update(remote_id: nil)
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
          subject.process_under_review_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
        end

        it 'skip withdraw if hot wallet does not exists ' do
          hot_wallet.update(status: 'disabled')
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
          subject.process_under_review_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
        end

        it 'skip withdraw if gateway does not support fetch_blockchain_transaction_id method' do
          hot_wallet.update(gateway: 'geth')
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
          subject.process_under_review_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
        end

        it 'does not change withdraw state if transaction ID is not available' do
          AbstractWallet.any_instance.stubs(:fetch_blockchain_transaction_id).returns(nil)
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
          subject.process_under_review_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'under_review'
          expect(btc_withdraw.txid).to eq nil
        end
      end
    end

    context :fails do
      it 'rescue error and does not change withdraw state' do
        AbstractWallet.any_instance.stubs(:fetch_blockchain_transaction_id).raises(StandardError)
        expect(btc_withdraw.aasm_state).to eq 'under_review'
        expect(btc_withdraw.txid).to eq nil

        expect { subject.process_under_review_withdrawals}.not_to raise_error

        btc_withdraw.reload
        expect(btc_withdraw.aasm_state).to eq 'under_review'
        expect(btc_withdraw.txid).to eq nil
      end
    end

  end

  context :confirming_withdraws do
    let!(:hot_wallet) { Wallet.active.joins(:currencies).find_by(currencies: { id: 'btc' }, kind: :hot).tap {|w| w.update(gateway: 'abstract')} }
    let!(:btc_withdraw) do
      create(:btc_withdraw, :with_deposit_liability, remote_id: 'id12345451', txid: '0xd4d5dda4808a43a35ef3cda76a710c95c89bedf72805ddc9111b0c8742ba9862')
        .tap(&:accept!)
        .tap(&:process!)
        .tap(&:dispatch!)
    end

    context :success do
      it 'successfully confirm' do
        expect(btc_withdraw.aasm_state).to eq 'confirming'
        subject.process_confirming_withdrawals

        btc_withdraw.reload
        expect(btc_withdraw.aasm_state).to eq 'succeed'
      end

      context :skip do
        it 'skip withdraw if remote_id does not exists ' do
          btc_withdraw.update(remote_id: nil)
          expect(btc_withdraw.aasm_state).to eq 'confirming'
          subject.process_confirming_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'confirming'
        end

        it 'skip withdraw if hot wallet does not exists ' do
          hot_wallet.update(status: 'disabled')
          expect(btc_withdraw.aasm_state).to eq 'confirming'
          subject.process_confirming_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'confirming'
        end

        it 'skip withdraw if gateway does not support fetch_withdraw_status method' do
          hot_wallet.update(gateway: 'geth')
          expect(btc_withdraw.aasm_state).to eq 'confirming'
          subject.process_confirming_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'confirming'
        end

        it 'does not change withdraw state if withdraw is not confirmed on blockchain' do
          AbstractWallet.any_instance.stubs(:fetch_withdraw_status).returns('pending')
          expect(btc_withdraw.aasm_state).to eq 'confirming'
          subject.process_confirming_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'confirming'
        end

        it 'does not change withdraw state if withdraw is not confirmed on blockchain' do
          AbstractWallet.any_instance.stubs(:fetch_withdraw_status).returns(nil)
          expect(btc_withdraw.aasm_state).to eq 'confirming'
          subject.process_confirming_withdrawals

          btc_withdraw.reload
          expect(btc_withdraw.aasm_state).to eq 'confirming'
        end
      end
    end

    context :fails do
      it 'rejects withdraw if it is rejected by gateway' do
        AbstractWallet.any_instance.stubs(:fetch_withdraw_status).returns('rejected')
        expect(btc_withdraw.aasm_state).to eq 'confirming'
        subject.process_confirming_withdrawals

        btc_withdraw.reload
        expect(btc_withdraw.aasm_state).to eq 'rejected'
      end

      it 'fails withdraw if it is failed by gateway' do
        AbstractWallet.any_instance.stubs(:fetch_withdraw_status).returns('failed')
        expect(btc_withdraw.aasm_state).to eq 'confirming'
        subject.process_confirming_withdrawals

        btc_withdraw.reload
        expect(btc_withdraw.aasm_state).to eq 'failed'
      end

      it 'rescue error and does not change withdraw state' do
        AbstractWallet.any_instance.stubs(:fetch_withdraw_status).raises(StandardError)
        expect(btc_withdraw.aasm_state).to eq 'confirming'
        expect { subject.process_confirming_withdrawals}.not_to raise_error

        btc_withdraw.reload
        expect(btc_withdraw.aasm_state).to eq 'confirming'
      end
    end
  end
end
