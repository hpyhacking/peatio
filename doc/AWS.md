# How to run Peatio and bitcoind on  Separate  Servers on AWS 

### what do you need?
- micro instance (for bitcoind don't create now)
- medium instance (for peatio) 
- EBS disk with 150 GB (To download the full node)
You should follow this steps [here](https://github.com/muhammednagy/peatio/blob/master/doc/deploy-production-server.md) to deploy Peatio ignore the bitcoind part

### create Bitcoind Server
1. Login to AWS Dashboard
2. head to EC2 
3. make a new micro instance and choose Ubuntu 16.04
4. add new 150 GB disk and mount it on /dev/xvdb
5. open SSH port to the world or your IP only if you have static IP  
6. allow port 8333 for the security group (default launch-wizard-1 )

### adding EBS disk 
    sudo mkfs.ext4 /dev/xvdb
    mkdir /home/ubuntu/bitcoind

add this line to /etc/fstab

    /dev/xvdb   /home/ubuntu/bitcoind    ext4    defaults    0    1

then do 
    
    sudo mount /dev/xvdb /home/ubuntu/bitcoind    
### Installing bitcoind Server

SSH into the Server and execute these commands

    sudo add-apt-repository ppa:bitcoin/bitcoin
    sudo apt-get update
    sudo apt-get install bitcoind

### Configuring bitcoind

    touch ~/bitcoind/bitcoin.conf
    vim ~/bitcoin/bitcoin.conf

Insert the following lines into the bitcoin.conf, and replce with your username and password.

    server=1
    daemon=1

    # If run on the test network instead of the real bitcoin network
    #testnet=1

    # You must set rpcuser and rpcpassword to secure the JSON-RPC api
    # Please make rpcpassword to something secure, `5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k` for example.
    # Listen for JSON-RPC connections on <port> (default: 8332 or testnet: 18332)
    rpcuser=INVENT_A_UNIQUE_USERNAME
    rpcpassword=INVENT_A_UNIQUE_PASSWORD
    rpcport=9333
    rpcallowip=PEATIO_SERVER_IP_HERE              
    # Notify when receiving coins
    walletnotify=/usr/bin/curl -d '{"type":"transaction", "hash":"%s"}' -H "Content-Type: application/json" -X POST https://yourwebsite.tld/webhooks/tx


### Run bitcoind automatically 

    sudo touch /etc/systemd/system/bitcoind.service
    sudo vim /etc/systemd/system/bitcoind.service

insert these lines into the file

    [Unit]
    Description=Bitcoin's distributed currency daemon
    After=network.target

    [Service]
    User=ubuntu
    Group=ubuntu

    Type=forking
    PIDFile=/home/ubuntu/bitcoind/bitcoind.pid
    ExecStart=/usr/bin/bitcoind -daemon -pid=/home/ubuntu/bitcoind/bitcoind.pid -conf=/home/ubuntu/bitcoind/bitcoin.conf -datadir=/home/ubuntu/bitcoind/

    Restart=always
    PrivateTmp=true
    TimeoutStopSec=60s
    TimeoutStartSec=2s
    StartLimitInterval=120s
    StartLimitBurst=5

    [Install]
    WantedBy=multi-user.target


save the file and run

    sudo systemctl start bitcoind
    sudo systemctl enable bitcoind # to enable automatica start when you reboot the server

# done 
You only need to put your username,password,the IP and port in currencies.yml
