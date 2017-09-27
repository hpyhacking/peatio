function totBal(){
var i = 0;
var bal1 = 0;
var bal2 = 0;
eth.accounts.forEach( function(e){
    bal1 = parseInt(eth.getBalance(e));
    bal2 += parseInt(bal1);         
});
console.log(web3.fromWei(bal2, "ether"));
};
