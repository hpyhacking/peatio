## Using Bitgo with Peatio instead of Bitcoind

### Requirments
1. Bitgo account
2. Bitgod 

### Installing
After installing Peatio you should do this

    git clone https://github.com/BitGo/bitgod.git
    cd bitgod
    sudo npm -g install bitgod

Create an account on bitgo then get your wallet id by looking at the link it should be like This

https://www.bitgo.com/enterprise/personal/wallets/Walletid

Then do vim connect.sh and put this inside and change the values
    
    bitcoin-cli -rpcport=9332 settoken <YOUR_TOKEN_ID>
    bitcoin-cli -rpcport=9332 setwallet <YOUR_WALLET_ID>
    bitcoin-cli -rpcport=9332 walletpassphrase <YOUR_WALLET_PASSWORD> 32000000

Do chmod +x connect.sh

    sudo touch /var/log/bitgod.log
    sudo chown deploy:deploy /var/log/bitgod.log

Let's make a service for bitgod to automate it!
Do vim /etc/systemd/systemd/bitgod.service then add 

    [Unit]
    Description=Bitgod daemon
    After=network.target

    [Service]
    User=deploy
    Group=deploy
    Type=simple
    ExecStart=/home/deploy/bitgod/bin/bitgod  -logfile /var/log/bitgod.log -env prod -masqueradeaccount=payment -rpcuser YOUR_USERNAME -rpcpassword YOUR_PASSWORD
    Restart=always
    PrivateTmp=true
    TimeoutStopSec=60s
    TimeoutStartSec=2s
    StartLimitInterval=120s
    StartLimitBurst=5

    [Install]
    WantedBy=multi-user.target

Then start it
    
    sudo service bitgod start

And enable it to run on boot
    
    sudo systemctl enable bitgod

Let's make another service to make bitgod connect to bitgo
    
    sudo vim /etc/systemd/system/connect.service

    [Unit]
    After=bitgod.service

    [Service]
    ExecStart=/home/deploy/connect.sh

    [Install]
    WantedBy=default.target

Then start it and enable it too

    sudo service connect start
    sudo systemctl enable connect

All you need now is to edit your config/currencies.yml