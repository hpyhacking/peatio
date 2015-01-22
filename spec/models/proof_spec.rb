require 'spec_helper'

describe Proof do
  describe '#asset_sum' do
    it 'aggregates address balances' do
      proof = Proof.new(addresses: [
        {"address"=>"1HjfnJpQmANtuW7yr1ggeDfyfe1kDK7rxx", "balance"=>1},
        {"address"=>"1HjfnJpQmANtuW7yr1ggeDfyfe1kDK7rm3", "balance"=>2.00005},
        {"address"=>"1dice97ECuByXAvqXpaYzSaQuPVvrtmz6", "balance"=>5.84489237}
      ])

      expect(proof.asset_sum).to eq(8.84494237)
    end
  end
end
