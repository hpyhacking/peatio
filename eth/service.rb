require 'web3'
w3 = Web3.new
while true
	accounts = w3.eth_accounts
        bn = w3.eth_blockNumber - 5
        block = w3.eth_getBlockByNumber('0x' + bn.to_s(16))
        for tx in block["transactions"]
                if accounts.include? tx["to"]
                        puts tx
                        postData = Net::HTTP.post_form(URI.parse('https://yourwebsite.com/webhooks/eth'), {'type'=>'transaction', 'hash'=>tx["hash"]})
                        sleep 5
                end
        end
end
