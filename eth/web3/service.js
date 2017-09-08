const Web3 = require('web3')
const winston = require('winston')
const axios = require('axios')


let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))
let accounts = (web3.personal.listAccounts).toLocaleString().toLowerCase().split(',')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: 'webhook.log' })
  ]
});

let filter = web3.eth.filter('latest')
filter.watch(function(error, result) {
  if (!error) {
    let confirmedBlock12 = web3.eth.getBlock(web3.eth.blockNumber - 11)
    confirmedBlock12.transactions.forEach(function(txId) {
      let transaction = web3.eth.getTransaction(txId)
      if (accounts.indexOf(transaction.to) > -1) {
          logger.log('info', transaction) ; 
          axios.post('https://yourwebsite.tld/webhooks/eth', {
            type: 'transaction',
            hash: transaction.hash
          })
          .then(function (response) {
              logger.log('info', response);
          })
          .catch(function (error) {
              logger.log('error', error);
          });
      }
    })
  }
})
