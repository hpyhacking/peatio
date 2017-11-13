describe CoinRPC do
  describe '#http_post_request' do
    it 'raises custom error on connection refused' do
      Net::HTTP.any_instance.stubs(:request).raises(Errno::ECONNREFUSED)

      rpc_client = CoinRPC::BTC.new('http://127.0.0.1:18332')

      expect do
        rpc_client.http_post_request ''
      end.to raise_error(CoinRPC::ConnectionRefusedError)
    end
  end
end
