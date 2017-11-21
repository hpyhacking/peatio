describe CoinRPC do
  describe '#http_post_request' do
    it 'raises custom error on connection refused' do
      Net::HTTP.any_instance.stubs(:request).raises(Errno::ECONNREFUSED)

      expect do
        CoinRPC[:btc].http_post_request '/wrong'
      end.to raise_error(CoinRPC::ConnectionRefusedError)
    end
  end
end
