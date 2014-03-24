module Private::AssetsHelper

  def main_btc_address_link
    addr = Currency.addresses && Currency.addresses['btc'].first
    link_to addr, btc_block_url(addr)
  end

end
