# encoding: UTF-8
# frozen_string_literal: true

describe Operations::Account do
  let(:account) { Operations::Account.find_by(code: '101') }

  describe '#code' do
    it 'validates presence' do
      account.code = nil
      account.valid?
      expect(account.errors[:code]).to include("can't be blank")
    end

    it 'validates uniqueness' do
      account.code = '102' # an already existing code
      account.valid?
      expect(account.errors[:code]).to include("has already been taken")

      account.code = '901' # a new code
      account.valid?
      expect(account.errors[:code]).to be_empty
    end
  end

  describe '#type' do
    it 'validates presence' do
      account.type = nil
      account.valid?
      expect(account.errors[:type]).to include("can't be blank")
    end

    it 'validates inclusion' do
      account.type = 'an-nonexistent-type'
      account.valid?
      expect(account.errors[:type]).to include("is not included in the list")

      account.type = Operations::Account::TYPES.first # an existent type
      account.valid?
      expect(account.errors[:type]).to be_empty
    end
  end

  describe '#kind' do
    it 'validates presence' do
      account.kind = nil
      account.valid?
      expect(account.errors[:kind]).to include("can't be blank")
    end

    it 'validates uniqueness scoped to type and currency_type' do
      account = Operations::Account.new

      # an already existing (kind, type, currency_type)
      account.kind          = :main
      account.type          = :asset
      account.currency_type = :fiat
      account.code = 101
      account.valid?
      expect(account.errors[:kind]).to include("has already been taken")

      # a different type
      account.type = :different_type
      account.valid?
      expect(account.errors[:kind]).to be_empty

      # restore existing type, but different currency_type
      account.type          = :asset
      account.currency_type = :different_currency_type
      account.valid?
      expect(account.errors[:kind]).to be_empty
    end
  end

  describe '#currency_type' do
    it 'validates presence' do
      account.currency_type = nil
      account.valid?
      expect(account.errors[:currency_type]).to include("can't be blank")
    end

    it 'validates inclusion' do
      account.currency_type = 'an-nonexistent-currency-type'
      account.valid?
      expect(account.errors[:currency_type]).to include("is not included in the list")

      account.currency_type = Currency.types.first # an existent currency_type
      account.valid?
      expect(account.errors[:currency_type]).to be_empty
    end
  end

  describe '#scope' do
    it 'validates presence' do
      account.scope = nil
      account.valid?
      expect(account.errors[:scope]).to include("can't be blank")
    end

    it 'validates inclusion' do
      account.scope = 'an-nonexistent-scope'
      account.valid?
      expect(account.errors[:scope]).to include("is not included in the list")

      account.scope = Operations::Account::SCOPES.first # an existent scope
      account.valid?
      expect(account.errors[:scope]).to be_empty
    end
  end
end
