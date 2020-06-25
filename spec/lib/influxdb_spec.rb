# encoding: UTF-8
# frozen_string_literal: true

describe Peatio::InfluxDB do
  context 'host sharding' do
    before { ENV['INFLUXDB_HOST'] = 'inflxudb-0,inflxudb-1' }

    after do
      ENV['INFLUXDB_HOST'] = 'influxdb'
      Peatio::InfluxDB.instance_variable_set(:@clients, {})
    end

    it { expect(Peatio::InfluxDB.client(keyshard: 'btcusd').config.hosts).to eq(['inflxudb-1']) }
    it { expect(Peatio::InfluxDB.client(keyshard: 'ethusd').config.hosts).to eq(['inflxudb-0']) }
  end
end
