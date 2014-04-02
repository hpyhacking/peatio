module Private::AssetsHelper

  def main_btc_address_link(assets)
    addr = assets['accounts'].first['address']
    link_to addr, btc_block_url(addr)
  end

  def verify_link(proof, partial_tree)
    hashtag = "verify?partial_tree=#{partial_tree.json.to_json}&expected_root=#{proof.root.to_json}"
    uri = "http://syskall.com/proof-of-liabilities/##{URI.encode hashtag}"
    link_to t('.go-verify'), uri, :class => 'btn btn-default', :target => '_blank'
  end

end
