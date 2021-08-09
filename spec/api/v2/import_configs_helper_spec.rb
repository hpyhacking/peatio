# frozen_string_literal: true

RSpec.describe API::V2::ImportConfigsHelper do
  let(:test_file) { File.read(Rails.root.join('spec', 'resources', 'import_configs', file_name)) }
  let(:file_name) { 'data.json' }

  subject(:import_configs) { API::V2::ImportConfigsHelper.new.process(tempfile: test_file) }

  it 'create new currency' do
    expect { import_configs }.to change { Currency.count }.by(2)
  end

  it 'create new blockchain currency' do
    expect { import_configs }.to change { BlockchainCurrency.count }.by(2)
  end

  it 'create new blockchain' do
    expect { import_configs }.to change { Blockchain.count }.by(1)
  end

  it 'create new wallet' do
    expect { import_configs }.to change { Wallet.count }.by(2)
  end

  it 'create new market' do
    Engine.create!(name: "peatio-default-engine", driver: 'peatio')
    expect { import_configs }.to change { Market.count }.by(1)
  end
end
