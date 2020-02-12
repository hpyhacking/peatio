# encoding: UTF-8
# frozen_string_literal: true

describe Transfer do
  let(:currency_btc) { Currency.find(:btc) }
  let(:currency_eth) { Currency.find(:eth) }
  let(:currency_usd) { Currency.find(:usd) }

  context 'validations' do
    subject { build(:transfer) }

    describe 'key' do
      it 'uniqueness' do
        existing_transfer = create(:transfer)
        subject.key = existing_transfer.key
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:key, /has already been taken/)
      end

      it 'presence' do
        subject.key = nil
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:key, /can't be blank/)
      end
    end

    describe 'category' do
      it 'presence' do
        subject.category = nil
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:category, /can't be blank/)
      end
    end

    describe 'accounting equation' do
      context 'single asset operation' do
        subject { build(:transfer, assets: build_list(:asset, 5)) }

        it 'invalidates transfer' do
          expect(subject.valid?).to be_falsey
          expect(subject).to include_ar_error(:base, /invalidates accounting equation/)
        end
      end

      context 'different operations with invalid accounting sum' do
        subject do
          build(:transfer,
                assets: assets,
                liabilities: liabilities,
                revenues: revenues,
                expenses: expenses)
        end

        context 'with single currency' do
          let(:assets) { [build(:asset, credit: 1, currency: currency_btc)] }
          let(:liabilities) { [build(:liability, :with_member, credit: 5, currency: currency_btc)] }
          let(:revenues) { [build(:revenue, credit: 5, currency: currency_btc)] }
          let(:expenses) { [build(:expense, credit: 1, currency: currency_btc)] }

          it 'invalidates transfer' do
            expect(subject.valid?).to be_falsey
            expect(subject).to include_ar_error(:base, /invalidates accounting equation/)
          end
        end

        context 'with different currencies' do
          let(:assets) { [build(:asset, credit: 1, currency: currency_btc)] }
          let(:liabilities) { [build(:liability, :with_member, credit: 5, currency: currency_eth)] }
          let(:revenues) { [build(:revenue, credit: 5, currency: currency_usd)] }
          let(:expenses) { [build(:expense, credit: 1, currency: currency_btc)] }

          it 'invalidates transfer' do
            expect(subject.valid?).to be_falsey
            expect(subject).to include_ar_error(:base, /invalidates accounting equation/)
          end
        end

        context 'multiple operations per operation type' do
          # assets - liabilities = revenues - expenses
          #
          # BTC:
          # (10 + 15) - (9 + 12) = (3 + 5) - (1 + 3)
          # 25 - 21 = 8 - 4
          # BTC accounting is correct.
          let(:asset1) { build(:asset, credit: 10, currency: currency_btc) }
          let(:asset2) { build(:asset, credit: 15, currency: currency_btc) }

          let(:liability1) { build(:liability, :with_member, credit: 9, currency: currency_btc) }
          let(:liability2) { build(:liability, :with_member, credit: 12, currency: currency_btc) }

          let(:revenue1) { build(:revenue, credit: 3, currency: currency_btc) }
          let(:revenue2) { build(:revenue, credit: 5, currency: currency_btc) }

          let(:expense1) { build(:expense, credit: 1, currency: currency_btc) }
          let(:expense2) { build(:expense, credit: 3, currency: currency_btc) }

          # assets - liabilities = revenues - expenses
          #
          # USD:
          # (90 + 25) - (88 + 25) = (4 + 2) - (2 + 1)
          # 115 - 113 = 6 - 3
          # USD accounting is broken.
          let(:asset3) { build(:asset, credit: 90, currency: currency_usd) }
          let(:asset4) { build(:asset, credit: 25, currency: currency_usd) }

          let(:liability3) { build(:liability, :with_member, credit: 88, currency: currency_usd) }
          let(:liability4) { build(:liability, :with_member, credit: 25, currency: currency_usd) }

          let(:revenue3) { build(:revenue, credit: 4, currency: currency_usd) }
          let(:revenue4) { build(:revenue, credit: 2, currency: currency_usd) }

          let(:expense3) { build(:expense, credit: 2, currency: currency_usd) }
          let(:expense4) { build(:expense, credit: 1, currency: currency_usd) }

          let(:assets) { [asset1, asset2, asset3, asset4] }
          let(:liabilities) { [liability1, liability2, liability3, liability4] }
          let(:revenues) { [revenue1, revenue2, revenue3, revenue4] }
          let(:expenses) { [expense1, expense2, expense3, expense4] }

          it 'invalidates transfer' do
            expect(subject.valid?).to be_falsey
            expect(subject).to include_ar_error(:base, /invalidates accounting equation/)
          end
        end
      end

      context 'valid accounting sum' do
        subject do
          build(:transfer,
                assets: assets,
                liabilities: liabilities,
                revenues: revenues,
                expenses: expenses)
        end
        context 'with single currency' do
          # assets - liabilities = revenues - expenses
          #
          # BTC:
          # (30 + 45 - 12) - (9 + 12 - 2) = (28 + 20 - 2) - (1 + 4 - 3)
          # 63 - 19 = 46 - 2
          # BTC accounting is correct.
          let(:member1) { create(:member, :level_3).tap { |m| m.get_account(currency_btc).plus_funds(50.0) } }

          let(:asset1) { build(:asset, credit: 30, currency: currency_btc) }
          let(:asset2) { build(:asset, credit: 45, currency: currency_btc) }
          let(:asset3) { build(:asset, :debit, debit: 12, currency: currency_btc) }

          let(:liability1) { build(:liability, :with_member, credit: 9, currency: currency_btc) }
          let(:liability2) { build(:liability, :with_member, credit: 12, currency: currency_btc) }
          let(:liability3) { build(:liability, :debit, :with_member, debit: 2, member: member1, currency: currency_btc) }

          let(:revenue1) { build(:revenue, credit: 28, currency: currency_btc) }
          let(:revenue2) { build(:revenue, credit: 20, currency: currency_btc) }
          let(:revenue3) { build(:revenue, :debit, debit: 2, currency: currency_btc) }

          let(:expense1) { build(:expense, credit: 1, currency: currency_btc) }
          let(:expense2) { build(:expense, credit: 4, currency: currency_btc) }
          let(:expense3) { build(:expense, :debit, debit: 3, currency: currency_btc) }


          let(:assets) { [asset1, asset2, asset3] }
          let(:liabilities) { [liability1, liability2, liability3] }
          let(:revenues) { [revenue1, revenue2, revenue3] }
          let(:expenses) { [expense1, expense2, expense3] }

          it 'validates transfer' do
            expect(subject.save!).to be_truthy
          end
        end
      end
    end
  end

  context 'do_transfer!' do
    subject do
      Transfer.create!(attributes_for(:transfer,
                                           liabilities: liabilities,
                                           assets: assets,
                                           revenues: revenues,
                                           expenses: expenses))
    end
    let(:asset1) { build(:asset, credit: 9, currency: currency_btc) }
    let(:asset2) { build(:asset, :debit, debit: 6, currency: currency_btc) }
    let(:revenue1) { build(:revenue, credit: 12, currency: currency_btc) }
    let(:revenue2) { build(:revenue, :debit, debit: 3, currency: currency_btc) }
    let(:expense1) { build(:expense, credit: 8, currency: currency_btc) }
    let(:expense2) { build(:expense, :debit, debit: 2, currency: currency_btc) }
    let(:assets) { [asset1, asset2] }
    let(:revenues) { [revenue1, revenue2] }
    let(:expenses) { [expense1, expense2] }
    let(:liabilities) { [] }

    it 'creates transfer' do
      expect {
        subject
      }.to change { Transfer.count }.by 1
    end

    context 'update_legacy_balances' do
      context 'without liabilities' do
        it 'does not change legacy balances' do
          expect {
            subject
          }.not_to change { Member.all.map(&:accounts) }
        end
      end

      context 'with liabilities' do
        let(:member1) { create(:member, :level_3).tap { |m| m.get_account(currency_btc).plus_funds(50.0) } }
        let(:member2) { create(:member, :level_3).tap { |m| m.get_account(currency_btc).plus_funds(50.0) } }
        let(:member3) { create(:member, :level_3).tap { |m| m.get_account(currency_btc).plus_funds(50.0) } }
        let(:credit) { build(:liability, credit: 9, member: member1, currency: currency_btc) }
        let(:debit1) { build(:liability, :debit, debit: 5, member: member2, currency: currency_btc) }
        let(:debit2) { build(:liability, :debit, debit: 4, member: member3, currency: currency_btc) }

        let(:liabilities) { [credit, debit1, debit2] }

        it 'increases balance for member1' do
          expect {
            subject
          }.to change { member1.accounts.find_by(currency: currency_btc).balance }.by(9)
        end

        it 'decreases balance for member2' do
          expect {
            subject
          }.to change { member2.accounts.find_by(currency: currency_btc).balance }.by(-5)
        end

        it 'decreases balance for member3' do
          expect {
            subject
          }.to change { member3.accounts.find_by(currency: currency_btc).balance }.by(-4)
        end

        context 'legacy balance update raise error' do
          before do
            Account.any_instance.expects(:sub_funds).raises(Account::AccountError)
          end

          it 'does not create transfer' do
            expect {
              subject rescue Account::AccountError; nil
            }.to_not change{ Transfer.count }
          end
        end
      end
    end
  end
end
