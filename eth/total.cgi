#!/bin/bash 
echo "Content-type: text/html"
echo ""

TOT=`geth attach rpc:http://127.0.0.1:8545 --exec 'loadScript("/home/ubuntu/total.js"); totBal() ;' | head -n 1`
echo $TOT
exit 0

