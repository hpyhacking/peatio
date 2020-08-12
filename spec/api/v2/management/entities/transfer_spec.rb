# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Entities::Transfer do
  let(:record) { create(:transfer) }
  subject { OpenStruct.new API::V2::Management::Entities::Transfer.represent(record.reload).serializable_hash }

  it do
    expect(subject.key).to eq record.key
    expect(subject.category).to eq record.category
    expect(subject.description).to eq record.description
  end

  context 'with operations' do
    let(:record) { create(:transfer_with_operations) }
    it do
      ::Operations::Account::TYPES.map(&:pluralize).each do |op_t|
        expect(subject.respond_to?(op_t)).to be_truthy
      end
    end

    it do
      record_assets = API::V2::Management::Entities::Operation
                        .represent(record.reload.assets)
      expect(subject.assets.to_json).to eq record_assets.to_json
    end

    it do
      record_expenses = API::V2::Management::Entities::Operation
                          .represent(record.reload.expenses)
      expect(subject.expenses.to_json).to eq record_expenses.to_json
    end

    it do
      record_liabilities = API::V2::Management::Entities::Operation
                             .represent(record.reload.liabilities)
      expect(subject.liabilities.to_json).to eq record_liabilities.to_json
    end

    it do
      record_revenues = API::V2::Management::Entities::Operation
                             .represent(record.reload.revenues)
      expect(subject.revenues.to_json).to eq record_revenues.to_json
    end
  end

  context 'with single operation type' do
    let(:record) { create(:transfer, :with_liabilities) }

    it do
      expect(subject.respond_to?(:liabilities)).to be_truthy
    end

    it do
      # TYPES - 'liabilities' = PLATFORM_TYPES
      ::Operations::Account::PLATFORM_TYPES.map(&:pluralize).each do |op_t|
        expect(subject.respond_to?(op_t.to_sym)).to be_falsey
      end
    end
  end

  context 'without operations' do
    it do
      ::Operations::Account::TYPES.map(&:pluralize).each do |op_t|
        expect(subject.respond_to?(op_t)).to be_falsey
      end
    end
  end
end
