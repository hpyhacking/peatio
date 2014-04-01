module Private::AssetsHelper

  def main_btc_address_link(assets)
    addr = assets['accounts'].first['address']
    link_to addr, btc_block_url(addr)
  end

end
