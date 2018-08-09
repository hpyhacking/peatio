# Change Log

## [Unreleased](https://github.com/rubykube/peatio/tree/HEAD)

[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.51...HEAD)

**Closed issues:**

- BUG: BTC Address Generation Error in Workbench [\#1488](https://github.com/rubykube/peatio/issues/1488)
- Ability to configure custom currency logo [\#1449](https://github.com/rubykube/peatio/issues/1449)
- Ability to specify minimum price per for trading [\#1447](https://github.com/rubykube/peatio/issues/1447)

**Merged pull requests:**

- Fixed icons [\#1516](https://github.com/rubykube/peatio/pull/1516) ([gfedorenko](https://github.com/gfedorenko))
- Fixed icons and renamed fields on Market New and Show pages [\#1515](https://github.com/rubykube/peatio/pull/1515) ([gfedorenko](https://github.com/gfedorenko))
- Revert "Added ability to disable currencies, markets and wallets" [\#1514](https://github.com/rubykube/peatio/pull/1514) ([gfedorenko](https://github.com/gfedorenko))
- API Middleware specs failure [\#1513](https://github.com/rubykube/peatio/pull/1513) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Updating patch level for gems [\#1512](https://github.com/rubykube/peatio/pull/1512) ([mod](https://github.com/mod))
- Added ability to disable currencies, markets and wallets [\#1511](https://github.com/rubykube/peatio/pull/1511) ([gfedorenko](https://github.com/gfedorenko))
- Feature/blockchains wallets [\#1510](https://github.com/rubykube/peatio/pull/1510) ([dmk](https://github.com/dmk))
- Improved dynamic txn fees for bitcoind/bitgo [\#1509](https://github.com/rubykube/peatio/pull/1509) ([dinesh-skyach](https://github.com/dinesh-skyach))
- ERC20 withdraw stuck in confirming when failed in blockchain [\#1507](https://github.com/rubykube/peatio/pull/1507) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fix wrong client for existing blockchain on admin panel [\#1504](https://github.com/rubykube/peatio/pull/1504) ([dmk](https://github.com/dmk))
- Fix erc20 deposit for tx with empty receipt [\#1503](https://github.com/rubykube/peatio/pull/1503) ([dmk](https://github.com/dmk))
- Fix erc20 deposit for tx with empty receipt [\#1502](https://github.com/rubykube/peatio/pull/1502) ([dmk](https://github.com/dmk))
- Bitgo wallet Client/Service [\#1491](https://github.com/rubykube/peatio/pull/1491) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Add icon url to currency \(closes \#1449\) [\#1465](https://github.com/rubykube/peatio/pull/1465) ([shal](https://github.com/shal))
- Support minimum price for Order \(closes \#1447\) [\#1460](https://github.com/rubykube/peatio/pull/1460) ([shal](https://github.com/shal))
- Integrate Blockchain and Wallet model and services with new transaction processing and multi wallet support  [\#1404](https://github.com/rubykube/peatio/pull/1404) ([mod](https://github.com/mod))

## [1.8.51](https://github.com/rubykube/peatio/tree/1.8.51) (2018-08-04)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.50...1.8.51)

**Closed issues:**

- Error or Bug? MultipleDepositAddresses [\#1469](https://github.com/rubykube/peatio/issues/1469)
- Rails 5.x support? [\#1455](https://github.com/rubykube/peatio/issues/1455)
- Trading UI doesn't appear [\#1437](https://github.com/rubykube/peatio/issues/1437)
- Simple Typo 'Canceld' [\#1380](https://github.com/rubykube/peatio/issues/1380)

**Merged pull requests:**

- Updates for admin panel [\#1501](https://github.com/rubykube/peatio/pull/1501) ([dmk](https://github.com/dmk))
- Fix typo [\#1496](https://github.com/rubykube/peatio/pull/1496) ([Atul9](https://github.com/Atul9))
- Add more details for the API docs [\#1493](https://github.com/rubykube/peatio/pull/1493) ([dmk](https://github.com/dmk))
- Fix typo in setup-osx.md documentation [\#1492](https://github.com/rubykube/peatio/pull/1492) ([skatkov](https://github.com/skatkov))
-  DepositCollectionFees worker for ERC20 [\#1489](https://github.com/rubykube/peatio/pull/1489) ([ysv](https://github.com/ysv))
- Improvements and bugfixes for ETH/ERC20 transactions [\#1486](https://github.com/rubykube/peatio/pull/1486) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Withdraw Coin Daemon [\#1485](https://github.com/rubykube/peatio/pull/1485) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Remove Unwanted Code From Currency MVC [\#1484](https://github.com/rubykube/peatio/pull/1484) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Improvements in Deposit coin address daemon [\#1482](https://github.com/rubykube/peatio/pull/1482) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Added deposit coin address daemon [\#1480](https://github.com/rubykube/peatio/pull/1480) ([dinesh-skyach](https://github.com/dinesh-skyach))
- WalletService module and WalletService::Base class [\#1479](https://github.com/rubykube/peatio/pull/1479) ([ysv](https://github.com/ysv))
- Add gateway & max\_balance to wallets [\#1478](https://github.com/rubykube/peatio/pull/1478) ([ysv](https://github.com/ysv))
-  Remove CoinAPI & daemons. Rename Client to BlockchainClient [\#1476](https://github.com/rubykube/peatio/pull/1476) ([ysv](https://github.com/ysv))
- Litecoin/Dash/BitcoinCash Blockchain Services [\#1475](https://github.com/rubykube/peatio/pull/1475) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Improve BlockchainService logger. Wallet & Blockchain bugfixes [\#1474](https://github.com/rubykube/peatio/pull/1474) ([ysv](https://github.com/ysv))
- Add blockchain key in currency [\#1473](https://github.com/rubykube/peatio/pull/1473) ([ritesh-skyach](https://github.com/ritesh-skyach))
- \[Ready\] Replace Confirmation With Block Number [\#1463](https://github.com/rubykube/peatio/pull/1463) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Include PublishToRabbitMQ GenerateJWT Event API middlewares by default [\#1459](https://github.com/rubykube/peatio/pull/1459) ([ysv](https://github.com/ysv))
- Bitcoin Blockchain Service [\#1444](https://github.com/rubykube/peatio/pull/1444) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fix migration multiple\_deposit\_addresses [\#1402](https://github.com/rubykube/peatio/pull/1402) ([calj](https://github.com/calj))

## [1.8.50](https://github.com/rubykube/peatio/tree/1.8.50) (2018-07-20)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.29...1.8.50)

**Closed issues:**

- Include PublishToRabbitMQ GenerateJWT Event API middlewares [\#1457](https://github.com/rubykube/peatio/issues/1457)

**Merged pull requests:**

- Add API endpoint for currencies \(\#1433\) [\#1462](https://github.com/rubykube/peatio/pull/1462) ([ymasiuk](https://github.com/ymasiuk))
- Include PublishToRabbitMQ GenerateJWT Event API middlewares by default \(closes \#1457\) [\#1458](https://github.com/rubykube/peatio/pull/1458) ([ysv](https://github.com/ysv))
- Event API serializers imporvements \(closes \#1376, \#1396\) [\#1442](https://github.com/rubykube/peatio/pull/1442) ([rxx](https://github.com/rxx))
- Add API endpoint for currencies [\#1433](https://github.com/rubykube/peatio/pull/1433) ([shal](https://github.com/shal))

## [1.6.29](https://github.com/rubykube/peatio/tree/1.6.29) (2018-07-19)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.29...1.6.29)

## [1.7.29](https://github.com/rubykube/peatio/tree/1.7.29) (2018-07-19)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.49...1.7.29)

## [1.8.49](https://github.com/rubykube/peatio/tree/1.8.49) (2018-07-19)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.48...1.8.49)

**Closed issues:**

- Ability to configure icon for currency [\#1448](https://github.com/rubykube/peatio/issues/1448)
- Where can admin verify a users identity ? [\#1446](https://github.com/rubykube/peatio/issues/1446)
- Sign out from Peatio does not work. [\#1445](https://github.com/rubykube/peatio/issues/1445)
- Page localhost:3000/trading/usdbtc doesn't exist [\#1436](https://github.com/rubykube/peatio/issues/1436)
- Wash/Self trading [\#1435](https://github.com/rubykube/peatio/issues/1435)
- I guess the coin daemon should ignore disabled currencies. [\#1428](https://github.com/rubykube/peatio/issues/1428)
- Coins with different conf names - withdrawal fails [\#1425](https://github.com/rubykube/peatio/issues/1425)
- Pusher --\> Slanger \(Question\) [\#1423](https://github.com/rubykube/peatio/issues/1423)
- I have enabled the 18332 port on AWS but connection refuse issue has come out. [\#1418](https://github.com/rubykube/peatio/issues/1418)
- I am not able to withdraw ETH or ERC20 tokens [\#1416](https://github.com/rubykube/peatio/issues/1416)
- Configuration for Barong [\#1414](https://github.com/rubykube/peatio/issues/1414)
- How can I set cold and hot wallets on Admin dashboard? [\#1405](https://github.com/rubykube/peatio/issues/1405)

**Merged pull requests:**

- Change Default Domain To peatio.tech [\#1454](https://github.com/rubykube/peatio/pull/1454) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Change Default Domain To peatio.tech [\#1453](https://github.com/rubykube/peatio/pull/1453) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Change Default Domain To peatio.tech [\#1452](https://github.com/rubykube/peatio/pull/1452) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Change Default Domain To peatio.tech [\#1451](https://github.com/rubykube/peatio/pull/1451) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Change Default Domain To peatio.tech \(closes \#1443\) [\#1450](https://github.com/rubykube/peatio/pull/1450) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Added Wallet/Blockchain validations [\#1429](https://github.com/rubykube/peatio/pull/1429) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Confirm withdrawals in BlockchainService \#process\_blockchain [\#1427](https://github.com/rubykube/peatio/pull/1427) ([ysv](https://github.com/ysv))
- Refactor Blockchain Service & BlockAPI [\#1424](https://github.com/rubykube/peatio/pull/1424) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Ability to register new blockchain and wallet [\#1422](https://github.com/rubykube/peatio/pull/1422) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Fix ERC20 token transactions processing [\#1421](https://github.com/rubykube/peatio/pull/1421) ([dinesh-skyach](https://github.com/dinesh-skyach))
- BlockchainService \#process\_blockchain deposits with proof of work [\#1417](https://github.com/rubykube/peatio/pull/1417) ([ysv](https://github.com/ysv))
- Withdrawals show transaction id [\#1411](https://github.com/rubykube/peatio/pull/1411) ([ritesh-skyach](https://github.com/ritesh-skyach))

## [1.8.48](https://github.com/rubykube/peatio/tree/1.8.48) (2018-07-12)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.47...1.8.48)

**Closed issues:**

- rails error [\#1415](https://github.com/rubykube/peatio/issues/1415)
- why the setting foun is hide ? [\#1401](https://github.com/rubykube/peatio/issues/1401)
- help me Failed to open TCP connection to exchangebitc.rog:80 \(getaddrinfo: Name or service not known\) [\#1397](https://github.com/rubykube/peatio/issues/1397)
- Which coins does Peatio support currently? [\#1394](https://github.com/rubykube/peatio/issues/1394)
- Incoming message from slanger [\#1392](https://github.com/rubykube/peatio/issues/1392)
- Why BitGo info is needed? [\#1389](https://github.com/rubykube/peatio/issues/1389)
- Wrong customer ID or password,please try again. [\#1388](https://github.com/rubykube/peatio/issues/1388)
- who know google oauth2 set [\#1385](https://github.com/rubykube/peatio/issues/1385)
- Additional market features [\#1383](https://github.com/rubykube/peatio/issues/1383)
- how to login with local accounts instead of google SSO? [\#1382](https://github.com/rubykube/peatio/issues/1382)
- Solvency Liability Proof likely to cause Out of Memory Issues [\#1381](https://github.com/rubykube/peatio/issues/1381)
- ECR20 and Peatio Original [\#1373](https://github.com/rubykube/peatio/issues/1373)
- High Severity Security Issue: DLL Loading Issue [\#1371](https://github.com/rubykube/peatio/issues/1371)
- Event API does not produce event on order status update [\#1369](https://github.com/rubykube/peatio/issues/1369)
- Why BitGo wallet info is needed? [\#1366](https://github.com/rubykube/peatio/issues/1366)
- Frontend modifications not registering. Caching issue? [\#1364](https://github.com/rubykube/peatio/issues/1364)
- admin/deposits/btc URL give error when run in production using passenger and nginx [\#1363](https://github.com/rubykube/peatio/issues/1363)
- KYC system with verification levels [\#1362](https://github.com/rubykube/peatio/issues/1362)
- After post to /v2/sessions "sessions are not synchronized"  [\#1336](https://github.com/rubykube/peatio/issues/1336)
- Can add error message in API endpoint [\#1333](https://github.com/rubykube/peatio/issues/1333)
- How to configure host file for remote environment \(docker compose\)  [\#1331](https://github.com/rubykube/peatio/issues/1331)
- Use blockchain data for withdraw confirmation [\#1247](https://github.com/rubykube/peatio/issues/1247)
- Remove or extract proof of liability \(solvency information\)  [\#1112](https://github.com/rubykube/peatio/issues/1112)
- We need specs for WS protocol API since we have none [\#705](https://github.com/rubykube/peatio/issues/705)
- Ability to set trading fee by user or groups of users [\#663](https://github.com/rubykube/peatio/issues/663)

**Merged pull requests:**

- Added 24 hours currency trades API endpoint \(\#1368\) [\#1420](https://github.com/rubykube/peatio/pull/1420) ([dmk](https://github.com/dmk))
- Fixed Broken market spec [\#1407](https://github.com/rubykube/peatio/pull/1407) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Update ffi to 1.9.25 [\#1393](https://github.com/rubykube/peatio/pull/1393) ([yivo](https://github.com/yivo))
- Remove auditing system \(you have to use Event API to do audits now\) [\#1391](https://github.com/rubykube/peatio/pull/1391) ([yivo](https://github.com/yivo))
- Remove solvency feature [\#1390](https://github.com/rubykube/peatio/pull/1390) ([yivo](https://github.com/yivo))
- Update sprockets gem [\#1386](https://github.com/rubykube/peatio/pull/1386) ([yivo](https://github.com/yivo))
- Add 24 hours currency trades API endpoint \(closes \#1356\) [\#1368](https://github.com/rubykube/peatio/pull/1368) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Ability to get data between some time interval \(time\_from, time\_to\) in GET /api/v2/k \(closes \#1290\) [\#1342](https://github.com/rubykube/peatio/pull/1342) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Send label when generating BitGo address \(closes \#1277\). [\#1318](https://github.com/rubykube/peatio/pull/1318) ([k1T4eR](https://github.com/k1T4eR))
- Allow users to have multiple deposit addresses [\#1282](https://github.com/rubykube/peatio/pull/1282) ([yivo](https://github.com/yivo))

## [1.8.47](https://github.com/rubykube/peatio/tree/1.8.47) (2018-07-03)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.46...1.8.47)

**Closed issues:**

- rubykube not answer [\#1384](https://github.com/rubykube/peatio/issues/1384)
- ActiveRecord::NoDatabaseError: Unknown database 'peatio\_production [\#1372](https://github.com/rubykube/peatio/issues/1372)

**Merged pull requests:**

- Document every daemon [\#1377](https://github.com/rubykube/peatio/pull/1377) ([yivo](https://github.com/yivo))

## [1.8.46](https://github.com/rubykube/peatio/tree/1.8.46) (2018-07-02)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.45...1.8.46)

**Merged pull requests:**

- Optimizations for trade executor [\#1335](https://github.com/rubykube/peatio/pull/1335) ([yivo](https://github.com/yivo))

## [1.8.45](https://github.com/rubykube/peatio/tree/1.8.45) (2018-07-02)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.44...1.8.45)

**Closed issues:**

- Unable to generate deposit address [\#1359](https://github.com/rubykube/peatio/issues/1359)
- Can create new endpoint in API [\#1356](https://github.com/rubykube/peatio/issues/1356)
- Do not receive error when get /api/v2/depth  with invalid/ not supported market  [\#1353](https://github.com/rubykube/peatio/issues/1353)
- How can i get data in specific time interval from GET /api/v2/k? [\#1290](https://github.com/rubykube/peatio/issues/1290)
- Remove Pusher Dependency [\#283](https://github.com/rubykube/peatio/issues/283)

**Merged pull requests:**

- Validate market param \(closes \#1353\) [\#1370](https://github.com/rubykube/peatio/pull/1370) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.8.44](https://github.com/rubykube/peatio/tree/1.8.44) (2018-06-28)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.28...1.8.44)

## [1.7.28](https://github.com/rubykube/peatio/tree/1.7.28) (2018-06-28)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.28...1.7.28)

## [1.6.28](https://github.com/rubykube/peatio/tree/1.6.28) (2018-06-28)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.21...1.6.28)

## [1.5.21](https://github.com/rubykube/peatio/tree/1.5.21) (2018-06-28)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.27...1.5.21)

**Closed issues:**

- Failed to run benchmark tools [\#1329](https://github.com/rubykube/peatio/issues/1329)
- Support SegWit wallets [\#215](https://github.com/rubykube/peatio/issues/215)

**Merged pull requests:**

- Fix XRP destination tag bug which breaks XRP withdraws \(closes \#1311\) [\#1341](https://github.com/rubykube/peatio/pull/1341) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Fix XRP destination tag bug which breaks XRP withdraws \(closes \#1311\) [\#1340](https://github.com/rubykube/peatio/pull/1340) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Fix XRP destination tag bug which breaks XRP withdraws \(closes \#1311\) [\#1339](https://github.com/rubykube/peatio/pull/1339) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Fix XRP destination tag bug which breaks XRP withdraws \(closes \#1311\) [\#1332](https://github.com/rubykube/peatio/pull/1332) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Specs for WS protocol API [\#1322](https://github.com/rubykube/peatio/pull/1322) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.7.27](https://github.com/rubykube/peatio/tree/1.7.27) (2018-06-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.27...1.7.27)

## [1.6.27](https://github.com/rubykube/peatio/tree/1.6.27) (2018-06-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.43...1.6.27)

## [1.8.43](https://github.com/rubykube/peatio/tree/1.8.43) (2018-06-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.20...1.8.43)

## [1.5.20](https://github.com/rubykube/peatio/tree/1.5.20) (2018-06-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.42...1.5.20)

**Closed issues:**

- enqueue\_address\_generation dead loop [\#1358](https://github.com/rubykube/peatio/issues/1358)
- Document Upload - We're sorry, but something went wrong. - ArgumentError \( is not a recognized provider\) [\#1357](https://github.com/rubykube/peatio/issues/1357)

**Merged pull requests:**

- Add missing error messages in APIv2 \(closes \#1333\) [\#1349](https://github.com/rubykube/peatio/pull/1349) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Add missing error messages in APIv2 \(closes \#1333\) [\#1348](https://github.com/rubykube/peatio/pull/1348) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Add missing error messages in APIv2 \(closes \#1333\) [\#1347](https://github.com/rubykube/peatio/pull/1347) ([ritesh-skyach](https://github.com/ritesh-skyach))
- Add missing error messages in APIv2 \(closes \#1333\) [\#1343](https://github.com/rubykube/peatio/pull/1343) ([ritesh-skyach](https://github.com/ritesh-skyach))

## [1.8.42](https://github.com/rubykube/peatio/tree/1.8.42) (2018-06-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.41...1.8.42)

**Merged pull requests:**

- Added ability to configure production db name from env [\#1355](https://github.com/rubykube/peatio/pull/1355) ([vshatravenko](https://github.com/vshatravenko))
- Adding docker compose files for backend services [\#1354](https://github.com/rubykube/peatio/pull/1354) ([mod](https://github.com/mod))

## [1.8.41](https://github.com/rubykube/peatio/tree/1.8.41) (2018-06-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.40...1.8.41)

**Closed issues:**

- Notify when receiving ethereum coins. [\#1351](https://github.com/rubykube/peatio/issues/1351)
- When run peatio in Production environment it does not feth Bitcoin RPC user name And Password [\#1350](https://github.com/rubykube/peatio/issues/1350)
- Access denied for user 'root'@' [\#1346](https://github.com/rubykube/peatio/issues/1346)
- Login issue [\#1345](https://github.com/rubykube/peatio/issues/1345)
- Missing a step in Ubuntu deployment [\#1338](https://github.com/rubykube/peatio/issues/1338)
- Trading interface results in to Routing error [\#1334](https://github.com/rubykube/peatio/issues/1334)
- How can I do trading with only Google authentication? [\#1330](https://github.com/rubykube/peatio/issues/1330)
- Ability to scale peatio daemons  [\#1327](https://github.com/rubykube/peatio/issues/1327)
- Can't see production logs [\#1326](https://github.com/rubykube/peatio/issues/1326)
- Matching engine and trade executor generating errors [\#1324](https://github.com/rubykube/peatio/issues/1324)
- Barong doesn't seem to work correctly [\#1320](https://github.com/rubykube/peatio/issues/1320)
- XRP withdraw seems broken in some situations  [\#1311](https://github.com/rubykube/peatio/issues/1311)
- Peatio to support admin approved withdrawals  [\#1011](https://github.com/rubykube/peatio/issues/1011)

**Merged pull requests:**

- Fix startup problems in benchmark \(fixes \#1329\) [\#1344](https://github.com/rubykube/peatio/pull/1344) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.8.40](https://github.com/rubykube/peatio/tree/1.8.40) (2018-06-20)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.39...1.8.40)

**Merged pull requests:**

- Matching engine and trade executor generating errors \(\#1324\) [\#1328](https://github.com/rubykube/peatio/pull/1328) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.8.39](https://github.com/rubykube/peatio/tree/1.8.39) (2018-06-18)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.38...1.8.39)

**Closed issues:**

- Use Member\#uid as BitGo's destination address label [\#1277](https://github.com/rubykube/peatio/issues/1277)
- Improvements for legacy benchmark tools [\#1249](https://github.com/rubykube/peatio/issues/1249)
- Minimum price for orders  [\#1088](https://github.com/rubykube/peatio/issues/1088)
- Ability to create multiple deposit address per user per coin [\#964](https://github.com/rubykube/peatio/issues/964)

**Merged pull requests:**

- Add missing GET /api/v2/member\_levels [\#1321](https://github.com/rubykube/peatio/pull/1321) ([yivo](https://github.com/yivo))

## [1.8.38](https://github.com/rubykube/peatio/tree/1.8.38) (2018-06-18)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.19...1.8.38)

**Closed issues:**

- Markets page error on daemon way [\#1319](https://github.com/rubykube/peatio/issues/1319)
- How can I see admin dashboard? [\#1317](https://github.com/rubykube/peatio/issues/1317)
- Google Authentication Redirect URI error [\#1316](https://github.com/rubykube/peatio/issues/1316)

**Merged pull requests:**

- Improvements for legacy benchmark tools \(closes \#1249\) [\#1254](https://github.com/rubykube/peatio/pull/1254) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.5.19](https://github.com/rubykube/peatio/tree/1.5.19) (2018-06-15)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.37...1.5.19)

## [1.8.37](https://github.com/rubykube/peatio/tree/1.8.37) (2018-06-15)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.26...1.8.37)

## [1.7.26](https://github.com/rubykube/peatio/tree/1.7.26) (2018-06-15)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.26...1.7.26)

## [1.6.26](https://github.com/rubykube/peatio/tree/1.6.26) (2018-06-15)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.25...1.6.26)

**Closed issues:**

- Installation issues on Ubunto 18 [\#1303](https://github.com/rubykube/peatio/issues/1303)
- new flag coin [\#1292](https://github.com/rubykube/peatio/issues/1292)
- Ability to select the order type \(market\) at the time of trading. [\#1289](https://github.com/rubykube/peatio/issues/1289)
- GET /api/v2/k throws error when there are no trades/orders in market  [\#1281](https://github.com/rubykube/peatio/issues/1281)
- WS protocol API Broken when receiving create/trade order details [\#1279](https://github.com/rubykube/peatio/issues/1279)
- Management API error if we send invalid UID in withdraws/new [\#1272](https://github.com/rubykube/peatio/issues/1272)

**Merged pull requests:**

- Handle race conditions when registering member + add useful logging for OmniAuth sequence. [\#1314](https://github.com/rubykube/peatio/pull/1314) ([yivo](https://github.com/yivo))
- Handle race conditions when registering member + add useful logging for OmniAuth sequence. [\#1313](https://github.com/rubykube/peatio/pull/1313) ([yivo](https://github.com/yivo))
- Handle race conditions when registering member + add useful logging for OmniAuth sequence. [\#1312](https://github.com/rubykube/peatio/pull/1312) ([yivo](https://github.com/yivo))
- Handle race conditions when registering member + add useful logging for OmniAuth sequence. [\#1310](https://github.com/rubykube/peatio/pull/1310) ([yivo](https://github.com/yivo))
- Prevent race conditions in withdraw worker + add rich logging. [\#1309](https://github.com/rubykube/peatio/pull/1309) ([yivo](https://github.com/yivo))
- Prevent race conditions in withdraw worker + add rich logging. [\#1308](https://github.com/rubykube/peatio/pull/1308) ([yivo](https://github.com/yivo))
- Prevent race conditions in withdraw worker + add rich logging. [\#1307](https://github.com/rubykube/peatio/pull/1307) ([yivo](https://github.com/yivo))
- Prevent race conditions in withdraw worker + add rich logging. [\#1306](https://github.com/rubykube/peatio/pull/1306) ([yivo](https://github.com/yivo))
- Fix Google auth error \(Error: invalid\_request\) which breaks local sign in for development [\#1305](https://github.com/rubykube/peatio/pull/1305) ([yivo](https://github.com/yivo))
- Fix Google auth error \(Error: invalid\_request\) which breaks local sign in for development [\#1304](https://github.com/rubykube/peatio/pull/1304) ([yivo](https://github.com/yivo))
- Fix Google auth error \(Error: invalid\_request\) which breaks local sign in for development [\#1302](https://github.com/rubykube/peatio/pull/1302) ([yivo](https://github.com/yivo))
- Fix Google auth error \(Error: invalid\_request\) which breaks local sign in for development [\#1301](https://github.com/rubykube/peatio/pull/1301) ([yivo](https://github.com/yivo))
- Fix Figaro warnings [\#1300](https://github.com/rubykube/peatio/pull/1300) ([yivo](https://github.com/yivo))
- Handle missing member & currency as validation errors preventing NoMethodError \(closes \#1272\) [\#1299](https://github.com/rubykube/peatio/pull/1299) ([yivo](https://github.com/yivo))
-  Handle missing Redis values in GET /api/v2/k \(fixes \#1281\) [\#1298](https://github.com/rubykube/peatio/pull/1298) ([yivo](https://github.com/yivo))
- Handle missing Redis values in GET /api/v2/k \(fixes \#1281\) [\#1297](https://github.com/rubykube/peatio/pull/1297) ([yivo](https://github.com/yivo))
- Handle missing Redis values in GET /api/v2/k \(fixes \#1281\) [\#1296](https://github.com/rubykube/peatio/pull/1296) ([yivo](https://github.com/yivo))
- Handle missing Redis values in GET /api/v2/k \(fixes \#1281\) [\#1295](https://github.com/rubykube/peatio/pull/1295) ([yivo](https://github.com/yivo))
- Fix Bunny errors which make WS API broken v1.5 \(closes \#1279\) [\#1294](https://github.com/rubykube/peatio/pull/1294) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fix Bunny errors which make WS API broken v1.6 \(closes \#1279\) [\#1293](https://github.com/rubykube/peatio/pull/1293) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.7.25](https://github.com/rubykube/peatio/tree/1.7.25) (2018-06-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.36...1.7.25)

## [1.8.36](https://github.com/rubykube/peatio/tree/1.8.36) (2018-06-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.35...1.8.36)

**Merged pull requests:**

- Fix Bunny errors which make WS API broken \(closes \#1279\) [\#1288](https://github.com/rubykube/peatio/pull/1288) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fix Bunny errors which make WS API broken \(closes \#1279\) [\#1283](https://github.com/rubykube/peatio/pull/1283) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.8.35](https://github.com/rubykube/peatio/tree/1.8.35) (2018-06-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.34...1.8.35)

**Closed issues:**

- Ability to add ERC20 token through peatio admin panel [\#1285](https://github.com/rubykube/peatio/issues/1285)

**Merged pull requests:**

- Add missing input for ERC20 contract address [\#1286](https://github.com/rubykube/peatio/pull/1286) ([yivo](https://github.com/yivo))
- Remove deprecated POST /api/v2/withdraws \(closes \#1178\) [\#1284](https://github.com/rubykube/peatio/pull/1284) ([yivo](https://github.com/yivo))

## [1.8.34](https://github.com/rubykube/peatio/tree/1.8.34) (2018-06-13)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.33...1.8.34)

**Closed issues:**

- Remove deprecated POST /api/v2/withdraws [\#1178](https://github.com/rubykube/peatio/issues/1178)

**Merged pull requests:**

- Ensure orders are put back to matching daemon order book \(fixes disappearing orders, fixes order cancelation problem, optimizes number of queries to markets\) [\#1245](https://github.com/rubykube/peatio/pull/1245) ([yivo](https://github.com/yivo))

## [1.8.33](https://github.com/rubykube/peatio/tree/1.8.33) (2018-06-13)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.32...1.8.33)

**Closed issues:**

- Add support to Stellar [\#1280](https://github.com/rubykube/peatio/issues/1280)
-  To Have Different Address Used For Ethereum and ERC20 Tokens Or Same Address? [\#1275](https://github.com/rubykube/peatio/issues/1275)
- Daemon status issue? [\#1274](https://github.com/rubykube/peatio/issues/1274)
- When I click on the command to run the server, is the error of the content of the picture the reason for the error of the environment variable? [\#1273](https://github.com/rubykube/peatio/issues/1273)
- v1.8 Management Create Withdraw API Error Messages [\#1239](https://github.com/rubykube/peatio/issues/1239)
- Too many SQL market requests, maybe move markets table into memory? [\#1199](https://github.com/rubykube/peatio/issues/1199)

**Merged pull requests:**

- Add documentation for Websocket API [\#1256](https://github.com/rubykube/peatio/pull/1256) ([shal](https://github.com/shal))

## [1.8.32](https://github.com/rubykube/peatio/tree/1.8.32) (2018-06-08)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.31...1.8.32)

**Merged pull requests:**

- Add support for Barong 1.8 dynamic levels \(closes \#1134\) [\#1222](https://github.com/rubykube/peatio/pull/1222) ([mitjok](https://github.com/mitjok))

## [1.8.31](https://github.com/rubykube/peatio/tree/1.8.31) (2018-06-08)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.25...1.8.31)

**Merged pull requests:**

- Cache JWT key \(don't initialize it at every request\) [\#1269](https://github.com/rubykube/peatio/pull/1269) ([yivo](https://github.com/yivo))
- Don't expose sensitive data from Faraday::Response\#describe \(closes \#1155\) [\#1263](https://github.com/rubykube/peatio/pull/1263) ([k1T4eR](https://github.com/k1T4eR))

## [1.6.25](https://github.com/rubykube/peatio/tree/1.6.25) (2018-06-08)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.24...1.6.25)

**Closed issues:**

- Trading page no UI [\#1268](https://github.com/rubykube/peatio/issues/1268)

## [1.7.24](https://github.com/rubykube/peatio/tree/1.7.24) (2018-06-07)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.30...1.7.24)

## [1.8.30](https://github.com/rubykube/peatio/tree/1.8.30) (2018-06-07)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.18...1.8.30)

## [1.5.18](https://github.com/rubykube/peatio/tree/1.5.18) (2018-06-07)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.29...1.5.18)

**Closed issues:**

- KeyError: key not found: "REDIS\_URL" [\#1267](https://github.com/rubykube/peatio/issues/1267)
- FalseClass, Fresh Install [\#1253](https://github.com/rubykube/peatio/issues/1253)
- GET /api/v2/trades always returns side value as null [\#1252](https://github.com/rubykube/peatio/issues/1252)
- How does gon.trades initialized? [\#1251](https://github.com/rubykube/peatio/issues/1251)
- COIN API Algo ETH [\#1250](https://github.com/rubykube/peatio/issues/1250)
- Deposit confirmations set to zero causes all deposits to be confirmed immediately  [\#1248](https://github.com/rubykube/peatio/issues/1248)
- Check if both currencies are enabled on market enabling [\#1242](https://github.com/rubykube/peatio/issues/1242)
- Deposit bug with ETH and ETC  [\#1240](https://github.com/rubykube/peatio/issues/1240)
- DB setup error:  Ask unit is not included in the list, Bid unit is not included in the list [\#1238](https://github.com/rubykube/peatio/issues/1238)
- New API method for getting currencies prices \(as well as volume and change\) for a specific currency [\#1234](https://github.com/rubykube/peatio/issues/1234)
- Too many repetitions and duplications on SQL statement in transaction for or trade executor [\#1198](https://github.com/rubykube/peatio/issues/1198)
- Sensitive data is sent from Faraday::Response\#describe [\#1155](https://github.com/rubykube/peatio/issues/1155)
- Support dynamic levels feature [\#1134](https://github.com/rubykube/peatio/issues/1134)
- Fresh install of Peatio does not have a string for market ID [\#1104](https://github.com/rubykube/peatio/issues/1104)
- Canceling orders at first try doesn't works [\#1036](https://github.com/rubykube/peatio/issues/1036)
- Peatio daemons reconnection failure on RabbitMQ Fail [\#1032](https://github.com/rubykube/peatio/issues/1032)
- Fully support field Market\#enabled [\#817](https://github.com/rubykube/peatio/issues/817)

**Merged pull requests:**

- Don't expose sensitive data from Faraday::Response\#describe \(closes \#1155\) [\#1266](https://github.com/rubykube/peatio/pull/1266) ([k1T4eR](https://github.com/k1T4eR))
- Don't expose sensitive data from Faraday::Response\#describe \(closes \#1155\) [\#1265](https://github.com/rubykube/peatio/pull/1265) ([k1T4eR](https://github.com/k1T4eR))
- Don't expose sensitive data from Faraday::Response\#describe \(closes \#1155\) [\#1264](https://github.com/rubykube/peatio/pull/1264) ([k1T4eR](https://github.com/k1T4eR))
- Expand db:setup command due to Rails bug \(closes \#1104\) [\#1262](https://github.com/rubykube/peatio/pull/1262) ([k1T4eR](https://github.com/k1T4eR))
- Expand db:setup command due to Rails bug \(closes \#1104\) [\#1261](https://github.com/rubykube/peatio/pull/1261) ([k1T4eR](https://github.com/k1T4eR))
- Expand db:setup command due to Rails bug \(closes \#1104\) [\#1260](https://github.com/rubykube/peatio/pull/1260) ([k1T4eR](https://github.com/k1T4eR))
- Expand db:setup command due to Rails bug \(closes \#1104\) [\#1259](https://github.com/rubykube/peatio/pull/1259) ([k1T4eR](https://github.com/k1T4eR))
- Don't accept deposits in case if deposit\_confirmations set to zero \(fixes \#1248\) [\#1258](https://github.com/rubykube/peatio/pull/1258) ([yivo](https://github.com/yivo))
- Don't accept deposits in case if deposit\_confirmations set to zero \(fixes \#1248\) [\#1257](https://github.com/rubykube/peatio/pull/1257) ([yivo](https://github.com/yivo))
- Check if both currencies are enabled on market enabling \(closes \#1242\) [\#1243](https://github.com/rubykube/peatio/pull/1243) ([ysv](https://github.com/ysv))

## [1.8.29](https://github.com/rubykube/peatio/tree/1.8.29) (2018-06-05)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.28...1.8.29)

**Closed issues:**

- Nokogiri error [\#1246](https://github.com/rubykube/peatio/issues/1246)
- Bring back legacy Peatio benchmark [\#1189](https://github.com/rubykube/peatio/issues/1189)

**Merged pull requests:**

- Add missing index for authentication which is important for API v2 performance \(closes \#1237\) [\#1244](https://github.com/rubykube/peatio/pull/1244) ([yivo](https://github.com/yivo))
- Fully support field Market\#enabled \(related to \#817\) [\#1229](https://github.com/rubykube/peatio/pull/1229) ([ysv](https://github.com/ysv))

## [1.8.28](https://github.com/rubykube/peatio/tree/1.8.28) (2018-06-05)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.23...1.8.28)

**Closed issues:**

- Index for table «authentications» on provider, member\_id & uid [\#1237](https://github.com/rubykube/peatio/issues/1237)
- Create liveness/readiness endpoints [\#1190](https://github.com/rubykube/peatio/issues/1190)

**Merged pull requests:**

- Add readiness & liveness probes [\#1197](https://github.com/rubykube/peatio/pull/1197) ([rxx](https://github.com/rxx))

## [1.7.23](https://github.com/rubykube/peatio/tree/1.7.23) (2018-06-04)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.27...1.7.23)

**Closed issues:**

- Where do fees collected on transactions go to in the exchange's wallet\(s\)?" [\#1235](https://github.com/rubykube/peatio/issues/1235)
- Version 1.7 Management API Cannot Cancel Withdraws [\#1232](https://github.com/rubykube/peatio/issues/1232)
- Multisig example that actually uses multiple signatures? [\#1225](https://github.com/rubykube/peatio/issues/1225)
- Currency\#enabled functionality should work in pair with Market\#enabled [\#1109](https://github.com/rubykube/peatio/issues/1109)

**Merged pull requests:**

- Fix management API withdraw cancelation bug in 1.7 \(closes \#1232\) [\#1236](https://github.com/rubykube/peatio/pull/1236) ([ritesh-skyach](https://github.com/ritesh-skyach))

## [1.8.27](https://github.com/rubykube/peatio/tree/1.8.27) (2018-06-01)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.22...1.8.27)

**Closed issues:**

- eth address wallet created but dont see deposit [\#1231](https://github.com/rubykube/peatio/issues/1231)
- Profit fee where going? [\#1230](https://github.com/rubykube/peatio/issues/1230)

**Merged pull requests:**

- Disable linked markets when currency is disabled \(closes \#1109\). [\#1233](https://github.com/rubykube/peatio/pull/1233) ([yivo](https://github.com/yivo))

## [1.7.22](https://github.com/rubykube/peatio/tree/1.7.22) (2018-05-31)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.26...1.7.22)

## [1.8.26](https://github.com/rubykube/peatio/tree/1.8.26) (2018-05-31)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.24...1.8.26)

## [1.6.24](https://github.com/rubykube/peatio/tree/1.6.24) (2018-05-31)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.17...1.6.24)

## [1.5.17](https://github.com/rubykube/peatio/tree/1.5.17) (2018-05-31)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.21...1.5.17)

**Closed issues:**

- Wrong customer ID or password,please try again. [\#1223](https://github.com/rubykube/peatio/issues/1223)
- Parameter «price» in in API v2 in order creation API should not be mandatory \(market orders\) [\#1213](https://github.com/rubykube/peatio/issues/1213)
- ManagementAPIv1::Entities::Withdraw,Deposit expose :uid code is buggy [\#1204](https://github.com/rubykube/peatio/issues/1204)

**Merged pull requests:**

- Use Member\#uid instead of authentications.barong.first.uid \(closes \#1204\)  [\#1228](https://github.com/rubykube/peatio/pull/1228) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Use Member\#uid instead of authentications.barong.first.uid \(closes \#1204\)  [\#1227](https://github.com/rubykube/peatio/pull/1227) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Make parameter «price» in API v2 order creation to be not mandatory \(fixes \#1213\) [\#1226](https://github.com/rubykube/peatio/pull/1226) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Make parameter «price» in API v2 order creation to be not mandatory \(fixes \#1213\) [\#1224](https://github.com/rubykube/peatio/pull/1224) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Replace Currency\#id with Currency\#code to reduce number of queries [\#1214](https://github.com/rubykube/peatio/pull/1214) ([yivo](https://github.com/yivo))

## [1.7.21](https://github.com/rubykube/peatio/tree/1.7.21) (2018-05-30)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.25...1.7.21)

## [1.8.25](https://github.com/rubykube/peatio/tree/1.8.25) (2018-05-30)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.24...1.8.25)

**Closed issues:**

- Can not logout and change a user [\#1219](https://github.com/rubykube/peatio/issues/1219)
- BTC Address not being generated [\#1218](https://github.com/rubykube/peatio/issues/1218)
- Rabbitmq communication with BTC node on separate server [\#1217](https://github.com/rubykube/peatio/issues/1217)
- Replacing Currency\#id with Currency\#code can greatly reduce number of SQL to currencies table  [\#1196](https://github.com/rubykube/peatio/issues/1196)
- Get rid of «Scoped order and limit are ignored, it’s forced to be batch order and batch size» in logs [\#1115](https://github.com/rubykube/peatio/issues/1115)

**Merged pull requests:**

- Make parameter «price» in API v2 order creation to be not mandatory \(fixes \#1213\) [\#1221](https://github.com/rubykube/peatio/pull/1221) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Make parameter «price» in API v2 order creation to be not mandatory \(fixes \#1213\) [\#1220](https://github.com/rubykube/peatio/pull/1220) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Member use uid instead of authentications.barong.first.uid \(closes \#1204\) [\#1216](https://github.com/rubykube/peatio/pull/1216) ([ysv](https://github.com/ysv))
- Use scope ordered instead of default\_scope for Markets \(closes \#1115\) [\#1215](https://github.com/rubykube/peatio/pull/1215) ([ysv](https://github.com/ysv))
- Bring back legacy Peatio benchmarks \(closes \#1189\) [\#1202](https://github.com/rubykube/peatio/pull/1202) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Remove ALL N+1 queries \(closes \#1186\) [\#1193](https://github.com/rubykube/peatio/pull/1193) ([ysv](https://github.com/ysv))

## [1.8.24](https://github.com/rubykube/peatio/tree/1.8.24) (2018-05-29)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.23...1.8.24)

**Closed issues:**

- Installation completed with all coins [\#1211](https://github.com/rubykube/peatio/issues/1211)
- Why the redirect url was still 127.0.0.1:3000? [\#1210](https://github.com/rubykube/peatio/issues/1210)
- Changing market list dropdown menu to horizontal [\#1209](https://github.com/rubykube/peatio/issues/1209)
- Installation done, require help for some service [\#1208](https://github.com/rubykube/peatio/issues/1208)
- Add Support Tradingview Chart [\#1207](https://github.com/rubykube/peatio/issues/1207)
- Add Support Referral System [\#1206](https://github.com/rubykube/peatio/issues/1206)
- DRY up Worker::DepositCoinAddress [\#1133](https://github.com/rubykube/peatio/issues/1133)
- TypeError: no implicit conversion of nil into Array in CoinAPI::BitGo [\#1116](https://github.com/rubykube/peatio/issues/1116)
- Changing market precision, while trading is going, can block creation of new orders that should match to the old once [\#1106](https://github.com/rubykube/peatio/issues/1106)
- not able to withdraw and deposit ETH. but successfully generated new ETH address.  [\#1056](https://github.com/rubykube/peatio/issues/1056)
- Upgrading Rails and all the other gems [\#20](https://github.com/rubykube/peatio/issues/20)

**Merged pull requests:**

- Remove calls to Pusher, AMQP and other out from DB transactions. Refactor all Pusher\#trigger\_async calls! \(closes \#1188\). [\#1195](https://github.com/rubykube/peatio/pull/1195) ([yivo](https://github.com/yivo))

## [1.8.23](https://github.com/rubykube/peatio/tree/1.8.23) (2018-05-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.22...1.8.23)

**Closed issues:**

- Analyze Scout and add missing DB indexes [\#1192](https://github.com/rubykube/peatio/issues/1192)
- Remove calls to Pusher, AMQP and other out from DB transactions [\#1188](https://github.com/rubykube/peatio/issues/1188)
- Remove ALL N+1 queries. USE includes, eager\_loads, joins where it is needed. And use bullet gem \(installed\) [\#1186](https://github.com/rubykube/peatio/issues/1186)
- Excessive call to localtime form daemons [\#1184](https://github.com/rubykube/peatio/issues/1184)
- Remove Pusher calls which are used for old UI [\#1153](https://github.com/rubykube/peatio/issues/1153)

**Merged pull requests:**

- Added the TZ variable to Dockerfile [\#1205](https://github.com/rubykube/peatio/pull/1205) ([vshatravenko](https://github.com/vshatravenko))

## [1.8.22](https://github.com/rubykube/peatio/tree/1.8.22) (2018-05-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.21...1.8.22)

**Closed issues:**

- Documentation Update: Trading UI [\#1201](https://github.com/rubykube/peatio/issues/1201)
- Currency Deposit Address Not Displaying [\#1182](https://github.com/rubykube/peatio/issues/1182)
- Saving service credentials in Peatio Admin [\#1034](https://github.com/rubykube/peatio/issues/1034)

**Merged pull requests:**

- Protect sensitive information in admin panel \(closes \#1034\) [\#1203](https://github.com/rubykube/peatio/pull/1203) ([yivo](https://github.com/yivo))

## [1.8.21](https://github.com/rubykube/peatio/tree/1.8.21) (2018-05-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.20...1.8.21)

**Merged pull requests:**

- Remove some extra queries when creating order. Improve indexes. [\#1200](https://github.com/rubykube/peatio/pull/1200) ([yivo](https://github.com/yivo))

## [1.8.20](https://github.com/rubykube/peatio/tree/1.8.20) (2018-05-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.19...1.8.20)

**Merged pull requests:**

- Add support for Currency\#enabled \(aka \#visible, closes \#818\) [\#855](https://github.com/rubykube/peatio/pull/855) ([shal](https://github.com/shal))

## [1.8.19](https://github.com/rubykube/peatio/tree/1.8.19) (2018-05-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.18...1.8.19)

**Closed issues:**

- Add Scout monitoring \(scoutapp.com\) [\#1187](https://github.com/rubykube/peatio/issues/1187)

**Merged pull requests:**

- Add Scout APM [\#1191](https://github.com/rubykube/peatio/pull/1191) ([yivo](https://github.com/yivo))

## [1.8.18](https://github.com/rubykube/peatio/tree/1.8.18) (2018-05-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.17...1.8.18)

**Merged pull requests:**

- Revert "Add PUSHER\_CLUSTER" [\#1185](https://github.com/rubykube/peatio/pull/1185) ([mod](https://github.com/mod))

## [1.8.17](https://github.com/rubykube/peatio/tree/1.8.17) (2018-05-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.20...1.8.17)

**Closed issues:**

- Support field Currency\#visible [\#818](https://github.com/rubykube/peatio/issues/818)

**Merged pull requests:**

- Add PUSHER\_CLUSTER [\#1183](https://github.com/rubykube/peatio/pull/1183) ([gpeng](https://github.com/gpeng))

## [1.7.20](https://github.com/rubykube/peatio/tree/1.7.20) (2018-05-23)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.16...1.7.20)

## [1.8.16](https://github.com/rubykube/peatio/tree/1.8.16) (2018-05-23)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.15...1.8.16)

**Merged pull requests:**

- Make checkboxes work in admin panel \(fixes \#1158\). [\#1180](https://github.com/rubykube/peatio/pull/1180) ([yivo](https://github.com/yivo))
- Make checkboxes work in admin panel \(fixes \#1158\). [\#1179](https://github.com/rubykube/peatio/pull/1179) ([yivo](https://github.com/yivo))

## [1.8.15](https://github.com/rubykube/peatio/tree/1.8.15) (2018-05-23)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.14...1.8.15)

**Closed issues:**

- Btc Private keys does not stored in Database and test btc Blances not confirmed [\#1177](https://github.com/rubykube/peatio/issues/1177)
- Bitcon address not visible [\#1176](https://github.com/rubykube/peatio/issues/1176)
- JWT Authenticated endpoint for Pusher / Slanger API Private channel subscription [\#1175](https://github.com/rubykube/peatio/issues/1175)
- Checkboxes don't work correctly  in admin panel \(unable to unset value\) [\#1158](https://github.com/rubykube/peatio/issues/1158)

**Merged pull requests:**

- Add POST /api/v2/pusher/auth [\#1181](https://github.com/rubykube/peatio/pull/1181) ([yivo](https://github.com/yivo))
- Remove AccountVersion [\#1174](https://github.com/rubykube/peatio/pull/1174) ([yivo](https://github.com/yivo))

## [1.8.14](https://github.com/rubykube/peatio/tree/1.8.14) (2018-05-22)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.19...1.8.14)

## [1.7.19](https://github.com/rubykube/peatio/tree/1.7.19) (2018-05-22)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.16...1.7.19)

## [1.5.16](https://github.com/rubykube/peatio/tree/1.5.16) (2018-05-22)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.23...1.5.16)

**Merged pull requests:**

- Output «reason» for API v2 exceptions & «debug\_message» for Management API v1 exceptions \(closes \#1156\). [\#1161](https://github.com/rubykube/peatio/pull/1161) ([yivo](https://github.com/yivo))
- Enqueue address generation if address is blank in GET /api/v2/deposit\_address \(issue \#1157\). [\#1159](https://github.com/rubykube/peatio/pull/1159) ([yivo](https://github.com/yivo))
- Validate new Bitcoin Cash CashAddr format and prevent errors like «Could not determine address version» \(fixes \#1151\). [\#1154](https://github.com/rubykube/peatio/pull/1154) ([yivo](https://github.com/yivo))

## [1.6.23](https://github.com/rubykube/peatio/tree/1.6.23) (2018-05-22)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.13...1.6.23)

**Closed issues:**

- BTC wallet activation  [\#1173](https://github.com/rubykube/peatio/issues/1173)
- We need to enable order with type 'market' [\#1168](https://github.com/rubykube/peatio/issues/1168)
- Trade page is broken under high load [\#1165](https://github.com/rubykube/peatio/issues/1165)
- GET /api/v2/deposit\_address doesn't enqueue address generation if address is blank [\#1157](https://github.com/rubykube/peatio/issues/1157)
- report\_exception doesn't output «reason» for API v2 exceptions, and debug\_message for Management API v1 exceptions [\#1156](https://github.com/rubykube/peatio/issues/1156)
- Withdraw and Member update message always has empty attributes in payload  [\#1152](https://github.com/rubykube/peatio/issues/1152)
- If I input invalid address for BCH withdraw the system will fails with «Error on withdraw audit: Could not determine address version» [\#1151](https://github.com/rubykube/peatio/issues/1151)
- Replace account versions and balance calculations to queries to deposit / withdraw / order / trade + use paper\_trail [\#1111](https://github.com/rubykube/peatio/issues/1111)

**Merged pull requests:**

- Add missing order type \(fixes \#1168\). [\#1172](https://github.com/rubykube/peatio/pull/1172) ([yivo](https://github.com/yivo))
- Add missing order type \(fixes \#1168\). [\#1171](https://github.com/rubykube/peatio/pull/1171) ([yivo](https://github.com/yivo))
- Add missing order type \(fixes \#1168\). [\#1170](https://github.com/rubykube/peatio/pull/1170) ([yivo](https://github.com/yivo))
- Add missing order type \(fixes \#1168\). [\#1169](https://github.com/rubykube/peatio/pull/1169) ([yivo](https://github.com/yivo))
- Output «reason» for API v2 exceptions \(closes \#1156\). [\#1167](https://github.com/rubykube/peatio/pull/1167) ([yivo](https://github.com/yivo))
- Output «reason» for API v2 exceptions & «debug\_message» for Management API v1 exceptions \(closes \#1156\). [\#1166](https://github.com/rubykube/peatio/pull/1166) ([yivo](https://github.com/yivo))
- Enqueue address generation if address is blank in GET /api/v2/deposit\_address \(issue \#1157\). [\#1164](https://github.com/rubykube/peatio/pull/1164) ([yivo](https://github.com/yivo))
- Enqueue address generation if address is blank in GET /api/v2/deposit\_address \(issue \#1157\). [\#1163](https://github.com/rubykube/peatio/pull/1163) ([yivo](https://github.com/yivo))
- Enqueue address generation if address is blank in GET /api/v2/deposit\_address \(issue \#1157\). [\#1162](https://github.com/rubykube/peatio/pull/1162) ([yivo](https://github.com/yivo))
- Output «reason» for API v2 exceptions & «debug\_message» for Management API v1 exceptions \(closes \#1156\). [\#1160](https://github.com/rubykube/peatio/pull/1160) ([yivo](https://github.com/yivo))

## [1.8.13](https://github.com/rubykube/peatio/tree/1.8.13) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.18...1.8.13)

**Merged pull requests:**

- Improve models: add missing indexes, improve validations, extract some parts to modules, remove some legacy code, improve structure of files in app/models \(fixes issues \#1107 \#1108\). [\#1110](https://github.com/rubykube/peatio/pull/1110) ([yivo](https://github.com/yivo))

## [1.7.18](https://github.com/rubykube/peatio/tree/1.7.18) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.12...1.7.18)

## [1.8.12](https://github.com/rubykube/peatio/tree/1.8.12) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.22...1.8.12)

## [1.6.22](https://github.com/rubykube/peatio/tree/1.6.22) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.15...1.6.22)

## [1.5.15](https://github.com/rubykube/peatio/tree/1.5.15) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.21...1.5.15)

**Closed issues:**

- GET /api/v2/deposit\_address?currency=FIAT returns null for fiats, should return error [\#1135](https://github.com/rubykube/peatio/issues/1135)
- XRP addresses with destination tag are not treated like valid [\#1125](https://github.com/rubykube/peatio/issues/1125)
- Ignore errors when generating deposit address \(prevent working nodes from being skipped\) [\#1119](https://github.com/rubykube/peatio/issues/1119)
- NoMethodError: undefined method `\[\]=' for nil:NilClass in Worker::MarketTicker line 26 [\#1118](https://github.com/rubykube/peatio/issues/1118)
- Don't expose sensitive data in /api/v2/deposit\_address?currency=btc [\#1117](https://github.com/rubykube/peatio/issues/1117)
- Peatio doesn't include CORS headers when returning an error [\#1113](https://github.com/rubykube/peatio/issues/1113)
- Add missing indexes like Member\#email UNIQ [\#1108](https://github.com/rubykube/peatio/issues/1108)
- Quicky improve validations at important models [\#1107](https://github.com/rubykube/peatio/issues/1107)
- Ripple: Failed to submit event: CoinAPI::Error: "txnNotFound" [\#835](https://github.com/rubykube/peatio/issues/835)

**Merged pull requests:**

- Send CORS headers from API v2 ever on error \(closes \#1113\). [\#1150](https://github.com/rubykube/peatio/pull/1150) ([yivo](https://github.com/yivo))
- Send CORS headers from API v2 ever on error \(closes \#1113\). [\#1149](https://github.com/rubykube/peatio/pull/1149) ([yivo](https://github.com/yivo))
- Send CORS headers from API v2 ever on error \(closes \#1113\). [\#1148](https://github.com/rubykube/peatio/pull/1148) ([yivo](https://github.com/yivo))
- Send CORS headers from API v2 ever on error  [\#1146](https://github.com/rubykube/peatio/pull/1146) ([yivo](https://github.com/yivo))

## [1.6.21](https://github.com/rubykube/peatio/tree/1.6.21) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.11...1.6.21)

## [1.8.11](https://github.com/rubykube/peatio/tree/1.8.11) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.17...1.8.11)

## [1.7.17](https://github.com/rubykube/peatio/tree/1.7.17) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.14...1.7.17)

## [1.5.14](https://github.com/rubykube/peatio/tree/1.5.14) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.13...1.5.14)

**Merged pull requests:**

- Return 422 for fiats when calling GET /api/v2/deposit\_address?currency=FIAT \(closes \#1135\). [\#1144](https://github.com/rubykube/peatio/pull/1144) ([yivo](https://github.com/yivo))
- Ignore errors when generating deposit address \(prevent working nodes from being skipped, fixes \#1119\). [\#1143](https://github.com/rubykube/peatio/pull/1143) ([yivo](https://github.com/yivo))
- Ignore errors when generating deposit address \(prevent working nodes from being skipped, fixes \#1119\). [\#1142](https://github.com/rubykube/peatio/pull/1142) ([yivo](https://github.com/yivo))
- Ignore errors when generating deposit address \(prevent working nodes from being skipped, fixes \#1119\). [\#1141](https://github.com/rubykube/peatio/pull/1141) ([yivo](https://github.com/yivo))
- Ignore errors when generating deposit address \(prevent working nodes from being skipped, fixes \#1119\). [\#1140](https://github.com/rubykube/peatio/pull/1140) ([yivo](https://github.com/yivo))
- Add correct validation for XRP addresses with destination tags \(fixes \#1125\). [\#1139](https://github.com/rubykube/peatio/pull/1139) ([yivo](https://github.com/yivo))
- Add correct validation for XRP addresses with destination tags \(fixes \#1125\). [\#1138](https://github.com/rubykube/peatio/pull/1138) ([yivo](https://github.com/yivo))
- Add correct validation for XRP addresses with destination tags \(fixes \#1125\). [\#1137](https://github.com/rubykube/peatio/pull/1137) ([yivo](https://github.com/yivo))
- Add correct validation for XRP addresses with destination tags \(fixes \#1125\). [\#1136](https://github.com/rubykube/peatio/pull/1136) ([yivo](https://github.com/yivo))
- Don't expose sensitive data in /api/v2/deposit\_address?currency=btc [\#1129](https://github.com/rubykube/peatio/pull/1129) ([yivo](https://github.com/yivo))

## [1.5.13](https://github.com/rubykube/peatio/tree/1.5.13) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.10...1.5.13)

**Merged pull requests:**

- Don't expose sensitive data in /api/v2/deposit\_address?currency=btc [\#1128](https://github.com/rubykube/peatio/pull/1128) ([yivo](https://github.com/yivo))
- Don't expose sensitive data in /api/v2/deposit\_address?currency=btc [\#1126](https://github.com/rubykube/peatio/pull/1126) ([yivo](https://github.com/yivo))

## [1.8.10](https://github.com/rubykube/peatio/tree/1.8.10) (2018-05-21)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.9...1.8.10)

**Closed issues:**

- Deposit update message always has empty attributes in payload [\#1132](https://github.com/rubykube/peatio/issues/1132)
- google sign problem [\#1131](https://github.com/rubykube/peatio/issues/1131)
- websocket [\#1124](https://github.com/rubykube/peatio/issues/1124)
- Request instsallation with good and seriuos dev [\#1123](https://github.com/rubykube/peatio/issues/1123)
- CoinAPI::BTC generating invalid bitcoin addresses [\#1122](https://github.com/rubykube/peatio/issues/1122)
- 1.8-stable Google signin error [\#1121](https://github.com/rubykube/peatio/issues/1121)
- 1.8-stable Google signin error [\#1120](https://github.com/rubykube/peatio/issues/1120)
- gem 'digest-sha3' conflict with ubuntu 16.04 [\#1114](https://github.com/rubykube/peatio/issues/1114)

**Merged pull requests:**

- Fix «NoMethodError: undefined method `\[\]=' for nil:NilClass in Worker::MarketTicker line 26» \(closes \#1118\). [\#1130](https://github.com/rubykube/peatio/pull/1130) ([yivo](https://github.com/yivo))
- Don't expose sensitive data in /api/v2/deposit\_address?currency=btc [\#1127](https://github.com/rubykube/peatio/pull/1127) ([yivo](https://github.com/yivo))

## [1.8.9](https://github.com/rubykube/peatio/tree/1.8.9) (2018-05-16)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.8...1.8.9)

**Merged pull requests:**

- Remove check on SENTRY\_ENV [\#1105](https://github.com/rubykube/peatio/pull/1105) ([gpeng](https://github.com/gpeng))

## [1.8.8](https://github.com/rubykube/peatio/tree/1.8.8) (2018-05-15)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.7...1.8.8)

**Closed issues:**

- Specs for CoinAPI::BCH [\#1046](https://github.com/rubykube/peatio/issues/1046)
- Specs for CoinAPI::BTC [\#970](https://github.com/rubykube/peatio/issues/970)

**Merged pull requests:**

- Drop config/initializers/abstract\_mysql2\_adapter.rb [\#1102](https://github.com/rubykube/peatio/pull/1102) ([yivo](https://github.com/yivo))
- Add magic annotation \(encoding + frozen\_string\_literal\) to each Ruby script. [\#1101](https://github.com/rubykube/peatio/pull/1101) ([yivo](https://github.com/yivo))
- Specs for CoinAPI::BCH \(closes \#1046\) [\#1100](https://github.com/rubykube/peatio/pull/1100) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Specs for CoinAPI::BTC \(closes \#970\) [\#1093](https://github.com/rubykube/peatio/pull/1093) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Update documentation \(issue \#325\) [\#1062](https://github.com/rubykube/peatio/pull/1062) ([rahul-ranchal](https://github.com/rahul-ranchal))

## [1.8.7](https://github.com/rubykube/peatio/tree/1.8.7) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.4.1...1.8.7)

**Closed issues:**

- Withdraw all bug with low coin amount, 0.0000000000000001 [\#1050](https://github.com/rubykube/peatio/issues/1050)

**Merged pull requests:**

- Fix withdraw bug with low coin amount \(issue \#1050\). [\#1099](https://github.com/rubykube/peatio/pull/1099) ([yivo](https://github.com/yivo))

## [1.4.1](https://github.com/rubykube/peatio/tree/1.4.1) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.6...1.4.1)

## [1.8.6](https://github.com/rubykube/peatio/tree/1.8.6) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.5...1.8.6)

**Closed issues:**

- Switch to slanger by default [\#830](https://github.com/rubykube/peatio/issues/830)
- Develop library for publishing / consuming events using AMQP [\#759](https://github.com/rubykube/peatio/issues/759)

**Merged pull requests:**

- Huge cleanup from legacy stuff [\#1090](https://github.com/rubykube/peatio/pull/1090) ([yivo](https://github.com/yivo))

## [1.8.5](https://github.com/rubykube/peatio/tree/1.8.5) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.16...1.8.5)

## [1.7.16](https://github.com/rubykube/peatio/tree/1.7.16) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.3.1...1.7.16)

**Closed issues:**

- \#\<NoMethodError: undefined method `iso8601' for nil:NilClass\> [\#1096](https://github.com/rubykube/peatio/issues/1096)
- How to make withdraw in case the ether amount is bigger than charged corresponding address [\#1020](https://github.com/rubykube/peatio/issues/1020)

**Merged pull requests:**

- Fix «NoMethodError: undefined method `iso8601' for nil:NilClass» \(closes \#1096\). [\#1098](https://github.com/rubykube/peatio/pull/1098) ([yivo](https://github.com/yivo))
- Fix «NoMethodError: undefined method `iso8601' for nil:NilClass» \(closes \#1096\). [\#1097](https://github.com/rubykube/peatio/pull/1097) ([yivo](https://github.com/yivo))

## [1.3.1](https://github.com/rubykube/peatio/tree/1.3.1) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.15...1.3.1)

## [1.7.15](https://github.com/rubykube/peatio/tree/1.7.15) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.12...1.7.15)

**Merged pull requests:**

- Ability to configure log level via environment variable LOG\_LEVEL \(closes \#1079\). [\#1095](https://github.com/rubykube/peatio/pull/1095) ([yivo](https://github.com/yivo))
- Ability to configure log level via environment variable LOG\_LEVEL \(closes \#1079\). [\#1094](https://github.com/rubykube/peatio/pull/1094) ([yivo](https://github.com/yivo))

## [1.5.12](https://github.com/rubykube/peatio/tree/1.5.12) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.4...1.5.12)

## [1.8.4](https://github.com/rubykube/peatio/tree/1.8.4) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.20...1.8.4)

## [1.6.20](https://github.com/rubykube/peatio/tree/1.6.20) (2018-05-14)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.14...1.6.20)

**Closed issues:**

- Ability for User to Generate API Key \(removed?\) [\#1091](https://github.com/rubykube/peatio/issues/1091)
- Ability to set log level [\#1079](https://github.com/rubykube/peatio/issues/1079)
- Remove ugly member statistics from Peatio [\#938](https://github.com/rubykube/peatio/issues/938)
- Remove lib/tasks/emu.rake [\#232](https://github.com/rubykube/peatio/issues/232)
- Remove benchmarks [\#231](https://github.com/rubykube/peatio/issues/231)
- Remove unneeded gems [\#19](https://github.com/rubykube/peatio/issues/19)

**Merged pull requests:**

- Use existing Rails logger with preconfigured level, log device etc \(don't create new\) [\#1089](https://github.com/rubykube/peatio/pull/1089) ([yivo](https://github.com/yivo))
- Update ci/bump.rb: add logging, add pagination for GitHub API \(fixes bumping for older branches\). [\#1086](https://github.com/rubykube/peatio/pull/1086) ([yivo](https://github.com/yivo))
- Update ci/bump.rb: add logging, add pagination for GitHub API \(fixes bumping for older branches\). [\#1085](https://github.com/rubykube/peatio/pull/1085) ([yivo](https://github.com/yivo))
- Update ci/bump.rb: add logging, add pagination for GitHub API \(fixes bumping for older branches\). [\#1084](https://github.com/rubykube/peatio/pull/1084) ([yivo](https://github.com/yivo))
- Ability to configure log level via environment variable LOG\_LEVEL \(closes \#1079\). [\#1083](https://github.com/rubykube/peatio/pull/1083) ([yivo](https://github.com/yivo))
- Ability to configure log level via environment variable LOG\_LEVEL \(closes \#1079\). [\#1082](https://github.com/rubykube/peatio/pull/1082) ([yivo](https://github.com/yivo))
- Ability to configure log level via environment variable LOG\_LEVEL \(closes \#1079\). [\#1080](https://github.com/rubykube/peatio/pull/1080) ([yivo](https://github.com/yivo))

## [1.7.14](https://github.com/rubykube/peatio/tree/1.7.14) (2018-05-11)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.11...1.7.14)

**Merged pull requests:**

- Ability to configure log level via environment variable LOG\_LEVEL \(closes \#1079\). [\#1081](https://github.com/rubykube/peatio/pull/1081) ([yivo](https://github.com/yivo))

## [1.5.11](https://github.com/rubykube/peatio/tree/1.5.11) (2018-05-11)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.13...1.5.11)

**Closed issues:**

- API - Orders, when there are insufficient funds in the wallet, a wrong error message appears [\#1078](https://github.com/rubykube/peatio/issues/1078)
- Peatio daemons container size goes above 300gb [\#1076](https://github.com/rubykube/peatio/issues/1076)

## [1.7.13](https://github.com/rubykube/peatio/tree/1.7.13) (2018-05-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.19...1.7.13)

## [1.6.19](https://github.com/rubykube/peatio/tree/1.6.19) (2018-05-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.18...1.6.19)

**Closed issues:**

- Backport \#1055 to 1.5, 1.6, 1.7 [\#1069](https://github.com/rubykube/peatio/issues/1069)
- Backport \#1066 to 1.5, 1.6, 1.7 [\#1067](https://github.com/rubykube/peatio/issues/1067)

**Merged pull requests:**

- Fix trade executor errors [\#1075](https://github.com/rubykube/peatio/pull/1075) ([yivo](https://github.com/yivo))
- Disable unsupported order type and don't expose internal exceptions to outer world \(fixes \#1051\). [\#1074](https://github.com/rubykube/peatio/pull/1074) ([yivo](https://github.com/yivo))
- Disable unsupported order type and don't expose internal exceptions to outer world \(fixes \#1051\). [\#1073](https://github.com/rubykube/peatio/pull/1073) ([yivo](https://github.com/yivo))
- Disable unsupported order type and don't expose internal exceptions to outer world \(fixes \#1051\). [\#1072](https://github.com/rubykube/peatio/pull/1072) ([yivo](https://github.com/yivo))

## [1.6.18](https://github.com/rubykube/peatio/tree/1.6.18) (2018-05-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.3...1.6.18)

## [1.8.3](https://github.com/rubykube/peatio/tree/1.8.3) (2018-05-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.12...1.8.3)

**Merged pull requests:**

- Fix trade execution errors [\#1071](https://github.com/rubykube/peatio/pull/1071) ([yivo](https://github.com/yivo))
- Add market events to Event API [\#1053](https://github.com/rubykube/peatio/pull/1053) ([yivo](https://github.com/yivo))

## [1.7.12](https://github.com/rubykube/peatio/tree/1.7.12) (2018-05-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.11...1.7.12)

**Closed issues:**

- API- when there are missing params in a request, the error needs to be generic and accurate [\#1051](https://github.com/rubykube/peatio/issues/1051)

**Merged pull requests:**

- Fix trade execution errors [\#1070](https://github.com/rubykube/peatio/pull/1070) ([yivo](https://github.com/yivo))

## [1.7.11](https://github.com/rubykube/peatio/tree/1.7.11) (2018-05-09)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.17...1.7.11)

## [1.6.17](https://github.com/rubykube/peatio/tree/1.6.17) (2018-05-09)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.2...1.6.17)

## [1.8.2](https://github.com/rubykube/peatio/tree/1.8.2) (2018-05-09)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.1...1.8.2)

**Closed issues:**

- No accounts are being created after adding new currency [\#1059](https://github.com/rubykube/peatio/issues/1059)
- There are no case\_sensitive & erc20\_contract\_address in currency rubric of admin panel [\#1058](https://github.com/rubykube/peatio/issues/1058)
- API - trades, when getting trades list, side is null [\#1052](https://github.com/rubykube/peatio/issues/1052)
- Trade execution error [\#1047](https://github.com/rubykube/peatio/issues/1047)
- Trade Screen not working properly [\#1045](https://github.com/rubykube/peatio/issues/1045)
- Sendmany Bitcoin transaction is ignored by coins.rb daemon in case it contains recipient address which doesn't belong to Peatio [\#1040](https://github.com/rubykube/peatio/issues/1040)
- trade\_executor daemon crashes  [\#1035](https://github.com/rubykube/peatio/issues/1035)
- Implement event «market.btcusd.new\_order» [\#996](https://github.com/rubykube/peatio/issues/996)
- Update documentation [\#325](https://github.com/rubykube/peatio/issues/325)

**Merged pull requests:**

- Disable unsupported order type and don't expose internal exceptions to outer world \(fixes \#1051\). [\#1066](https://github.com/rubykube/peatio/pull/1066) ([yivo](https://github.com/yivo))
- Touch accounts after creating new currency \(fixes \#1059\) [\#1065](https://github.com/rubykube/peatio/pull/1065) ([yivo](https://github.com/yivo))
- Touch accounts after creating new currency \(fixes \#1059\) [\#1064](https://github.com/rubykube/peatio/pull/1064) ([yivo](https://github.com/yivo))
- Touch accounts after creating new currency \(fixes \#1059\) [\#1063](https://github.com/rubykube/peatio/pull/1063) ([yivo](https://github.com/yivo))
- Add case\_sensitive & erc20\_contract\_address to currency rubric in admin panel [\#1061](https://github.com/rubykube/peatio/pull/1061) ([yivo](https://github.com/yivo))
- Touch accounts after creating new currency [\#1060](https://github.com/rubykube/peatio/pull/1060) ([yivo](https://github.com/yivo))

## [1.8.1](https://github.com/rubykube/peatio/tree/1.8.1) (2018-05-09)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.8.0...1.8.1)

**Closed issues:**

- Trade CryptoCurrency [\#1054](https://github.com/rubykube/peatio/issues/1054)
- Manage Withdraw option not available [\#1044](https://github.com/rubykube/peatio/issues/1044)
- eth and erc20 payment address problem [\#1043](https://github.com/rubykube/peatio/issues/1043)
- bundle install error: gem install ffi -v '1.9.23 ERROR [\#1042](https://github.com/rubykube/peatio/issues/1042)
- Can not cancel orders. [\#1029](https://github.com/rubykube/peatio/issues/1029)
- The code which looks for new transactions \(lib/daemons/coins.rb\) is very ineffective and buggy [\#805](https://github.com/rubykube/peatio/issues/805)

**Merged pull requests:**

- Don't upcase TID \(keep it as is\) [\#1057](https://github.com/rubykube/peatio/pull/1057) ([yivo](https://github.com/yivo))
- Fix trade execution errors [\#1055](https://github.com/rubykube/peatio/pull/1055) ([yivo](https://github.com/yivo))
- Support sendmany Bitcoin transaction which contain recipient address not belonging to Peatio \(fixes \#1040\). [\#1049](https://github.com/rubykube/peatio/pull/1049) ([yivo](https://github.com/yivo))

## [1.8.0](https://github.com/rubykube/peatio/tree/1.8.0) (2018-05-04)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.16...1.8.0)

**Closed issues:**

- add currency [\#1039](https://github.com/rubykube/peatio/issues/1039)
- trading page 404, why close issues? same problem [\#1030](https://github.com/rubykube/peatio/issues/1030)
- Need a possibility to understand,  through api, if fiat is present in current deployment [\#1021](https://github.com/rubykube/peatio/issues/1021)

**Merged pull requests:**

- Replace state to action in withdraws \(Management API v1\) [\#1037](https://github.com/rubykube/peatio/pull/1037) ([yivo](https://github.com/yivo))
- Proposal for API to expose for account balance. [\#1033](https://github.com/rubykube/peatio/pull/1033) ([CallumD](https://github.com/CallumD))
- Tweak lib/daemons/coins.rb for stability [\#1028](https://github.com/rubykube/peatio/pull/1028) ([yivo](https://github.com/yivo))
- Release Peatio 1.8.0 [\#1026](https://github.com/rubykube/peatio/pull/1026) ([yivo](https://github.com/yivo))

## [1.6.16](https://github.com/rubykube/peatio/tree/1.6.16) (2018-05-02)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.10...1.6.16)

## [1.7.10](https://github.com/rubykube/peatio/tree/1.7.10) (2018-05-02)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.15...1.7.10)

**Closed issues:**

- Setup Ethereum [\#1019](https://github.com/rubykube/peatio/issues/1019)
- All cryptoaddresses comparisons should be case-sensitive or insensitive \(depending on currency\) [\#1005](https://github.com/rubykube/peatio/issues/1005)
- Add support for ERC20 [\#384](https://github.com/rubykube/peatio/issues/384)

**Merged pull requests:**

- Add logging to Grape APIs [\#1027](https://github.com/rubykube/peatio/pull/1027) ([yivo](https://github.com/yivo))
- Fix «\[object Object\]» problem in API docs, add bin/bump for updating versions & tweak ci/bump.rb [\#1024](https://github.com/rubykube/peatio/pull/1024) ([yivo](https://github.com/yivo))
- Fix «\[object Object\]» problem in API docs, add bin/bump for updating versions & tweak ci/bump.rb [\#1023](https://github.com/rubykube/peatio/pull/1023) ([yivo](https://github.com/yivo))
- Fix «\[object Object\]» problem in API docs, add bin/bump for updating versions & tweak ci/bump.rb [\#1022](https://github.com/rubykube/peatio/pull/1022) ([yivo](https://github.com/yivo))
- Add support for ERC20 [\#913](https://github.com/rubykube/peatio/pull/913) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.6.15](https://github.com/rubykube/peatio/tree/1.6.15) (2018-05-01)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.9...1.6.15)

## [1.7.9](https://github.com/rubykube/peatio/tree/1.7.9) (2018-05-01)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.8...1.7.9)

**Closed issues:**

- \[Mac OS Development Environment\] Trading url is not reachable [\#1013](https://github.com/rubykube/peatio/issues/1013)
- NoMethodError in Management API [\#1010](https://github.com/rubykube/peatio/issues/1010)
- Permit transactions between internal  recipients  [\#837](https://github.com/rubykube/peatio/issues/837)

**Merged pull requests:**

- Fix disappearing security\_configuration when module reloads [\#1018](https://github.com/rubykube/peatio/pull/1018) ([yivo](https://github.com/yivo))
- Fix disappearing security\_configuration when module reloads [\#1017](https://github.com/rubykube/peatio/pull/1017) ([yivo](https://github.com/yivo))
- Fix disappearing security\_configuration when module reloads [\#1016](https://github.com/rubykube/peatio/pull/1016) ([yivo](https://github.com/yivo))
- Fix disappearing security\_configuration when module reloads [\#1015](https://github.com/rubykube/peatio/pull/1015) ([yivo](https://github.com/yivo))
- Fix disappearing security\_configuration when module reloads [\#1014](https://github.com/rubykube/peatio/pull/1014) ([kriskelly](https://github.com/kriskelly))
- Permit transactions between internal recipients [\#1012](https://github.com/rubykube/peatio/pull/1012) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.7.8](https://github.com/rubykube/peatio/tree/1.7.8) (2018-05-01)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.14...1.7.8)

## [1.6.14](https://github.com/rubykube/peatio/tree/1.6.14) (2018-05-01)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.7...1.6.14)

**Closed issues:**

- Bitgo Usage [\#1009](https://github.com/rubykube/peatio/issues/1009)
- Ethereum setup on Peatio [\#1006](https://github.com/rubykube/peatio/issues/1006)
- Support Zcash [\#1001](https://github.com/rubykube/peatio/issues/1001)
- Can not create new order [\#1000](https://github.com/rubykube/peatio/issues/1000)
- market does not have a valid value [\#999](https://github.com/rubykube/peatio/issues/999)
- Withdraw created via API call were not processed by daemons [\#997](https://github.com/rubykube/peatio/issues/997)
- Question: Is it possible to AWS Redis ElasticCache? [\#995](https://github.com/rubykube/peatio/issues/995)

**Merged pull requests:**

- Add «deposit\_confirmations» to config/seed/currencies.yml.erb [\#1008](https://github.com/rubykube/peatio/pull/1008) ([yivo](https://github.com/yivo))
- Add missing «withdraw\_fee» & «deposit\_confirmations» to config/seed/currencies.yml.erb [\#1007](https://github.com/rubykube/peatio/pull/1007) ([yivo](https://github.com/yivo))
- Submit withdraw after creation via API [\#1004](https://github.com/rubykube/peatio/pull/1004) ([ysv](https://github.com/ysv))
- Submit withdraw after creation via API [\#1002](https://github.com/rubykube/peatio/pull/1002) ([ysv](https://github.com/ysv))
- Submit withdraw after creation via API \(closes \#997\) [\#998](https://github.com/rubykube/peatio/pull/998) ([ysv](https://github.com/ysv))
- Add API calls for getting all possible fees \(resolves \#852\) [\#935](https://github.com/rubykube/peatio/pull/935) ([shal](https://github.com/shal))
- Deposit fee feature \(closes \#886\) [\#915](https://github.com/rubykube/peatio/pull/915) ([ysv](https://github.com/ysv))

## [1.7.7](https://github.com/rubykube/peatio/tree/1.7.7) (2018-04-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.10...1.7.7)

**Closed issues:**

- UI issue at account info [\#953](https://github.com/rubykube/peatio/issues/953)
- UI existing Market overview  [\#939](https://github.com/rubykube/peatio/issues/939)
- Deposit fee feature [\#886](https://github.com/rubykube/peatio/issues/886)
- Unexpected URL for fiat deposit page \(admin panel\) [\#883](https://github.com/rubykube/peatio/issues/883)
- Unable to disable Web / API access at admin panel [\#862](https://github.com/rubykube/peatio/issues/862)
- Add API calls to get percent of the fees [\#852](https://github.com/rubykube/peatio/issues/852)

**Merged pull requests:**

- Fix UI issues \(master\) [\#994](https://github.com/rubykube/peatio/pull/994) ([webmix](https://github.com/webmix))
- Fix UI issues \(1.7\) [\#993](https://github.com/rubykube/peatio/pull/993) ([webmix](https://github.com/webmix))
- \#883 Unexpected URL for fiat deposit page v1.8 [\#992](https://github.com/rubykube/peatio/pull/992) ([dinesh-skyach](https://github.com/dinesh-skyach))
- \#883 Unexpected URL for fiat deposit page v1.7 [\#991](https://github.com/rubykube/peatio/pull/991) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.5.10](https://github.com/rubykube/peatio/tree/1.5.10) (2018-04-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.13...1.5.10)

## [1.6.13](https://github.com/rubykube/peatio/tree/1.6.13) (2018-04-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.6...1.6.13)

## [1.7.6](https://github.com/rubykube/peatio/tree/1.7.6) (2018-04-27)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.5...1.7.6)

**Closed issues:**

- ActiveYAML not needed anymore [\#987](https://github.com/rubykube/peatio/issues/987)
- Trading page gives 404 [\#981](https://github.com/rubykube/peatio/issues/981)
- Ability to establish cookie-based session using API [\#974](https://github.com/rubykube/peatio/issues/974)
- BitGo ETH address generation is still broken [\#920](https://github.com/rubykube/peatio/issues/920)

**Merged pull requests:**

- Typos in docs/specs/event\_api [\#989](https://github.com/rubykube/peatio/pull/989) ([yivo](https://github.com/yivo))
- Remove ActiveYAML stuff [\#988](https://github.com/rubykube/peatio/pull/988) ([yivo](https://github.com/yivo))
- Experimental fix for BitGo ETH address generation [\#986](https://github.com/rubykube/peatio/pull/986) ([yivo](https://github.com/yivo))
- Experimental fix for BitGo ETH address generation [\#985](https://github.com/rubykube/peatio/pull/985) ([yivo](https://github.com/yivo))
- Experimental fix for BitGo ETH address generation [\#984](https://github.com/rubykube/peatio/pull/984) ([yivo](https://github.com/yivo))
- Update API docs [\#983](https://github.com/rubykube/peatio/pull/983) ([yivo](https://github.com/yivo))
- Update API docs [\#982](https://github.com/rubykube/peatio/pull/982) ([yivo](https://github.com/yivo))
- Ability to establish cookie-based session using API [\#980](https://github.com/rubykube/peatio/pull/980) ([yivo](https://github.com/yivo))
- Experimental fix for BitGo ETH address generation [\#933](https://github.com/rubykube/peatio/pull/933) ([yivo](https://github.com/yivo))

## [1.7.5](https://github.com/rubykube/peatio/tree/1.7.5) (2018-04-26)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.12...1.7.5)

## [1.6.12](https://github.com/rubykube/peatio/tree/1.6.12) (2018-04-26)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.9...1.6.12)

## [1.5.9](https://github.com/rubykube/peatio/tree/1.5.9) (2018-04-26)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.4...1.5.9)

**Closed issues:**

- «fatal: reference is not a tree:» when installing plugins \(error due to --depth=1\) [\#975](https://github.com/rubykube/peatio/issues/975)
- BitcoinCash address should be converted to legacy format [\#704](https://github.com/rubykube/peatio/issues/704)

**Merged pull requests:**

- Remove «--depth=1» from git clone in bin/install\_plugins \(fixes \#975\) [\#979](https://github.com/rubykube/peatio/pull/979) ([yivo](https://github.com/yivo))
- Remove «--depth=1» from git clone in bin/install\_plugins \(fixes \#975\) [\#978](https://github.com/rubykube/peatio/pull/978) ([yivo](https://github.com/yivo))
- Remove «--depth=1» from git clone in bin/install\_plugins \(fixes \#975\) [\#977](https://github.com/rubykube/peatio/pull/977) ([yivo](https://github.com/yivo))
- Remove «--depth=1» from git clone in bin/install\_plugins \(fixes \#975\) [\#976](https://github.com/rubykube/peatio/pull/976) ([yivo](https://github.com/yivo))
- Always use legacy Bitcoin Cash addresses \(fixes \#704\) [\#973](https://github.com/rubykube/peatio/pull/973) ([yivo](https://github.com/yivo))
- Always use legacy Bitcoin Cash addresses \(fixes \#704\) [\#972](https://github.com/rubykube/peatio/pull/972) ([yivo](https://github.com/yivo))
- Always use legacy Bitcoin Cash addresses \(fixes \#704\) [\#971](https://github.com/rubykube/peatio/pull/971) ([yivo](https://github.com/yivo))
-  Always use legacy Bitcoin Cash addresses \(fixes \#704\) [\#969](https://github.com/rubykube/peatio/pull/969) ([yivo](https://github.com/yivo))

## [1.7.4](https://github.com/rubykube/peatio/tree/1.7.4) (2018-04-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.11...1.7.4)

## [1.6.11](https://github.com/rubykube/peatio/tree/1.6.11) (2018-04-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.10...1.6.11)

**Closed issues:**

- Capybara::ExpectationNotMet: Timed out waiting for Selenium session reset [\#957](https://github.com/rubykube/peatio/issues/957)
- Trading ccy-to-ccy with price less than 0.01 fails on 1-5-stable version. [\#916](https://github.com/rubykube/peatio/issues/916)
- Withdraw issue or lost 0.00000001 [\#911](https://github.com/rubykube/peatio/issues/911)
- Funds withdraw issue, the Withdraw History isn't updating to the last status.  [\#875](https://github.com/rubykube/peatio/issues/875)

**Merged pull requests:**

- Add missing translations for withdraw states [\#968](https://github.com/rubykube/peatio/pull/968) ([yivo](https://github.com/yivo))
- Add missing translations for withdraw states [\#966](https://github.com/rubykube/peatio/pull/966) ([yivo](https://github.com/yivo))
- Add missing «Prepared» translation \(closes \#875\) [\#965](https://github.com/rubykube/peatio/pull/965) ([shal](https://github.com/shal))
- Submit amounts as strings, update String\#to\_d to match Rails behaviour, add specs for extremely precise amounts \(fixes issue \#911, 0.00000001 problem\). [\#963](https://github.com/rubykube/peatio/pull/963) ([yivo](https://github.com/yivo))
- Submit amounts as strings, update String\#to\_d to match Rails behaviour, add specs for extremely precise amounts \(fixes issue \#911, 0.00000001 problem\). [\#962](https://github.com/rubykube/peatio/pull/962) ([yivo](https://github.com/yivo))
- Retry on all Capybara errors in tests \(issue \#957\) [\#961](https://github.com/rubykube/peatio/pull/961) ([yivo](https://github.com/yivo))
- Retry on all Capybara errors in tests \(issue \#957\) [\#960](https://github.com/rubykube/peatio/pull/960) ([yivo](https://github.com/yivo))
- Retry on all Capybara errors in tests \(issue \#957\) [\#959](https://github.com/rubykube/peatio/pull/959) ([yivo](https://github.com/yivo))
- Submit amounts as strings, update String\#to\_d to match Rails behaviour, add specs for extremely precise amounts \(fixes issue \#911\). [\#958](https://github.com/rubykube/peatio/pull/958) ([yivo](https://github.com/yivo))

## [1.6.10](https://github.com/rubykube/peatio/tree/1.6.10) (2018-04-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.3...1.6.10)

## [1.7.3](https://github.com/rubykube/peatio/tree/1.7.3) (2018-04-25)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.9...1.7.3)

**Closed issues:**

- Withdrawal process cant be canceled  [\#945](https://github.com/rubykube/peatio/issues/945)
- Support Barong level 4 and above [\#941](https://github.com/rubykube/peatio/issues/941)
- Fiat withdrawal, lower amount than withdrawal limit issue. [\#940](https://github.com/rubykube/peatio/issues/940)
- Bid/Ask fee change bug [\#905](https://github.com/rubykube/peatio/issues/905)

**Merged pull requests:**

- Limit trading fee to 50% [\#956](https://github.com/rubykube/peatio/pull/956) ([yivo](https://github.com/yivo))
- Limit trading fee to 50% [\#955](https://github.com/rubykube/peatio/pull/955) ([yivo](https://github.com/yivo))
- Limit trading fee to 50% [\#954](https://github.com/rubykube/peatio/pull/954) ([yivo](https://github.com/yivo))

## [1.6.9](https://github.com/rubykube/peatio/tree/1.6.9) (2018-04-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.2...1.6.9)

## [1.7.2](https://github.com/rubykube/peatio/tree/1.7.2) (2018-04-24)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.1...1.7.2)

**Closed issues:**

- updated\_at is nil when submitting withdraw update event using event API [\#950](https://github.com/rubykube/peatio/issues/950)
- Unable to access peatio \(peatio\_daemons also throwing a lot of exceptions\) [\#934](https://github.com/rubykube/peatio/issues/934)
- Withdraw coin currency ID UI issue [\#929](https://github.com/rubykube/peatio/issues/929)
- Deposit details are broken [\#928](https://github.com/rubykube/peatio/issues/928)
- The side bar collapse have issue with sub menus [\#921](https://github.com/rubykube/peatio/issues/921)
- Footer issue [\#877](https://github.com/rubykube/peatio/issues/877)
- UI improvements of Deposits \(UAH\) and Withdraws \(all\)  [\#867](https://github.com/rubykube/peatio/issues/867)
- UI Proofs -\> Edit improvements  [\#866](https://github.com/rubykube/peatio/issues/866)

**Merged pull requests:**

- Disable automatic processing for fiat withdraws and bring back ability to cancel withdraw [\#952](https://github.com/rubykube/peatio/pull/952) ([yivo](https://github.com/yivo))
- Disable automatic processing for fiat withdraws and bring back ability to cancel withdraw [\#951](https://github.com/rubykube/peatio/pull/951) ([yivo](https://github.com/yivo))
- Disable automatic processing for fiat withdraws and bring back ability to cancel withdraw [\#949](https://github.com/rubykube/peatio/pull/949) ([yivo](https://github.com/yivo))
- Support Barong level 4 and above [\#948](https://github.com/rubykube/peatio/pull/948) ([yivo](https://github.com/yivo))
- Support Barong level 4 and above [\#947](https://github.com/rubykube/peatio/pull/947) ([yivo](https://github.com/yivo))
- Support Barong level 4 and above [\#946](https://github.com/rubykube/peatio/pull/946) ([yivo](https://github.com/yivo))
- Update conditions for fiat withdraw button \(for manual processing\) [\#944](https://github.com/rubykube/peatio/pull/944) ([yivo](https://github.com/yivo))
- Update conditions for fiat withdraw button \(for manual processing\) [\#943](https://github.com/rubykube/peatio/pull/943) ([yivo](https://github.com/yivo))
- Update conditions for fiat withdraw button \(for manual processing\) [\#942](https://github.com/rubykube/peatio/pull/942) ([yivo](https://github.com/yivo))
- Various admin style fixes \(master\) [\#937](https://github.com/rubykube/peatio/pull/937) ([webmix](https://github.com/webmix))
- Various admin style fixes \(1.7\) [\#936](https://github.com/rubykube/peatio/pull/936) ([webmix](https://github.com/webmix))
- Add rspec-retry \(attempting to resolve timeout issue \#878\) [\#908](https://github.com/rubykube/peatio/pull/908) ([yivo](https://github.com/yivo))

## [1.7.1](https://github.com/rubykube/peatio/tree/1.7.1) (2018-04-23)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.7.0...1.7.1)

**Closed issues:**

- Update omniauth-barong gem [\#930](https://github.com/rubykube/peatio/issues/930)
- Typo in Funds \(Deposit\) [\#927](https://github.com/rubykube/peatio/issues/927)
- Candlestick not showing properly [\#926](https://github.com/rubykube/peatio/issues/926)
- Remove the Pusher panel and code [\#864](https://github.com/rubykube/peatio/issues/864)
- Charts building issue  [\#854](https://github.com/rubykube/peatio/issues/854)
- Cleanup README from style customization [\#849](https://github.com/rubykube/peatio/issues/849)
- README file needs lot of update [\#847](https://github.com/rubykube/peatio/issues/847)
- Specs failing: Capybara::ExpectationNotMet: Timed out waiting for Selenium session reset \(alert problem\) [\#834](https://github.com/rubykube/peatio/issues/834)
- Publish informative events about lifecycle from most important models using AMQP [\#757](https://github.com/rubykube/peatio/issues/757)
- OTP for API withdraw operations [\#624](https://github.com/rubykube/peatio/issues/624)
- API client for Elixir  [\#434](https://github.com/rubykube/peatio/issues/434)

**Merged pull requests:**

- Update omniaut-barong to 0.1.4 \(closes \#930\) [\#931](https://github.com/rubykube/peatio/pull/931) ([ysv](https://github.com/ysv))
- UI bugs fixes \(Bootstrap 4 migration\) - 1.7  [\#925](https://github.com/rubykube/peatio/pull/925) ([webmix](https://github.com/webmix))
- UI bugs fixes \(Bootstrap 4 migration\) - 1.8 \(master\) [\#924](https://github.com/rubykube/peatio/pull/924) ([webmix](https://github.com/webmix))
- Remove the Pusher panel and code \(closes \#864\) [\#922](https://github.com/rubykube/peatio/pull/922) ([shal](https://github.com/shal))
- Fix walletnotify example in docs [\#918](https://github.com/rubykube/peatio/pull/918) ([kriskelly](https://github.com/kriskelly))

## [1.7.0](https://github.com/rubykube/peatio/tree/1.7.0) (2018-04-19)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.8...1.7.0)

**Closed issues:**

- Footer in admin pannel [\#903](https://github.com/rubykube/peatio/issues/903)
- UI fix horizontal scrolling  [\#900](https://github.com/rubykube/peatio/issues/900)
- Increase max possible fee \(withdraw, market, order, currency\) [\#890](https://github.com/rubykube/peatio/issues/890)
- UI improvements to a Members page in admin panel [\#873](https://github.com/rubykube/peatio/issues/873)
- UI improvements to a funds page [\#872](https://github.com/rubykube/peatio/issues/872)
- Update styles for admin/currencies   [\#865](https://github.com/rubykube/peatio/issues/865)
- UI issues with the left navigation bar at admin panel [\#863](https://github.com/rubykube/peatio/issues/863)

**Merged pull requests:**

- Various design fixes \(Bootstrap 4 migration\) [\#917](https://github.com/rubykube/peatio/pull/917) ([webmix](https://github.com/webmix))
- Implement Event API [\#914](https://github.com/rubykube/peatio/pull/914) ([yivo](https://github.com/yivo))
- Sidebar fixes \(Bootstrap 4 migration\) [\#912](https://github.com/rubykube/peatio/pull/912) ([webmix](https://github.com/webmix))
- Use decimal 32, 16 for all fee columns \(closes \#890\) [\#906](https://github.com/rubykube/peatio/pull/906) ([ysv](https://github.com/ysv))
- Use decimal 32, 16  for all fee columns [\#904](https://github.com/rubykube/peatio/pull/904) ([ysv](https://github.com/ysv))
- Release notes for 1.7.0 [\#897](https://github.com/rubykube/peatio/pull/897) ([yivo](https://github.com/yivo))
- Update omniauth-barong version [\#896](https://github.com/rubykube/peatio/pull/896) ([spavlishak](https://github.com/spavlishak))
- Specifications for Event API [\#868](https://github.com/rubykube/peatio/pull/868) ([mod](https://github.com/mod))

## [1.6.8](https://github.com/rubykube/peatio/tree/1.6.8) (2018-04-19)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.8...1.6.8)

**Closed issues:**

- Unrecognized currency on proof page [\#902](https://github.com/rubykube/peatio/issues/902)
- Net::ReadTimeout in Capybara specs [\#878](https://github.com/rubykube/peatio/issues/878)

**Merged pull requests:**

- Update omniauth-barong version [\#898](https://github.com/rubykube/peatio/pull/898) ([dmk](https://github.com/dmk))

## [1.5.8](https://github.com/rubykube/peatio/tree/1.5.8) (2018-04-18)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.7...1.5.8)

**Closed issues:**

- Sidebar is not scrollable: I can't access menu items at the bottom [\#882](https://github.com/rubykube/peatio/issues/882)
- Fee must be stored in order model [\#842](https://github.com/rubykube/peatio/issues/842)
- Gemfile optimization: eventmachine & em-websocket should be required by demand \(in websocket daemon\) [\#824](https://github.com/rubykube/peatio/issues/824)

**Merged pull requests:**

- Display Currency\#code instead of Currency\#to\_s at /admin/proofs \(closes \#902\) [\#910](https://github.com/rubykube/peatio/pull/910) ([ysv](https://github.com/ysv))
- Add rspec-retry \(attempting to resolve timeout issue \#878\) [\#909](https://github.com/rubykube/peatio/pull/909) ([yivo](https://github.com/yivo))
- Add rspec-retry \(attempting to resolve timeout issue \#878\) [\#907](https://github.com/rubykube/peatio/pull/907) ([yivo](https://github.com/yivo))
- Add missing «Currencies» rubric at admin panel [\#901](https://github.com/rubykube/peatio/pull/901) ([yivo](https://github.com/yivo))
- Store fee in order model [\#899](https://github.com/rubykube/peatio/pull/899) ([yivo](https://github.com/yivo))
- Gemfile optimization: eventmachine & em-websocket [\#885](https://github.com/rubykube/peatio/pull/885) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Store fee in order model [\#879](https://github.com/rubykube/peatio/pull/879) ([ysv](https://github.com/ysv))

## [1.5.7](https://github.com/rubykube/peatio/tree/1.5.7) (2018-04-18)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.7...1.5.7)

**Closed issues:**

- deposits not accepted [\#893](https://github.com/rubykube/peatio/issues/893)
- non bitgo coin wallet address [\#891](https://github.com/rubykube/peatio/issues/891)
- is there a guide to add new BTC based coin \(altcoin\)? [\#889](https://github.com/rubykube/peatio/issues/889)
- only sign in button, no signup - using google oauth [\#888](https://github.com/rubykube/peatio/issues/888)
- Canceling orders doesn't work on BTCD/ETHD [\#841](https://github.com/rubykube/peatio/issues/841)
- Missing Private::DepositsController\#destroy action \(couldn't cancel deposit\) [\#838](https://github.com/rubykube/peatio/issues/838)
- Embed «DepositChannel» in «Currency» [\#789](https://github.com/rubykube/peatio/issues/789)
- Embed «WithdrawChannel» in «Currency» [\#788](https://github.com/rubykube/peatio/issues/788)
- Move deposit channels to database layer [\#785](https://github.com/rubykube/peatio/issues/785)
- Move withdraw channels to database layer [\#784](https://github.com/rubykube/peatio/issues/784)
- Remove mailing stuff from Peatio [\#758](https://github.com/rubykube/peatio/issues/758)
- Ability to manage currencies using admin panel [\#716](https://github.com/rubykube/peatio/issues/716)

**Merged pull requests:**

- Add ability to set uid and gid as docker build args \(\#833\) [\#895](https://github.com/rubykube/peatio/pull/895) ([gfedorenko](https://github.com/gfedorenko))
- Fix error in OrderBook entity caused by class loading order bug in Grape [\#892](https://github.com/rubykube/peatio/pull/892) ([kriskelly](https://github.com/kriskelly))
- Update sidebar.js \(remove ES6 syntax\) [\#887](https://github.com/rubykube/peatio/pull/887) ([webmix](https://github.com/webmix))
- Embed «WithdrawChannel» in «Currency» [\#884](https://github.com/rubykube/peatio/pull/884) ([ysv](https://github.com/ysv))
- Embed «DepositChannel» in «Currency» [\#881](https://github.com/rubykube/peatio/pull/881) ([yivo](https://github.com/yivo))
- Various UI fixes \(Bootstrap 4 migration\) [\#880](https://github.com/rubykube/peatio/pull/880) ([webmix](https://github.com/webmix))
- Remove mailing stuff from Peatio \(closes \#758\) [\#850](https://github.com/rubykube/peatio/pull/850) ([ysv](https://github.com/ysv))
- Multi-fiat support [\#826](https://github.com/rubykube/peatio/pull/826) ([yivo](https://github.com/yivo))
- Ability to manage currencies using admin panel [\#825](https://github.com/rubykube/peatio/pull/825) ([ysv](https://github.com/ysv))

## [1.6.7](https://github.com/rubykube/peatio/tree/1.6.7) (2018-04-16)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.6...1.6.7)

## [1.5.6](https://github.com/rubykube/peatio/tree/1.5.6) (2018-04-16)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.6...1.5.6)

**Closed issues:**

- QR code generation on new account [\#876](https://github.com/rubykube/peatio/issues/876)
- trade page have unnecessary Sign in option. [\#871](https://github.com/rubykube/peatio/issues/871)
- rake db:seed probably breaks [\#869](https://github.com/rubykube/peatio/issues/869)
- Finish Capybara tests in features/admin/withdraw\_spec.rb [\#831](https://github.com/rubykube/peatio/issues/831)
- Deposit model it too complex and can fully replace PaymentTransaction [\#827](https://github.com/rubykube/peatio/issues/827)
- Recode Slim templates to ERB and remove gem slim [\#823](https://github.com/rubykube/peatio/issues/823)
- Remove custom swagger UI leftovers [\#822](https://github.com/rubykube/peatio/issues/822)

**Merged pull requests:**

- Don't create payment addresses for fiat currency. Additional checks for address generation. [\#874](https://github.com/rubykube/peatio/pull/874) ([yivo](https://github.com/yivo))
- Fix some typos in README. [\#870](https://github.com/rubykube/peatio/pull/870) ([seed](https://github.com/seed))
- Finish Capybara tests in features/admin/withdraw\_spec.rb [\#860](https://github.com/rubykube/peatio/pull/860) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Remove custom swagger UI leftovers [\#844](https://github.com/rubykube/peatio/pull/844) ([k1T4eR](https://github.com/k1T4eR))
- Remove gem Slim [\#836](https://github.com/rubykube/peatio/pull/836) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.6.6](https://github.com/rubykube/peatio/tree/1.6.6) (2018-04-13)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.5...1.6.6)

**Closed issues:**

- Depositing Daemon Issues [\#861](https://github.com/rubykube/peatio/issues/861)
- List of orders is not displayed in trading UI [\#840](https://github.com/rubykube/peatio/issues/840)

**Merged pull requests:**

- Enqueue new matching engine after market create \(closes \#840 \#841\) [\#856](https://github.com/rubykube/peatio/pull/856) ([ysv](https://github.com/ysv))
- Migrating to Bootstrap 4 + admin template [\#828](https://github.com/rubykube/peatio/pull/828) ([webmix](https://github.com/webmix))

## [1.5.5](https://github.com/rubykube/peatio/tree/1.5.5) (2018-04-13)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.5...1.5.5)

## [1.6.5](https://github.com/rubykube/peatio/tree/1.6.5) (2018-04-13)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.4...1.6.5)

**Closed issues:**

- error:  cannot load such file -- em-http     [\#859](https://github.com/rubykube/peatio/issues/859)
- NoMethodError: undefined method `deep\_symbolize\_keys' [\#858](https://github.com/rubykube/peatio/issues/858)
- Possible memory leak? [\#857](https://github.com/rubykube/peatio/issues/857)
- rake aborted!  \(bundle exec rake tmp:create yarn:install assets:precompile\) [\#853](https://github.com/rubykube/peatio/issues/853)
- Base fiat currency is not specified. [\#851](https://github.com/rubykube/peatio/issues/851)
- To finish Deposit to BCH admin should Accept the the transaction [\#846](https://github.com/rubykube/peatio/issues/846)
- Sync Bitcoin [\#845](https://github.com/rubykube/peatio/issues/845)
- Delete the fiat coin already implemented on the platfrom [\#843](https://github.com/rubykube/peatio/issues/843)

**Merged pull requests:**

- Add missing Private::DepositsController\#destroy action \(couldn't cancel deposit\) [\#839](https://github.com/rubykube/peatio/pull/839) ([yivo](https://github.com/yivo))
- Replace PaymentTransaction in favor of Deposit [\#829](https://github.com/rubykube/peatio/pull/829) ([yivo](https://github.com/yivo))

## [1.6.4](https://github.com/rubykube/peatio/tree/1.6.4) (2018-04-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.4...1.6.4)

## [1.5.4](https://github.com/rubykube/peatio/tree/1.5.4) (2018-04-10)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.3...1.5.4)

**Closed issues:**

- Fully remove Deposit\#sn in favor of TID [\#821](https://github.com/rubykube/peatio/issues/821)
- Bunny::TCPConnectionFailedForAllHosts in Admin::Members\#show [\#819](https://github.com/rubykube/peatio/issues/819)
- Remove Deposit\#fund\_extra, Deposit\#fund\_uid and usages \(USELESS, now using TID\) [\#803](https://github.com/rubykube/peatio/issues/803)
- Remove Withdraw\#sn and all usages [\#802](https://github.com/rubykube/peatio/issues/802)
- Definitely BIG problems with BitGo API [\#801](https://github.com/rubykube/peatio/issues/801)
- Remove trading UI leftovers in Peatio  [\#793](https://github.com/rubykube/peatio/issues/793)
- After canceling order it is not saving in History [\#765](https://github.com/rubykube/peatio/issues/765)
- Specs are failing with seed 59081 [\#733](https://github.com/rubykube/peatio/issues/733)
- Ability to manage market pairs using admin panel [\#717](https://github.com/rubykube/peatio/issues/717)

**Merged pull requests:**

- Add ability to set uid and gid as docker build args [\#833](https://github.com/rubykube/peatio/pull/833) ([dmk](https://github.com/dmk))
- Ignore .yarnrc and .cache [\#832](https://github.com/rubykube/peatio/pull/832) ([dmk](https://github.com/dmk))
- Remove Deposit\#fund\_extra, Deposit\#fund\_uid and usages \(fixes \#803\) [\#820](https://github.com/rubykube/peatio/pull/820) ([k1T4eR](https://github.com/k1T4eR))
- Remove Withdraw\#sn and all usages \(fixes \#802\) [\#816](https://github.com/rubykube/peatio/pull/816) ([k1T4eR](https://github.com/k1T4eR))
-  Fixes & specs for updated BitGo API [\#797](https://github.com/rubykube/peatio/pull/797) ([yivo](https://github.com/yivo))
- Fix failing specs with seed 59081 & 39808 \(Capybara + DatabaseCleaner issue\) [\#796](https://github.com/rubykube/peatio/pull/796) ([yivo](https://github.com/yivo))
- Remove trading UI leftovers in Peatio [\#794](https://github.com/rubykube/peatio/pull/794) ([k1T4eR](https://github.com/k1T4eR))
- Ability to manage market pairs using admin panel [\#781](https://github.com/rubykube/peatio/pull/781) ([ysv](https://github.com/ysv))

## [1.6.3](https://github.com/rubykube/peatio/tree/1.6.3) (2018-04-06)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.2...1.6.3)

**Closed issues:**

- If withdraw was rejected it should still appear in Account history  [\#814](https://github.com/rubykube/peatio/issues/814)
- Account history should have 'State/Action' column  [\#813](https://github.com/rubykube/peatio/issues/813)
- Email notification 'ETHD withdrawal has been successfully submitted' is sent, when withdraw was rejected  [\#812](https://github.com/rubykube/peatio/issues/812)
- Set member API version to match Peatio version [\#810](https://github.com/rubykube/peatio/issues/810)
- Page should not be reloaded after creation of withdraw [\#798](https://github.com/rubykube/peatio/issues/798)
- When Accept Deposit from Admin UI, get error undefined method `may\_submit?' for \#\<Deposits::Fiat\> [\#795](https://github.com/rubykube/peatio/issues/795)

**Merged pull requests:**

- Set member API version to match Peatio version \(fixes \#810\) [\#815](https://github.com/rubykube/peatio/pull/815) ([k1T4eR](https://github.com/k1T4eR))
- Page should not be reloaded after creation of withdraw \(fixes \#798\) [\#807](https://github.com/rubykube/peatio/pull/807) ([k1T4eR](https://github.com/k1T4eR))
- Get rid of errors «Undefined method may\_\*?» for deposits and withdraws \(fixes \#795\). [\#806](https://github.com/rubykube/peatio/pull/806) ([yivo](https://github.com/yivo))
- Hide «unsecure protocol» warning from Bundler [\#751](https://github.com/rubykube/peatio/pull/751) ([dpaluy](https://github.com/dpaluy))

## [1.6.2](https://github.com/rubykube/peatio/tree/1.6.2) (2018-04-06)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.3...1.6.2)

## [1.5.3](https://github.com/rubykube/peatio/tree/1.5.3) (2018-04-06)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.1...1.5.3)

**Closed issues:**

- Admin deposit view is broken after \#740 [\#809](https://github.com/rubykube/peatio/issues/809)
- PUSHER\_CLIENT\_ENCRYPTED is ignored when value is «false» [\#804](https://github.com/rubykube/peatio/issues/804)
- Missing destination object \(fiat deposit/withdraw admin pages are broken\) [\#799](https://github.com/rubykube/peatio/issues/799)
- Fix warnings from figaro [\#792](https://github.com/rubykube/peatio/issues/792)
- Remove withdraw destination from withdraw model [\#772](https://github.com/rubykube/peatio/issues/772)

**Merged pull requests:**

- PUSHER\_CLIENT\_ENCRYPTED is ignored when value is «false» [\#811](https://github.com/rubykube/peatio/pull/811) ([k1T4eR](https://github.com/k1T4eR))
- Suppress warnings from figaro \(fixes \#792\) [\#808](https://github.com/rubykube/peatio/pull/808) ([k1T4eR](https://github.com/k1T4eR))
- Remove «WithdrawDestination» model in favor of RID \(fixes \#799, \#772\). [\#800](https://github.com/rubykube/peatio/pull/800) ([yivo](https://github.com/yivo))
- Add missing step for installation with PostgreSQL [\#769](https://github.com/rubykube/peatio/pull/769) ([dpaluy](https://github.com/dpaluy))
- Add gem «bullet» [\#762](https://github.com/rubykube/peatio/pull/762) ([dpaluy](https://github.com/dpaluy))

## [1.6.1](https://github.com/rubykube/peatio/tree/1.6.1) (2018-04-06)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.6.0...1.6.1)

**Closed issues:**

- NoMethodError: undefined method `fetch' for \#\<OpenSSL::PKey::RSA\> [\#790](https://github.com/rubykube/peatio/issues/790)
- Change of the server [\#780](https://github.com/rubykube/peatio/issues/780)
- markets not working. [\#779](https://github.com/rubykube/peatio/issues/779)
- Customization of title in mails [\#766](https://github.com/rubykube/peatio/issues/766)
- Support Zendesk Integration. [\#744](https://github.com/rubykube/peatio/issues/744)
- New feature proposition - Coin list voting [\#403](https://github.com/rubykube/peatio/issues/403)

**Merged pull requests:**

- Fix «NoMethodError: undefined method `fetch' for \#\<OpenSSL::PKey::RSA\>» [\#791](https://github.com/rubykube/peatio/pull/791) ([yivo](https://github.com/yivo))
- Fix typos and update details for Ubuntu installation instruction [\#783](https://github.com/rubykube/peatio/pull/783) ([msylvestre](https://github.com/msylvestre))
- Improved English phrasing in README [\#782](https://github.com/rubykube/peatio/pull/782) ([PFBourassa](https://github.com/PFBourassa))
- Add missing translation for «ORDER FULFILLED» \(account version reason\) and fix spelling. [\#709](https://github.com/rubykube/peatio/pull/709) ([sramsden](https://github.com/sramsden))

## [1.6.0](https://github.com/rubykube/peatio/tree/1.6.0) (2018-04-04)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.2...1.6.0)

**Merged pull requests:**

- Remove unused config/templates/markets.yml [\#777](https://github.com/rubykube/peatio/pull/777) ([yivo](https://github.com/yivo))
- Release 1.6.0 [\#773](https://github.com/rubykube/peatio/pull/773) ([yivo](https://github.com/yivo))
- Add management API v1 [\#740](https://github.com/rubykube/peatio/pull/740) ([yivo](https://github.com/yivo))

## [1.5.2](https://github.com/rubykube/peatio/tree/1.5.2) (2018-04-04)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.1...1.5.2)

**Closed issues:**

- getting warning while rake db:create [\#778](https://github.com/rubykube/peatio/issues/778)
- BitGo API docs for creation of address is outdated: unable to create ETH address [\#775](https://github.com/rubykube/peatio/issues/775)
- 500 Error on pages after the  Migrate markets.yaml to database [\#774](https://github.com/rubykube/peatio/issues/774)
- Ethereum Deposit  [\#770](https://github.com/rubykube/peatio/issues/770)
- Help me understand how wallet works [\#736](https://github.com/rubykube/peatio/issues/736)
- Multisig Wallet Ethereum [\#621](https://github.com/rubykube/peatio/issues/621)
- Docker image build should be tested in production, development & test environments [\#127](https://github.com/rubykube/peatio/issues/127)
- Migrate markets.yml into database [\#121](https://github.com/rubykube/peatio/issues/121)

**Merged pull requests:**

- Handle specific response for ETH wallet from BitGo \(closes \#775\). [\#776](https://github.com/rubykube/peatio/pull/776) ([yivo](https://github.com/yivo))
- Migrate markets.yaml to database. [\#412](https://github.com/rubykube/peatio/pull/412) ([k1T4eR](https://github.com/k1T4eR))

## [1.5.1](https://github.com/rubykube/peatio/tree/1.5.1) (2018-04-02)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.4.0...1.5.1)

**Closed issues:**

- Performance of initial HTTP GET  is not great [\#768](https://github.com/rubykube/peatio/issues/768)
- Peatio API V2 Service [\#767](https://github.com/rubykube/peatio/issues/767)

**Merged pull requests:**

- Handle «state», «level» from Barong via OmniAuth \(\#724\) [\#771](https://github.com/rubykube/peatio/pull/771) ([shal](https://github.com/shal))

## [1.4.0](https://github.com/rubykube/peatio/tree/1.4.0) (2018-03-30)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.3.0...1.4.0)

## [1.3.0](https://github.com/rubykube/peatio/tree/1.3.0) (2018-03-30)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.2.0...1.3.0)

## [1.2.0](https://github.com/rubykube/peatio/tree/1.2.0) (2018-03-30)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.1.0...1.2.0)

## [1.1.0](https://github.com/rubykube/peatio/tree/1.1.0) (2018-03-30)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.5.0...1.1.0)

**Closed issues:**

- API for fetching saved addresses for ccy doesn't work [\#764](https://github.com/rubykube/peatio/issues/764)
- USD Deposits behaviour [\#760](https://github.com/rubykube/peatio/issues/760)
- Error installing Nokogiri 1.8.2 gem in docker container for Peatio [\#755](https://github.com/rubykube/peatio/issues/755)
- MISCONF Redis is configured to save RDB snapshots [\#754](https://github.com/rubykube/peatio/issues/754)
- Hiring: Setup of platform and Dividends Token&Referral Implimentation [\#753](https://github.com/rubykube/peatio/issues/753)
- Update button doesnt work [\#752](https://github.com/rubykube/peatio/issues/752)
- All data in trade page is blank [\#750](https://github.com/rubykube/peatio/issues/750)
- Market wont accept any buy or sell orders [\#749](https://github.com/rubykube/peatio/issues/749)
- bundle exec rake db:setup failure [\#748](https://github.com/rubykube/peatio/issues/748)
- Unable to add coin withdrawals address [\#747](https://github.com/rubykube/peatio/issues/747)
- Deposit address not generated [\#746](https://github.com/rubykube/peatio/issues/746)
- Ability to create fiat/coin withdraws using management API [\#745](https://github.com/rubykube/peatio/issues/745)
- Sign In With Barong | Your account has been disabled, contact admin if you have any problem. [\#743](https://github.com/rubykube/peatio/issues/743)
- Trade page is blank [\#742](https://github.com/rubykube/peatio/issues/742)
- KeyError: key not found: "REDIS\_URL" [\#739](https://github.com/rubykube/peatio/issues/739)
- Trade not working [\#738](https://github.com/rubykube/peatio/issues/738)
- Cannot complete setup via docker [\#735](https://github.com/rubykube/peatio/issues/735)
- Currency code is shown as Ruby object inspection at /admin/proofs [\#734](https://github.com/rubykube/peatio/issues/734)
- Your account has been disabled, contact admin if you have any problem. [\#732](https://github.com/rubykube/peatio/issues/732)
- Base fiat currency is not specified [\#731](https://github.com/rubykube/peatio/issues/731)
- Scan project for Rubocop offences \(TravisCI\) [\#729](https://github.com/rubykube/peatio/issues/729)
- Perform security scan at TravisCI \(Brakeman\) [\#728](https://github.com/rubykube/peatio/issues/728)
- Update loofah to 2.2 [\#725](https://github.com/rubykube/peatio/issues/725)
- AssetsController \#partial\_tree is broken [\#723](https://github.com/rubykube/peatio/issues/723)
- Respect field «state» from OmniAuth data [\#722](https://github.com/rubykube/peatio/issues/722)
- Improve validations for app/models/currency.rb [\#718](https://github.com/rubykube/peatio/issues/718)
- Implement base structure for payments API based on Grape \(separate namespace\) [\#715](https://github.com/rubykube/peatio/issues/715)
- Remove translations not used by Peatio [\#714](https://github.com/rubykube/peatio/issues/714)
- Seperated trading UI [\#713](https://github.com/rubykube/peatio/issues/713)
- rake aborted! [\#712](https://github.com/rubykube/peatio/issues/712)
- Markets switcher doesn't work   [\#707](https://github.com/rubykube/peatio/issues/707)
- What is account Summary? How it is working? [\#706](https://github.com/rubykube/peatio/issues/706)
- Currency\#quick\_withdraw\_limit [\#692](https://github.com/rubykube/peatio/issues/692)
- Themes support \[proposal\] [\#584](https://github.com/rubykube/peatio/issues/584)
- Ability to retrieve solvency information through API [\#566](https://github.com/rubykube/peatio/issues/566)
- Ability to create fiat deposits using management API [\#558](https://github.com/rubykube/peatio/issues/558)
- Recommended approach to transfer exchange funds to cold wallet [\#537](https://github.com/rubykube/peatio/issues/537)
- Move member UI \(not admin\) to Rails::Engine based gem [\#493](https://github.com/rubykube/peatio/issues/493)
- Add support for SQLite [\#491](https://github.com/rubykube/peatio/issues/491)
- UI should sign out user when session is expired [\#423](https://github.com/rubykube/peatio/issues/423)
- Confirmation mail [\#397](https://github.com/rubykube/peatio/issues/397)
- Importing existing order books [\#371](https://github.com/rubykube/peatio/issues/371)
- Enable Code Climate [\#240](https://github.com/rubykube/peatio/issues/240)

**Merged pull requests:**

- Ability to enable/disable incrementation of patch level on master branch [\#756](https://github.com/rubykube/peatio/pull/756) ([yivo](https://github.com/yivo))
- Stop «Exchange assets» tab from breaking without liability proof generated && remove redundant AssetsController\#partial\_tree \(closes \#723\) [\#741](https://github.com/rubykube/peatio/pull/741) ([ysv](https://github.com/ysv))
- Display Currency\#code instead of Currency\#to\_s at /admin/proofs \(fixes \#734\). [\#737](https://github.com/rubykube/peatio/pull/737) ([yivo](https://github.com/yivo))
- Update loofah to 2.2 \(closes \#725\) [\#727](https://github.com/rubykube/peatio/pull/727) ([ysv](https://github.com/ysv))
- Remove translations not used by Peatio \(closes \#714\) [\#726](https://github.com/rubykube/peatio/pull/726) ([ysv](https://github.com/ysv))
- Handle «state», «level» from Barong via OmniAuth [\#724](https://github.com/rubykube/peatio/pull/724) ([yivo](https://github.com/yivo))
- Remove Currency quick\_withdraw\_limit method \(closes \#692\) [\#721](https://github.com/rubykube/peatio/pull/721) ([ysv](https://github.com/ysv))
- Ability to retrieve assets information through API \(closes \#566\) [\#701](https://github.com/rubykube/peatio/pull/701) ([ysv](https://github.com/ysv))
- Speed up Docker image build. [\#648](https://github.com/rubykube/peatio/pull/648) ([yivo](https://github.com/yivo))

## [1.5.0](https://github.com/rubykube/peatio/tree/1.5.0) (2018-03-20)
[Full Changelog](https://github.com/rubykube/peatio/compare/1.0.0...1.5.0)

**Closed issues:**

- WebSocket API fails while trying to get JWT Authorization token [\#699](https://github.com/rubykube/peatio/issues/699)
- Add DELETE /api/v2/sessions which clears user session stored in Redis [\#697](https://github.com/rubykube/peatio/issues/697)
- Charge the FEE in the "base currency"  [\#695](https://github.com/rubykube/peatio/issues/695)
- Investigate why account have field in and out [\#693](https://github.com/rubykube/peatio/issues/693)
- All bank fields must be required for fiat withdraw [\#684](https://github.com/rubykube/peatio/issues/684)
- Peatio doesn't not update order status after it is executed [\#683](https://github.com/rubykube/peatio/issues/683)
- Refactor environment variables for Pusher. [\#681](https://github.com/rubykube/peatio/issues/681)
- APIv2::Entities::WithdrawDestination should include type in field list [\#680](https://github.com/rubykube/peatio/issues/680)
- Field «destination» at APIv2::Entities::Withdraw should be presented as APIv2::Entities::WithdrawDestination [\#679](https://github.com/rubykube/peatio/issues/679)
- Missed dash\<fiat\> market? [\#673](https://github.com/rubykube/peatio/issues/673)
- MySQL database collation needs to be set on database.yml [\#672](https://github.com/rubykube/peatio/issues/672)
- /usr/local/share/peatio/Gemfile:65: syntax error, unexpected ':', expecting $end [\#671](https://github.com/rubykube/peatio/issues/671)
- Api for getting stats from aggregated orders [\#670](https://github.com/rubykube/peatio/issues/670)
- Enable verification of special JWT payload fields [\#668](https://github.com/rubykube/peatio/issues/668)
- Stop keeping private key for JWT, use it only in specs \(must be generated on the demand\) [\#666](https://github.com/rubykube/peatio/issues/666)
- Include iat, exp, jti, sub, iss, aud as additional fields in JWT payload \(update specs only\) [\#664](https://github.com/rubykube/peatio/issues/664)
- Remove Member\#jwt without replacement [\#660](https://github.com/rubykube/peatio/issues/660)
- Remove helper controller used for testing \(Test::ModuleController & Test::MembersController\) [\#659](https://github.com/rubykube/peatio/issues/659)
- Error on Database Setup: Use strings for Figaro configuration. [\#655](https://github.com/rubykube/peatio/issues/655)
- no mina-slack.git ?? [\#654](https://github.com/rubykube/peatio/issues/654)
- When ETH Support? [\#653](https://github.com/rubykube/peatio/issues/653)
- Peatio publishes too many messages in Pusher [\#652](https://github.com/rubykube/peatio/issues/652)
- Peatio API does not cancel single order [\#651](https://github.com/rubykube/peatio/issues/651)
- Peatio API does not cancel all orders [\#650](https://github.com/rubykube/peatio/issues/650)
- Dynamic models, controllers, routes, and code itself for currencies [\#646](https://github.com/rubykube/peatio/issues/646)
- Update bin/init\_config & bin/link\_config according to new config templates structure and updated requirements for config/seed [\#642](https://github.com/rubykube/peatio/issues/642)
- After canceling withdraw page isn't reloaded and UI doesn't react for user action [\#634](https://github.com/rubykube/peatio/issues/634)
- List markets path [\#632](https://github.com/rubykube/peatio/issues/632)
- Remove USD market [\#628](https://github.com/rubykube/peatio/issues/628)
- On the fly member registration in API by using JWT payload [\#623](https://github.com/rubykube/peatio/issues/623)
- Strip keypair authentication [\#622](https://github.com/rubykube/peatio/issues/622)
- Diagram for high level architecture [\#619](https://github.com/rubykube/peatio/issues/619)
- Funds not working - getting redirected to /settings [\#615](https://github.com/rubykube/peatio/issues/615)
- Errno::ENOENT: No such file or directory @ dir\_chdir - vendor/assets/yarn\_components [\#614](https://github.com/rubykube/peatio/issues/614)
- It is not possible to select some timeranges at markets [\#613](https://github.com/rubykube/peatio/issues/613)
- Ripple Security Issue [\#612](https://github.com/rubykube/peatio/issues/612)
- When viewing details of withdrawal i get the following error [\#609](https://github.com/rubykube/peatio/issues/609)
- Typo in app/models/member.rb related to update for OAuth token [\#604](https://github.com/rubykube/peatio/issues/604)
- JWT security issues [\#600](https://github.com/rubykube/peatio/issues/600)
- Withdrawal not getting through to test.bitgo account and testnet [\#599](https://github.com/rubykube/peatio/issues/599)
- Withdraw worker makes withdraw from the newest address but should use funded for it \(BIP32 incompatible currencies only\)   [\#594](https://github.com/rubykube/peatio/issues/594)
- how can i desposit USD? [\#592](https://github.com/rubykube/peatio/issues/592)
- Steps to configure Ethereum with Peatio [\#591](https://github.com/rubykube/peatio/issues/591)
- Page is reloaded no matter what POST withdraw resulted in [\#588](https://github.com/rubykube/peatio/issues/588)
- Display all deposits and withdraws in history \(current limit is 3\) [\#587](https://github.com/rubykube/peatio/issues/587)
- sql error when run " bundle exec rake db:setup " [\#586](https://github.com/rubykube/peatio/issues/586)
- NoMethodError \(undefined method `name' for \#\<Member\>\) [\#581](https://github.com/rubykube/peatio/issues/581)
- When try to view details of failed withdrawal \(as admin\) i get following error [\#580](https://github.com/rubykube/peatio/issues/580)
- Wrong blockchain explorer URL in withdrawal history for destination address [\#579](https://github.com/rubykube/peatio/issues/579)
- When withdrawing on freshly installed system, it does not ask for destination address [\#578](https://github.com/rubykube/peatio/issues/578)
- "undefined method `sum' for nil:NilClass" error when i click on "Solvency" page/menu item [\#577](https://github.com/rubykube/peatio/issues/577)
- Documentation for GCP deployment [\#573](https://github.com/rubykube/peatio/issues/573)
- Regular sign/signup is not implemented? [\#571](https://github.com/rubykube/peatio/issues/571)
- Mysql url format [\#568](https://github.com/rubykube/peatio/issues/568)
- Ability to retrieve API key through API [\#565](https://github.com/rubykube/peatio/issues/565)
- Ability to block regular users to access the UI [\#563](https://github.com/rubykube/peatio/issues/563)
- Ability to customize landing page text [\#562](https://github.com/rubykube/peatio/issues/562)
- Trade Interface, still LTC missing in the choice of the differents markets [\#561](https://github.com/rubykube/peatio/issues/561)
- User BTC withdraw are auto-rejected? [\#560](https://github.com/rubykube/peatio/issues/560)
- Specs for auth via Barong OAuth [\#559](https://github.com/rubykube/peatio/issues/559)
- Remove leftovers after banks.yml removal [\#557](https://github.com/rubykube/peatio/issues/557)
- Delete old generators for deposits, withdraws, locales, and other stuff [\#556](https://github.com/rubykube/peatio/issues/556)
- Address Generation Message [\#553](https://github.com/rubykube/peatio/issues/553)
- Add specs for PR \#534 \(Ability to disable UI\) [\#549](https://github.com/rubykube/peatio/issues/549)
- Implement new fiat withdraw story [\#548](https://github.com/rubykube/peatio/issues/548)
- Plugin system [\#547](https://github.com/rubykube/peatio/issues/547)
- Pusher is not working on trading page [\#538](https://github.com/rubykube/peatio/issues/538)
- Output SN in admin panel [\#533](https://github.com/rubykube/peatio/issues/533)
- Charts doesn't work for BCH/CAD [\#532](https://github.com/rubykube/peatio/issues/532)
- Add ability to optionally disable member UI and markets UI [\#521](https://github.com/rubykube/peatio/issues/521)
- Remove name & nickname from member & authorization models [\#517](https://github.com/rubykube/peatio/issues/517)
- market order [\#498](https://github.com/rubykube/peatio/issues/498)
- Add support for ETH \(BitGo only\) [\#496](https://github.com/rubykube/peatio/issues/496)
- Optimize TravisCI notifications [\#492](https://github.com/rubykube/peatio/issues/492)
- Add support for PostgreSQL [\#490](https://github.com/rubykube/peatio/issues/490)
- Update JWT gem to 2.x [\#469](https://github.com/rubykube/peatio/issues/469)
- Withdraw in Fiat do not works, gives 403 Forbidden  Error [\#459](https://github.com/rubykube/peatio/issues/459)
- Deposit address is displayed with offset to down \(out of the box\) [\#453](https://github.com/rubykube/peatio/issues/453)
- UI issue at «Solvency» page [\#429](https://github.com/rubykube/peatio/issues/429)
- Market Notify on/off doesnt work [\#426](https://github.com/rubykube/peatio/issues/426)
- ReferenceError: log is not defined \(JavaScript error at /documents/api\_v2\) [\#420](https://github.com/rubykube/peatio/issues/420)
- Check the candlestick on markets page and ensure it works well [\#406](https://github.com/rubykube/peatio/issues/406)
- few overlaps found  [\#395](https://github.com/rubykube/peatio/issues/395)
- Layouting in drop down menu [\#380](https://github.com/rubykube/peatio/issues/380)
- Extract trading page \(UI only\) to separate application [\#347](https://github.com/rubykube/peatio/issues/347)
- Add support for Ethereum \(daemon\) [\#334](https://github.com/rubykube/peatio/issues/334)
- Remove hardcoded currencies [\#279](https://github.com/rubykube/peatio/issues/279)
- MSSQL SQL syntax incompatibilities [\#207](https://github.com/rubykube/peatio/issues/207)
- Several specs are failing vue to MSSQL incompatibilities [\#206](https://github.com/rubykube/peatio/issues/206)
- ActiveRecord should respect database column types limits \(it should validate lengths\) [\#189](https://github.com/rubykube/peatio/issues/189)
- Remove gem eco [\#162](https://github.com/rubykube/peatio/issues/162)
- Question: Setting up bank connectivity [\#111](https://github.com/rubykube/peatio/issues/111)

**Merged pull requests:**

- Release Peatio 1.5 [\#711](https://github.com/rubykube/peatio/pull/711) ([yivo](https://github.com/yivo))
- Replace /markets/btcusd with /trading/btcusd \(Ingress issue\) [\#710](https://github.com/rubykube/peatio/pull/710) ([yivo](https://github.com/yivo))
- Add ability to install plugins [\#708](https://github.com/rubykube/peatio/pull/708) ([yivo](https://github.com/yivo))
- Use npm version of 'currency-flags' package [\#703](https://github.com/rubykube/peatio/pull/703) ([dmk](https://github.com/dmk))
- Updated the nginx.conf and passenger.conf record [\#702](https://github.com/rubykube/peatio/pull/702) ([shiftctrl-io](https://github.com/shiftctrl-io))
- Fix broken authentication in WS \(\#699\) [\#700](https://github.com/rubykube/peatio/pull/700) ([dkrokhmal](https://github.com/dkrokhmal))
- Clear user session stored in Redis via API call DELETE /api/v2/sessions \(closes \#697\) [\#698](https://github.com/rubykube/peatio/pull/698) ([ysv](https://github.com/ysv))
- Drop in & out from Account model \(closes \#693\) [\#696](https://github.com/rubykube/peatio/pull/696) ([ysv](https://github.com/ysv))
- Dynamic models, controllers, routes, and code itself for currencies [\#694](https://github.com/rubykube/peatio/pull/694) ([yivo](https://github.com/yivo))
- Add files related to development, etc to ignored by docker [\#689](https://github.com/rubykube/peatio/pull/689) ([shal](https://github.com/shal))
- Set collation on database.yml \(closes \#672\) [\#688](https://github.com/rubykube/peatio/pull/688) ([ysv](https://github.com/ysv))
- Refactor environment variables for Pusher \(closes \#681\) [\#687](https://github.com/rubykube/peatio/pull/687) ([ysv](https://github.com/ysv))
- All bank fields must be required for fiat withdraw [\#686](https://github.com/rubykube/peatio/pull/686) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Expose WithdrawDestination type via API \(closes \#680\) [\#685](https://github.com/rubykube/peatio/pull/685) ([ysv](https://github.com/ysv))
- Present field «destination» at APIv2::Entities::Withdraw as APIv2::Entities::WithdrawDestination [\#682](https://github.com/rubykube/peatio/pull/682) ([shal](https://github.com/shal))
- Release notes for 1.4.0 [\#678](https://github.com/rubykube/peatio/pull/678) ([yivo](https://github.com/yivo))
- Fix regression after \#372 \(broken websocket\_api.rb daemon [\#677](https://github.com/rubykube/peatio/pull/677) ([dmk](https://github.com/dmk))
- Stop keeping private key for JWT, use it only in specs \(closes \#666\) [\#676](https://github.com/rubykube/peatio/pull/676) ([yivo](https://github.com/yivo))
- Fix order of commands in bin/setup to resolve issues with asset installation step [\#675](https://github.com/rubykube/peatio/pull/675) ([dmk](https://github.com/dmk))
- Add missing DASH/USD market \(fixes \#673\). [\#674](https://github.com/rubykube/peatio/pull/674) ([yivo](https://github.com/yivo))
- Enable verification of special JWT payload fields \(closes \#668\). [\#669](https://github.com/rubykube/peatio/pull/669) ([yivo](https://github.com/yivo))
- Introduce additional JWT payload fields in specs: iat, exp, jti, sub, iss, aud \(update specs\) [\#665](https://github.com/rubykube/peatio/pull/665) ([yivo](https://github.com/yivo))
- Remove helper controller used for testing: Test::ModuleController & Test::MembersController [\#662](https://github.com/rubykube/peatio/pull/662) ([yivo](https://github.com/yivo))
- Remove Member\#jwt without replacements \(closes \#660\). [\#661](https://github.com/rubykube/peatio/pull/661) ([yivo](https://github.com/yivo))
- Update JWT gem to 2.1 [\#658](https://github.com/rubykube/peatio/pull/658) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Add on the fly member registration based on JWT payload [\#657](https://github.com/rubykube/peatio/pull/657) ([yivo](https://github.com/yivo))
- Fix broken market «Notify» On/Off buttons [\#649](https://github.com/rubykube/peatio/pull/649) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Changing travis room [\#644](https://github.com/rubykube/peatio/pull/644) ([mod](https://github.com/mod))
- Update bin/init\_config & bin/link\_config according to new config templates structure and updated requirements for config/seed \(closes \#642\) [\#643](https://github.com/rubykube/peatio/pull/643) ([ysv](https://github.com/ysv))
- Reload page after canceling withdraw [\#641](https://github.com/rubykube/peatio/pull/641) ([dinesh-skyach](https://github.com/dinesh-skyach))
- \[ci skip\] Update lib/peatio/version.rb to 1.2.7. [\#640](https://github.com/rubykube/peatio/pull/640) ([yivo](https://github.com/yivo))
- Automatically update lib/peatio/version.rb from TravisCI. [\#639](https://github.com/rubykube/peatio/pull/639) ([yivo](https://github.com/yivo))
- Remove obsolete deployment & pipeline stuff [\#637](https://github.com/rubykube/peatio/pull/637) ([yivo](https://github.com/yivo))
- Replace Gem eco with ejs [\#636](https://github.com/rubykube/peatio/pull/636) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Update MacOS setup instructions [\#635](https://github.com/rubykube/peatio/pull/635) ([gpeng](https://github.com/gpeng))
- Add idempotency behavior for deposit address generation [\#633](https://github.com/rubykube/peatio/pull/633) ([yivo](https://github.com/yivo))
- Fix ReferenceError: log is not defined \(JavaScript error at /documents/api\_v2\) [\#631](https://github.com/rubykube/peatio/pull/631) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fix failing specs with seed 6911. [\#630](https://github.com/rubykube/peatio/pull/630) ([yivo](https://github.com/yivo))
- Strip keypair authentication [\#629](https://github.com/rubykube/peatio/pull/629) ([shal](https://github.com/shal))
- Require latest stable Chrome via .travis.yml & update chromedriver-helper to 1.2.0 \(fixes broken Travis builds\) [\#627](https://github.com/rubykube/peatio/pull/627) ([yivo](https://github.com/yivo))
- Release notes for 1.3.0 [\#625](https://github.com/rubykube/peatio/pull/625) ([yivo](https://github.com/yivo))
- Refactor withdraw destination: implement new fiat withdraw story, leverage existing withdraw API resources, and update UI [\#620](https://github.com/rubykube/peatio/pull/620) ([ysv](https://github.com/ysv))
- Add automatic validation for numeric and string database table fields [\#618](https://github.com/rubykube/peatio/pull/618) ([shal](https://github.com/shal))
- Fix UI bug preventing from selecting timeranges at markets page [\#617](https://github.com/rubykube/peatio/pull/617) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fix wrong blockchain explorer URL in deposit & withdrawal history [\#616](https://github.com/rubykube/peatio/pull/616) ([ysv](https://github.com/ysv))
- Typo in app/models/member.rb related to update for OAuth token \(\#604\) [\#611](https://github.com/rubykube/peatio/pull/611) ([ysv](https://github.com/ysv))
- Admin Deposit & Withdraw controllers fix inheritance problems \(closes  \#609\) [\#610](https://github.com/rubykube/peatio/pull/610) ([ysv](https://github.com/ysv))
- Add specs for ability to disable UI \(closes \#549\) [\#607](https://github.com/rubykube/peatio/pull/607) ([ysv](https://github.com/ysv))
- Add release notes for 1.2.0. [\#606](https://github.com/rubykube/peatio/pull/606) ([yivo](https://github.com/yivo))
- Make UI handle long deposit addresses [\#605](https://github.com/rubykube/peatio/pull/605) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Specs for auth via Barong OAuth \(\#559\) [\#603](https://github.com/rubykube/peatio/pull/603) ([ysv](https://github.com/ysv))
- Backport support for Rippled, and move from deprecated v1 REST API to latest JSON RPC. [\#602](https://github.com/rubykube/peatio/pull/602) ([yivo](https://github.com/yivo))
- Remove leftovers after banks.yml removal \(\#557\) [\#598](https://github.com/rubykube/peatio/pull/598) ([ysv](https://github.com/ysv))
- Delete old generators for deposits, withdraws, locales, and other stuff \(\#556\) [\#597](https://github.com/rubykube/peatio/pull/597) ([ysv](https://github.com/ysv))
- Remove ability to generate extra addresses \(fixes \#594\) [\#596](https://github.com/rubykube/peatio/pull/596) ([yivo](https://github.com/yivo))
- View details of coin withdrawal fix caused by wrong before\_action using \(\#580\) [\#595](https://github.com/rubykube/peatio/pull/595) ([ysv](https://github.com/ysv))
- \#553  Address Generation Message [\#593](https://github.com/rubykube/peatio/pull/593) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Display all deposits and withdraws in history \(closes \#587\) [\#590](https://github.com/rubykube/peatio/pull/590) ([yivo](https://github.com/yivo))
- Reload page after withdraw create only on success \(closes \#588\) [\#589](https://github.com/rubykube/peatio/pull/589) ([yivo](https://github.com/yivo))
- \#429 Fixed UI issue at Solvency page [\#585](https://github.com/rubykube/peatio/pull/585) ([dinesh-skyach](https://github.com/dinesh-skyach))
- \#380 Fixed Layouting in drop down menu [\#582](https://github.com/rubykube/peatio/pull/582) ([dinesh-skyach](https://github.com/dinesh-skyach))
- \#395 Fixed few overlaps found [\#576](https://github.com/rubykube/peatio/pull/576) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Fixed broken Docker Setup page link [\#575](https://github.com/rubykube/peatio/pull/575) ([shiftctrl-io](https://github.com/shiftctrl-io))
- Fixed broken Kite link under Production Setup [\#574](https://github.com/rubykube/peatio/pull/574) ([shiftctrl-io](https://github.com/shiftctrl-io))
- Add support for PostgreSQL [\#572](https://github.com/rubykube/peatio/pull/572) ([mitjok](https://github.com/mitjok))
- Fixed broken link to Docker Setup page [\#570](https://github.com/rubykube/peatio/pull/570) ([shiftctrl-io](https://github.com/shiftctrl-io))
- Add support for ETH \(Geth\) [\#569](https://github.com/rubykube/peatio/pull/569) ([yivo](https://github.com/yivo))
- \#206 and \#207: Several Specs are failing due to MSSQL incompatibilities [\#567](https://github.com/rubykube/peatio/pull/567) ([dinesh-skyach](https://github.com/dinesh-skyach))
- Automatically tag version from TravisCI build [\#555](https://github.com/rubykube/peatio/pull/555) ([yivo](https://github.com/yivo))
- Output member SN in admin panel \(\#533\) [\#551](https://github.com/rubykube/peatio/pull/551) ([ysv](https://github.com/ysv))
- Remove name & nickname from member & authorization models [\#535](https://github.com/rubykube/peatio/pull/535) ([ysv](https://github.com/ysv))
- Move currencies.yml to database [\#488](https://github.com/rubykube/peatio/pull/488) ([mitjok](https://github.com/mitjok))
- Extract trading UI to separate component [\#449](https://github.com/rubykube/peatio/pull/449) ([dinesh-skyach](https://github.com/dinesh-skyach))

## [1.0.0](https://github.com/rubykube/peatio/tree/1.0.0) (2018-02-19)
[Full Changelog](https://github.com/rubykube/peatio/compare/0.2.5...1.0.0)

**Closed issues:**

- Peatio documentation update [\#544](https://github.com/rubykube/peatio/issues/544)
- Incompatible character encodings: ASCII-8BIT and UTF-8 [\#541](https://github.com/rubykube/peatio/issues/541)
- Error in production [\#540](https://github.com/rubykube/peatio/issues/540)
- Please Update Install Documents [\#536](https://github.com/rubykube/peatio/issues/536)
- Add ability to customize page metadata: title, desc & keywords [\#530](https://github.com/rubykube/peatio/issues/530)
- Update omniauth-barong gem [\#524](https://github.com/rubykube/peatio/issues/524)
- Sentry is missing at markets page [\#520](https://github.com/rubykube/peatio/issues/520)
- Add ability to add custom stylesheet for landing & application pages [\#519](https://github.com/rubykube/peatio/issues/519)
- Store OAuth2 token in Authorization\#secret [\#518](https://github.com/rubykube/peatio/issues/518)
- Replace ROTP gem in favor of custom generator [\#516](https://github.com/rubykube/peatio/issues/516)
- Ability to dynamically change the css for trading page [\#513](https://github.com/rubykube/peatio/issues/513)
- Yarn Error [\#512](https://github.com/rubykube/peatio/issues/512)
- Button "accept" missed up [\#511](https://github.com/rubykube/peatio/issues/511)
- Support for Ripple [\#508](https://github.com/rubykube/peatio/issues/508)
- Refactor fiat deposits to match new behavior [\#507](https://github.com/rubykube/peatio/issues/507)
- Add form to admin rubric which allows to manually create deposit [\#506](https://github.com/rubykube/peatio/issues/506)
- Fix errors preventing fiat deposit from working [\#503](https://github.com/rubykube/peatio/issues/503)
- Add support for member levels and delete KyC [\#499](https://github.com/rubykube/peatio/issues/499)
- Changing style have problem [\#497](https://github.com/rubykube/peatio/issues/497)
- If withdraw fails amount should be put back to balance [\#494](https://github.com/rubykube/peatio/issues/494)
- API Documentation of Locally Installed Peatio [\#487](https://github.com/rubykube/peatio/issues/487)
- Add withdraw\_channels & deposit\_channels to generators [\#485](https://github.com/rubykube/peatio/issues/485)
- When manually depositing fiat currency in admin panel transaction should be created and listed at history [\#483](https://github.com/rubykube/peatio/issues/483)
- USD markets list is empty [\#482](https://github.com/rubykube/peatio/issues/482)
- Cannot find translation at bank deposit/withdraw page [\#481](https://github.com/rubykube/peatio/issues/481)
- Not recognizing my email as Admin in application.yml [\#480](https://github.com/rubykube/peatio/issues/480)
- Need to fix travis CI after pr \#466 merge [\#476](https://github.com/rubykube/peatio/issues/476)
- Specs are failing in devel due to \#466 [\#475](https://github.com/rubykube/peatio/issues/475)
- Create api call to destroy withdraw addresses [\#473](https://github.com/rubykube/peatio/issues/473)
- Google Auth error "Wrong customer ID or password,please try again." [\#470](https://github.com/rubykube/peatio/issues/470)
- On the trading interface [\#468](https://github.com/rubykube/peatio/issues/468)
- Still a problem with the withdraw, here with BTC [\#467](https://github.com/rubykube/peatio/issues/467)
- Alternative for pusher [\#464](https://github.com/rubykube/peatio/issues/464)
- ActionView::Template::Error: wrong number of arguments \(given 1, expected 0\) at /admin/withdraws/banks [\#462](https://github.com/rubykube/peatio/issues/462)
- NoMethodError: undefined method `\[\]' for nil:NilClass at /api/v2/k\_with\_pending\_trades.json [\#461](https://github.com/rubykube/peatio/issues/461)
- Markets switcher doesn't work [\#460](https://github.com/rubykube/peatio/issues/460)
- Google Auth Problem [\#457](https://github.com/rubykube/peatio/issues/457)
- POST /api/v2/withdraws requires amount to be integer only [\#452](https://github.com/rubykube/peatio/issues/452)
- Add opportunity set value withdraw fee [\#451](https://github.com/rubykube/peatio/issues/451)
- Real Name Auth has problem [\#448](https://github.com/rubykube/peatio/issues/448)
- New currencies not displayed for old users [\#447](https://github.com/rubykube/peatio/issues/447)
- BitGo Express REST API for withdraw sometimes requires OTP [\#446](https://github.com/rubykube/peatio/issues/446)
- Add support for BitcoinWhite [\#445](https://github.com/rubykube/peatio/issues/445)
- No signin/signup buttons on kubernetes deployment [\#444](https://github.com/rubykube/peatio/issues/444)
- dotenv [\#443](https://github.com/rubykube/peatio/issues/443)
- Docker persist data [\#442](https://github.com/rubykube/peatio/issues/442)
- Can't access admin. Have added email to application.yml [\#441](https://github.com/rubykube/peatio/issues/441)
- Adding Trollbox in Market [\#440](https://github.com/rubykube/peatio/issues/440)
- Docker tag mismatch 0.2.4 and 0.2.5 [\#439](https://github.com/rubykube/peatio/issues/439)
- Market doesnt work after adding USD currencies [\#438](https://github.com/rubykube/peatio/issues/438)
- When we add new currencies to a deployment, old users don't have wallets for the new currencies [\#436](https://github.com/rubykube/peatio/issues/436)
- Example Setup MySQL  [\#433](https://github.com/rubykube/peatio/issues/433)
- Responsive issue [\#432](https://github.com/rubykube/peatio/issues/432)
- ArgumentError: wrong number of arguments \(given 2, expected 0..1\) at markets when submitting order with zero volume [\#422](https://github.com/rubykube/peatio/issues/422)
- After adding new coin admin/withdraw/coins doesnt work [\#421](https://github.com/rubykube/peatio/issues/421)
- Undefined method balance for CoinAPI::BitGo [\#418](https://github.com/rubykube/peatio/issues/418)
- Add missing coin\_api/ltc.rb \(migrate coin\_rpc/ltc.rb\) [\#414](https://github.com/rubykube/peatio/issues/414)
- Realtime data always 0 [\#413](https://github.com/rubykube/peatio/issues/413)
- After adding new coin Old users didint see it [\#409](https://github.com/rubykube/peatio/issues/409)
- Add BASE\_FIAT\_CCY=USD environment variable which defines the base fiat currency [\#408](https://github.com/rubykube/peatio/issues/408)
- Merge POST withdraws API into devel [\#407](https://github.com/rubykube/peatio/issues/407)
- Markets page should update list of orders when order is created [\#405](https://github.com/rubykube/peatio/issues/405)
- Production deployment v2.0 [\#401](https://github.com/rubykube/peatio/issues/401)
- Can't deposit funds [\#399](https://github.com/rubykube/peatio/issues/399)
- Add GET \(index only\) & POST /withdrawals/addresses [\#394](https://github.com/rubykube/peatio/issues/394)
- Sprockets::FileNotFound in Welcome\#index  [\#392](https://github.com/rubykube/peatio/issues/392)
- Ability to configure the PEATIO text which is displayed on the market page header [\#391](https://github.com/rubykube/peatio/issues/391)
- Can't connect Mysql [\#390](https://github.com/rubykube/peatio/issues/390)
- Docker peatio-specs not coming up [\#389](https://github.com/rubykube/peatio/issues/389)
- Is the Dockerfile working [\#388](https://github.com/rubykube/peatio/issues/388)
- Rake db:setup returns syntax error [\#383](https://github.com/rubykube/peatio/issues/383)
- Access admin module and approve profile [\#382](https://github.com/rubykube/peatio/issues/382)
- Naviagating to /admin/ reroutes to root [\#377](https://github.com/rubykube/peatio/issues/377)
- Add omniauth-barong gem [\#376](https://github.com/rubykube/peatio/issues/376)
- documentation issues. [\#375](https://github.com/rubykube/peatio/issues/375)
- Fiat deposit screen [\#374](https://github.com/rubykube/peatio/issues/374)
- Remove Twilio leftovers from application.yml [\#373](https://github.com/rubykube/peatio/issues/373)
- Getting 404 from Google when trying to login  [\#370](https://github.com/rubykube/peatio/issues/370)
- Remove hardcoded host in API docs and use headers\['Host'\] [\#367](https://github.com/rubykube/peatio/issues/367)
- File system exhaustion on exception while handling AMPQ messages [\#364](https://github.com/rubykube/peatio/issues/364)
- Remove gem amqp [\#353](https://github.com/rubykube/peatio/issues/353)
- Update aasm to 4.x [\#352](https://github.com/rubykube/peatio/issues/352)
- Add markets API [\#349](https://github.com/rubykube/peatio/issues/349)
- Add support for Dash [\#346](https://github.com/rubykube/peatio/issues/346)
- Move hardcoded config files into database and make them dynamic [\#344](https://github.com/rubykube/peatio/issues/344)
- Find and fix incompatibilities in Peatio's JSON RPC with BitGo [\#339](https://github.com/rubykube/peatio/issues/339)
- Bundle-audit on current codebase  [\#337](https://github.com/rubykube/peatio/issues/337)
- Brakeman audit on current codebase [\#336](https://github.com/rubykube/peatio/issues/336)
- Find a way to get God log to STDOUT / STDERR instead of files [\#335](https://github.com/rubykube/peatio/issues/335)
- Add support for Litecoin [\#333](https://github.com/rubykube/peatio/issues/333)
- Add support for Bitcoin Cash [\#332](https://github.com/rubykube/peatio/issues/332)
- Not seeing candle sticks on trade page [\#324](https://github.com/rubykube/peatio/issues/324)
- Ability to list withdraws using API [\#316](https://github.com/rubykube/peatio/issues/316)
- Trad page showing blank  [\#309](https://github.com/rubykube/peatio/issues/309)
- BTC Deposit : Address not showing    [\#308](https://github.com/rubykube/peatio/issues/308)
- Per Trade fee  [\#304](https://github.com/rubykube/peatio/issues/304)
- coininfo page [\#303](https://github.com/rubykube/peatio/issues/303)
- Revert fund\_source to fund\_source\_id [\#301](https://github.com/rubykube/peatio/issues/301)
- Create admin rubric which allows to manually deposit USD [\#300](https://github.com/rubykube/peatio/issues/300)
- Create configuration variables which should be used to specify active OAuth providers [\#299](https://github.com/rubykube/peatio/issues/299)
- Balance should be rounded with higher precision [\#287](https://github.com/rubykube/peatio/issues/287)
- Squash database migrations in single file [\#286](https://github.com/rubykube/peatio/issues/286)
- Is there an easier way to add new coins? [\#284](https://github.com/rubykube/peatio/issues/284)
- Market orders by price instead of volume [\#264](https://github.com/rubykube/peatio/issues/264)
- how to install [\#191](https://github.com/rubykube/peatio/issues/191)
- Refreshing the page creates new API token [\#182](https://github.com/rubykube/peatio/issues/182)
- Trading Page is blank /markets/btccny [\#115](https://github.com/rubykube/peatio/issues/115)
- How add the Cryptonote coin [\#113](https://github.com/rubykube/peatio/issues/113)
- Conditionally require omniauth providers based on application config [\#30](https://github.com/rubykube/peatio/issues/30)
- Start using Yarn for asset dependencies [\#23](https://github.com/rubykube/peatio/issues/23)
- Clean up database seeds, generate admin account from Helm [\#21](https://github.com/rubykube/peatio/issues/21)

**Merged pull requests:**

- Annotate schema information for models [\#546](https://github.com/rubykube/peatio/pull/546) ([yivo](https://github.com/yivo))
- Documentation for local development environment setup with docker [\#545](https://github.com/rubykube/peatio/pull/545) ([ysv](https://github.com/ysv))
- Merge devel branch for the release candidate 1.0.0 [\#543](https://github.com/rubykube/peatio/pull/543) ([mod](https://github.com/mod))
- Fix issue with bad encoded character \(\#541\) [\#542](https://github.com/rubykube/peatio/pull/542) ([ysv](https://github.com/ysv))
- Updating documentations [\#539](https://github.com/rubykube/peatio/pull/539) ([mod](https://github.com/mod))
- Add ability to optionally disable member and markets UI [\#534](https://github.com/rubykube/peatio/pull/534) ([ysv](https://github.com/ysv))
- Release v1.0.0-alpha RC1 [\#531](https://github.com/rubykube/peatio/pull/531) ([mod](https://github.com/mod))
- Allow to customize page metadata: title, desc & keywords. [\#529](https://github.com/rubykube/peatio/pull/529) ([yivo](https://github.com/yivo))
- Refactor fiat deposits to match new behavior [\#528](https://github.com/rubykube/peatio/pull/528) ([ysv](https://github.com/ysv))
- Add missing Sentry at markets page [\#527](https://github.com/rubykube/peatio/pull/527) ([yivo](https://github.com/yivo))
- Update omniauth-barong to 0.1.2 and lock the min version to the same [\#526](https://github.com/rubykube/peatio/pull/526) ([yivo](https://github.com/yivo))
- Store OAuth2 access token for downloading profile in future. Add task barong:levels for refreshing access level for Barong members. [\#525](https://github.com/rubykube/peatio/pull/525) ([yivo](https://github.com/yivo))
- Replace ROTP gem in favor of custom generator [\#523](https://github.com/rubykube/peatio/pull/523) ([yivo](https://github.com/yivo))
- Add ability to include custom stylesheet for landing, funds, api\_v2 & application layouts. [\#522](https://github.com/rubykube/peatio/pull/522) ([yivo](https://github.com/yivo))
- Add missing «Accept» button for withdraw \(admin panel\) [\#515](https://github.com/rubykube/peatio/pull/515) ([yivo](https://github.com/yivo))
- Add ability to include custom stylesheets for markets page [\#514](https://github.com/rubykube/peatio/pull/514) ([yivo](https://github.com/yivo))
- Add form to admin rubric which allows to manually create deposit [\#509](https://github.com/rubykube/peatio/pull/509) ([ysv](https://github.com/ysv))
- Fix errors preventing fiat deposit from working \(\#503\) [\#505](https://github.com/rubykube/peatio/pull/505) ([ysv](https://github.com/ysv))
- Revert "Create admin rubric which allows to manually deposit USD" \(\#483\) [\#504](https://github.com/rubykube/peatio/pull/504) ([Liapin](https://github.com/Liapin))
- Replace KyC with member level [\#502](https://github.com/rubykube/peatio/pull/502) ([yivo](https://github.com/yivo))
- If withdraw fails amount is put back to balance [\#501](https://github.com/rubykube/peatio/pull/501) ([ysv](https://github.com/ysv))
- Fix processing transaction behavior. [\#500](https://github.com/rubykube/peatio/pull/500) ([k1T4eR](https://github.com/k1T4eR))
- Add support for Ethereum \(BitGo\) [\#495](https://github.com/rubykube/peatio/pull/495) ([ysv](https://github.com/ysv))
- Add withdraw\_channels & deposit\_channels to generators [\#486](https://github.com/rubykube/peatio/pull/486) ([ysv](https://github.com/ysv))
- Remove duplicate stuff for currencies: rewrite loops, cleanup controllers & unify lot of views [\#484](https://github.com/rubykube/peatio/pull/484) ([yivo](https://github.com/yivo))
- Add API call for deleting withdraw address [\#479](https://github.com/rubykube/peatio/pull/479) ([ec](https://github.com/ec))
- Remove state «almost\_done» from withdraw and dispatch failed API calls to «failed» state \(closes \#476\). [\#478](https://github.com/rubykube/peatio/pull/478) ([ysv](https://github.com/ysv))
-  Fix specs falling due to \#466 [\#477](https://github.com/rubykube/peatio/pull/477) ([ysv](https://github.com/ysv))
- k\_with\_pending\_trades fix undefined method '\[\]' error [\#474](https://github.com/rubykube/peatio/pull/474) ([ysv](https://github.com/ysv))
- Markets switcher fix after ability to define the base fiat currency \(\#460\) [\#472](https://github.com/rubykube/peatio/pull/472) ([ysv](https://github.com/ysv))
- Frontend sign in through Peatio [\#466](https://github.com/rubykube/peatio/pull/466) ([dmk](https://github.com/dmk))
- Fix markets switcher \(\#460\) [\#465](https://github.com/rubykube/peatio/pull/465) ([ysv](https://github.com/ysv))
- Fix \#462: ActionView::Template::Error: wrong number of arguments \(given 1, expected 0\) at /admin/withdraws/banks [\#463](https://github.com/rubykube/peatio/pull/463) ([yivo](https://github.com/yivo))
- Docker image tag mismatch & abbility to use custom VERSION [\#458](https://github.com/rubykube/peatio/pull/458) ([ysv](https://github.com/ysv))
- Added opportunity set value of withdraw fee in withdraw\_channels.yml [\#456](https://github.com/rubykube/peatio/pull/456) ([ysv](https://github.com/ysv))
- \[WIP\] POST /api/v2/withdraws allows amount to be fraction number \(\#452\) [\#454](https://github.com/rubykube/peatio/pull/454) ([ysv](https://github.com/ysv))
- Add new rake task: accounts:touch \(\#436\) [\#450](https://github.com/rubykube/peatio/pull/450) ([ysv](https://github.com/ysv))
- Add missing HTML code for «Solvency» page & change transparent background for LTC to white icon [\#431](https://github.com/rubykube/peatio/pull/431) ([yivo](https://github.com/yivo))
- Bugfixes for coins.rb & amqp:deposit\_coin daemons found after BitGo integration [\#430](https://github.com/rubykube/peatio/pull/430) ([yivo](https://github.com/yivo))
- Add missing "entries" key for CoinAPI::BTC\#load\_deposit! and minor fixes for Bitcoind [\#428](https://github.com/rubykube/peatio/pull/428) ([yivo](https://github.com/yivo))
- Add support for Dash [\#425](https://github.com/rubykube/peatio/pull/425) ([yivo](https://github.com/yivo))
- Fix ArgumentError \(issue 422\) [\#424](https://github.com/rubykube/peatio/pull/424) ([yivo](https://github.com/yivo))
- Undefined method balance for CoinAPI::BitGo [\#419](https://github.com/rubykube/peatio/pull/419) ([ymasiuk](https://github.com/ymasiuk))
- Remove hardcoded host in API docs [\#417](https://github.com/rubykube/peatio/pull/417) ([ymasiuk](https://github.com/ymasiuk))
- Add missing coin\_api/ltc.rb [\#416](https://github.com/rubykube/peatio/pull/416) ([ymasiuk](https://github.com/ymasiuk))
- Remove Twilio leftovers from application.yml [\#415](https://github.com/rubykube/peatio/pull/415) ([ymasiuk](https://github.com/ymasiuk))
- Add ability to define the base fiat currency  [\#411](https://github.com/rubykube/peatio/pull/411) ([ysv](https://github.com/ysv))
- POST /api/v2/withdraws [\#410](https://github.com/rubykube/peatio/pull/410) ([ysv](https://github.com/ysv))
- Add BCH & LTC support [\#402](https://github.com/rubykube/peatio/pull/402) ([yivo](https://github.com/yivo))
- Fix issue preventing Docker container from build. Also fix docs issues. [\#400](https://github.com/rubykube/peatio/pull/400) ([yivo](https://github.com/yivo))
- Add GET \(index only\) & POST /withdrawals/addresses\(\#394\) [\#398](https://github.com/rubykube/peatio/pull/398) ([ysv](https://github.com/ysv))
- Ability to configure text which is displayed on the market page header\(\#391\) [\#393](https://github.com/rubykube/peatio/pull/393) ([ysv](https://github.com/ysv))
-  Add omniauth-barong gem\(\#376\) [\#385](https://github.com/rubykube/peatio/pull/385) ([ysv](https://github.com/ysv))
- \[Fix \#287\] Change balance precision in markets. [\#379](https://github.com/rubykube/peatio/pull/379) ([k1T4eR](https://github.com/k1T4eR))
- Fiat deposit screen invalid protocol name \(\#374\) [\#378](https://github.com/rubykube/peatio/pull/378) ([ysv](https://github.com/ysv))
- Remove gem amqp [\#372](https://github.com/rubykube/peatio/pull/372) ([ysv](https://github.com/ysv))
- Update aasm to 4.x [\#369](https://github.com/rubykube/peatio/pull/369) ([ysv](https://github.com/ysv))
- Fix layout for API doc [\#366](https://github.com/rubykube/peatio/pull/366) ([yivo](https://github.com/yivo))
- \[Fix \#301\] Revert fund\_source to fund\_source\_id. [\#365](https://github.com/rubykube/peatio/pull/365) ([k1T4eR](https://github.com/k1T4eR))
- Make GOD log to STDOUT in Docker env \(fixes \#335\) [\#363](https://github.com/rubykube/peatio/pull/363) ([shal](https://github.com/shal))
- Ability to manage rails force\_ssl option from environment [\#361](https://github.com/rubykube/peatio/pull/361) ([calj](https://github.com/calj))
- Create configuration variables which should be used to specify active OAuth providers [\#357](https://github.com/rubykube/peatio/pull/357) ([ysv](https://github.com/ysv))
- Issue refreshing the page creates new api token [\#356](https://github.com/rubykube/peatio/pull/356) ([dinesh-skyach](https://github.com/dinesh-skyach))
- BitGo support [\#355](https://github.com/rubykube/peatio/pull/355) ([yivo](https://github.com/yivo))
- Create admin rubric which allows to manually deposit USD [\#354](https://github.com/rubykube/peatio/pull/354) ([ysv](https://github.com/ysv))
- Security fixes according to Brakeman [\#350](https://github.com/rubykube/peatio/pull/350) ([vpetrusenko](https://github.com/vpetrusenko))
- Replace rest-client in favor of faraday & update rack-attack \(security issues \#337\) [\#348](https://github.com/rubykube/peatio/pull/348) ([vpetrusenko](https://github.com/vpetrusenko))
- Squash database migrations in single file [\#343](https://github.com/rubykube/peatio/pull/343) ([shal](https://github.com/shal))
- Add ability to list withdraws using API [\#338](https://github.com/rubykube/peatio/pull/338) ([yivo](https://github.com/yivo))
- Add support for Bitcoin Cash [\#331](https://github.com/rubykube/peatio/pull/331) ([yivo](https://github.com/yivo))

## [0.2.5](https://github.com/rubykube/peatio/tree/0.2.5) (2018-01-23)
[Full Changelog](https://github.com/rubykube/peatio/compare/0.2.4...0.2.5)

**Closed issues:**

- bundle exec rake assets:precompile issue [\#328](https://github.com/rubykube/peatio/issues/328)
- Error gem install atomic -v '1.1.99' [\#327](https://github.com/rubykube/peatio/issues/327)
- ActionView::Template::Error \(couldn't find file 'yarn\_components/raven-js/dist/raven' with type 'application/javascript' [\#326](https://github.com/rubykube/peatio/issues/326)
- Missing raven-js [\#323](https://github.com/rubykube/peatio/issues/323)
- Move to Ruby 2.5 [\#317](https://github.com/rubykube/peatio/issues/317)
- CoinRPC\#sendtoaddress requires real number with maximum 8 decimal places but Peatio may send more \(withdraw\) [\#310](https://github.com/rubykube/peatio/issues/310)
- Write rake task which sends test email to specified address \(useful for testing mails\) [\#302](https://github.com/rubykube/peatio/issues/302)
- RabbitMQ doesn't requeue messages which consumer failed to process [\#298](https://github.com/rubykube/peatio/issues/298)
- Install exception reporting software which should be configurable [\#296](https://github.com/rubykube/peatio/issues/296)
- Prevent ActiveRecord exceptions from being silenced  [\#295](https://github.com/rubykube/peatio/issues/295)
- Remove sign in and sign up [\#291](https://github.com/rubykube/peatio/issues/291)
- Withdraws::Withdrawable\#create has became empty after removal of 2FA [\#290](https://github.com/rubykube/peatio/issues/290)
- Withdrawal of crypto \(both BTC & XRP\) not working [\#285](https://github.com/rubykube/peatio/issues/285)
- Issues with fees [\#280](https://github.com/rubykube/peatio/issues/280)
- Fiat deposits not working [\#276](https://github.com/rubykube/peatio/issues/276)
- Make SMTP username, password and authentication type optional  [\#271](https://github.com/rubykube/peatio/issues/271)
- Translations has been deleted but link still exists [\#269](https://github.com/rubykube/peatio/issues/269)
- Remove lib/tasks/migration.rake [\#268](https://github.com/rubykube/peatio/issues/268)
- Delete unneeded images & locales [\#267](https://github.com/rubykube/peatio/issues/267)
- Strip captcha feature [\#266](https://github.com/rubykube/peatio/issues/266)
- RabbitMQ server disconnects long-running clients [\#261](https://github.com/rubykube/peatio/issues/261)
- Fix markets sorting [\#260](https://github.com/rubykube/peatio/issues/260)
- Remove malformed currency symbol from title at page «Trade» [\#258](https://github.com/rubykube/peatio/issues/258)
- Delete locales leaving only English, French & Russian [\#256](https://github.com/rubykube/peatio/issues/256)
- Precompiled assets are broken at «Funds» page [\#253](https://github.com/rubykube/peatio/issues/253)
- Leftovers after acts-as-taggable-on removal [\#249](https://github.com/rubykube/peatio/issues/249)
- Deletion of orders doesn't seem to work [\#248](https://github.com/rubykube/peatio/issues/248)
- ChromeDriver constantly stucks [\#244](https://github.com/rubykube/peatio/issues/244)
- Errors of data processing in loops may stop newer data for being processed \(stucks the whole application, daemons moustly\) [\#243](https://github.com/rubykube/peatio/issues/243)
- No job rescheduling in daemons when exception is raised [\#242](https://github.com/rubykube/peatio/issues/242)
- Generation of deposit address doesn't work stable: randomly isn't generated [\#241](https://github.com/rubykube/peatio/issues/241)
- Leverage SMTP configuration using application.yml [\#239](https://github.com/rubykube/peatio/issues/239)
- Issue viewing documents in admin panel at «Verify Account» page [\#237](https://github.com/rubykube/peatio/issues/237)
- Remove lib/tasks/deploy.rake [\#230](https://github.com/rubykube/peatio/issues/230)
- Remove lib/tasks/install.rake [\#226](https://github.com/rubykube/peatio/issues/226)
- Leftovers after removal of 2FA: member phone number & Phonelib [\#225](https://github.com/rubykube/peatio/issues/225)
- Remove running accounts [\#221](https://github.com/rubykube/peatio/issues/221)
- Remove signup history [\#220](https://github.com/rubykube/peatio/issues/220)
- Remove gem acts-as-taggable-on [\#219](https://github.com/rubykube/peatio/issues/219)
- Update OmniAuth & OmniAuth providers to the latest version  [\#216](https://github.com/rubykube/peatio/issues/216)
- Logs should go to stdout/stderr especially when running in Docker/Kubernetes [\#201](https://github.com/rubykube/peatio/issues/201)
- Leftovers after refactoring of CNY =\> USD [\#200](https://github.com/rubykube/peatio/issues/200)
- Missing translation at «Trade» [\#199](https://github.com/rubykube/peatio/issues/199)
- Button «Copy deposit address» at «Funds» is broken [\#197](https://github.com/rubykube/peatio/issues/197)
- Button «Reject» doesn't work while editing KYC document  [\#188](https://github.com/rubykube/peatio/issues/188)
- Admin rubric "Documents" doesn't work at all [\#187](https://github.com/rubykube/peatio/issues/187)
- User should not be able to focus disabled fields when editing proof [\#186](https://github.com/rubykube/peatio/issues/186)
- Multiple admin menu rubrics receive "active" state as the same time [\#185](https://github.com/rubykube/peatio/issues/185)
- Add MailCatcher for testing mails in development environment [\#184](https://github.com/rubykube/peatio/issues/184)
- Missing translations for flash message in case member is disabled  [\#183](https://github.com/rubykube/peatio/issues/183)
- Remove leftovers after removal of 2fa auth [\#172](https://github.com/rubykube/peatio/issues/172)
- Update gem bunny [\#157](https://github.com/rubykube/peatio/issues/157)
- Error when you try to withdraw 0 from wallet with zero balance  [\#130](https://github.com/rubykube/peatio/issues/130)
- No way to customize RAILS\_ENV when building Docker image [\#126](https://github.com/rubykube/peatio/issues/126)
- Spec is failing \(seed 13602\) [\#88](https://github.com/rubykube/peatio/issues/88)
- Use $ as the default currency [\#67](https://github.com/rubykube/peatio/issues/67)
- Remove gem "unread" [\#40](https://github.com/rubykube/peatio/issues/40)
- Remove built-in ticketing system [\#22](https://github.com/rubykube/peatio/issues/22)
- Create a demo/test database with faker and factorybot [\#16](https://github.com/rubykube/peatio/issues/16)

**Merged pull requests:**

- Update ruby version to 2.5.0 [\#340](https://github.com/rubykube/peatio/pull/340) ([shal](https://github.com/shal))
- Add config/initializers/exception\_reporting.rb which adds utils for reporting exceptions to screen and / or exception tracking software \(ETS\). [\#330](https://github.com/rubykube/peatio/pull/330) ([yivo](https://github.com/yivo))
- Fix types of compared data \(String was compared with Symbols\) in Member\#touch\_accounts [\#329](https://github.com/rubykube/peatio/pull/329) ([yivo](https://github.com/yivo))
- Add WebhooksController for processing deposits [\#322](https://github.com/rubykube/peatio/pull/322) ([ysv](https://github.com/ysv))
- Allow to customize appearance by ENV. [\#321](https://github.com/rubykube/peatio/pull/321) ([yivo](https://github.com/yivo))
- Link configuration files in production env [\#320](https://github.com/rubykube/peatio/pull/320) ([calj](https://github.com/calj))
- Manually invoke AASM's after\_commit \(send\_coins + send\_email\) hook when performing withdraw audit \(see comments, this is temporary fix\). [\#319](https://github.com/rubykube/peatio/pull/319) ([yivo](https://github.com/yivo))
- Use 0.15% as fee for all markets. Increase quick\_withdraw\_max amount. [\#318](https://github.com/rubykube/peatio/pull/318) ([ysv](https://github.com/ysv))
- Fix precision for satoshi currency [\#315](https://github.com/rubykube/peatio/pull/315) ([ysv](https://github.com/ysv))
- Add Telegram badge [\#314](https://github.com/rubykube/peatio/pull/314) ([yivo](https://github.com/yivo))
- Add Sentry \(error tracking software\) [\#313](https://github.com/rubykube/peatio/pull/313) ([yivo](https://github.com/yivo))
- Add missing descriptions for Rake tasks [\#312](https://github.com/rubykube/peatio/pull/312) ([yivo](https://github.com/yivo))
- Add LICENSE.md [\#311](https://github.com/rubykube/peatio/pull/311) ([yivo](https://github.com/yivo))
- Fixed SMTP settings [\#307](https://github.com/rubykube/peatio/pull/307) ([vshatravenko](https://github.com/vshatravenko))
- Add peatio:mailer:testshot Rake task. [\#305](https://github.com/rubykube/peatio/pull/305) ([yivo](https://github.com/yivo))
- General bugfixes and stability improvements for daemons [\#297](https://github.com/rubykube/peatio/pull/297) ([yivo](https://github.com/yivo))
- Make SMTP credentials optional which is required by sSMTP [\#294](https://github.com/rubykube/peatio/pull/294) ([yivo](https://github.com/yivo))
- Build Docker container in TravisCI. [\#293](https://github.com/rubykube/peatio/pull/293) ([yivo](https://github.com/yivo))
- Configure TravisCI to send notifications to Slack. [\#292](https://github.com/rubykube/peatio/pull/292) ([yivo](https://github.com/yivo))
- Fix errors causing fiat deposits & withdraw to be broken [\#288](https://github.com/rubykube/peatio/pull/288) ([vpetrusenko](https://github.com/vpetrusenko))
- Change to strict variants of methods to improve debug tools [\#282](https://github.com/rubykube/peatio/pull/282) ([ec](https://github.com/ec))
- Fix broken «Reject» button while editing KYC document [\#278](https://github.com/rubykube/peatio/pull/278) ([spavlishak](https://github.com/spavlishak))
- Remove invalid link «How to verify» at «Solvency» [\#277](https://github.com/rubykube/peatio/pull/277) ([spavlishak](https://github.com/spavlishak))
- Delete unneeded images & locales [\#273](https://github.com/rubykube/peatio/pull/273) ([gfedorenko](https://github.com/gfedorenko))
- Remove lib/tasks/migration.rake [\#272](https://github.com/rubykube/peatio/pull/272) ([gfedorenko](https://github.com/gfedorenko))
- Remove captcha [\#270](https://github.com/rubykube/peatio/pull/270) ([spavlishak](https://github.com/spavlishak))
- Update omniauth gems [\#265](https://github.com/rubykube/peatio/pull/265) ([spavlishak](https://github.com/spavlishak))
-  Remove malformed currency symbol from title at page «Trade» [\#263](https://github.com/rubykube/peatio/pull/263) ([spavlishak](https://github.com/spavlishak))
- Delete all unnecessary locales and translations [\#262](https://github.com/rubykube/peatio/pull/262) ([gfedorenko](https://github.com/gfedorenko))
- Precompiled assets are broken at «Funds» page [\#259](https://github.com/rubykube/peatio/pull/259) ([ysv](https://github.com/ysv))
- Bunny update to v2.9 \(the latest stable\) \(\#157\) [\#257](https://github.com/rubykube/peatio/pull/257) ([ec](https://github.com/ec))
- Reload page after the order gets deleted \(fixes \#248 and \#88\). [\#255](https://github.com/rubykube/peatio/pull/255) ([gfedorenko](https://github.com/gfedorenko))
- Remove sign in and sign up [\#252](https://github.com/rubykube/peatio/pull/252) ([vpetrusenko](https://github.com/vpetrusenko))
- Add .travis.yml [\#251](https://github.com/rubykube/peatio/pull/251) ([yivo](https://github.com/yivo))
- Leftovers after acts-as-taggable-on removal \(member\_tags.yml\) [\#250](https://github.com/rubykube/peatio/pull/250) ([gfedorenko](https://github.com/gfedorenko))
- Fix issues with ChromeDriver when it constantly stucks preventing specs from run [\#247](https://github.com/rubykube/peatio/pull/247) ([yivo](https://github.com/yivo))
- Leverage SMTP configuration using application.yml [\#246](https://github.com/rubykube/peatio/pull/246) ([gfedorenko](https://github.com/gfedorenko))
- Remove leftovers after removal of 2FA: member phone number & Phonelib [\#245](https://github.com/rubykube/peatio/pull/245) ([ymasiuk](https://github.com/ymasiuk))
- Fix viewing documents in admin panel at «Verify Account» page [\#238](https://github.com/rubykube/peatio/pull/238) ([ysv](https://github.com/ysv))
- Deleted deploy.rake [\#234](https://github.com/rubykube/peatio/pull/234) ([gfedorenko](https://github.com/gfedorenko))
- Remove sign up history [\#233](https://github.com/rubykube/peatio/pull/233) ([gfedorenko](https://github.com/gfedorenko))
- Delete lib/tasks/install.rake [\#229](https://github.com/rubykube/peatio/pull/229) ([gfedorenko](https://github.com/gfedorenko))
- Conditionally access «document\_translations» table in migration \(fixes broken database migration\) [\#228](https://github.com/rubykube/peatio/pull/228) ([gfedorenko](https://github.com/gfedorenko))
- Add Test::Controller which provides HTTP GET /test/members, add rake peatio:test:tear{up|down} [\#227](https://github.com/rubykube/peatio/pull/227) ([yivo](https://github.com/yivo))
- Remove gem acts-as-taggable-on [\#224](https://github.com/rubykube/peatio/pull/224) ([gfedorenko](https://github.com/gfedorenko))
- Remove running accounts [\#223](https://github.com/rubykube/peatio/pull/223) ([ymasiuk](https://github.com/ymasiuk))
- Remove built-in ticketing system [\#222](https://github.com/rubykube/peatio/pull/222) ([gfedorenko](https://github.com/gfedorenko))
- Log to file in test environment [\#218](https://github.com/rubykube/peatio/pull/218) ([yivo](https://github.com/yivo))
- Remove app/models/document [\#217](https://github.com/rubykube/peatio/pull/217) ([yivo](https://github.com/yivo))
- Reenable accidentally disabled force\_ssl. [\#214](https://github.com/rubykube/peatio/pull/214) ([yivo](https://github.com/yivo))
- Fix broken button «Copy deposit address» at «Funds» [\#213](https://github.com/rubykube/peatio/pull/213) ([ymasiuk](https://github.com/ymasiuk))
- Configure Rails.logger so it always logs to STDOUT instead of log/production.log [\#212](https://github.com/rubykube/peatio/pull/212) ([yivo](https://github.com/yivo))
- Drop Node.js system dependency in favor of embedded V8 engine \(currently v.6.3.x\). [\#211](https://github.com/rubykube/peatio/pull/211) ([yivo](https://github.com/yivo))
- Add MailCatcher for testing mails in development environment [\#210](https://github.com/rubykube/peatio/pull/210) ([ymasiuk](https://github.com/ymasiuk))
- Leftovers after refactoring of CNY =\> USD [\#209](https://github.com/rubykube/peatio/pull/209) ([ymasiuk](https://github.com/ymasiuk))
- Allow to customize RAILS\_ENV when building image. [\#205](https://github.com/rubykube/peatio/pull/205) ([yivo](https://github.com/yivo))
- Add .dockerignore. [\#204](https://github.com/rubykube/peatio/pull/204) ([yivo](https://github.com/yivo))
- Single AMQP channel per daemon. [\#203](https://github.com/rubykube/peatio/pull/203) ([yivo](https://github.com/yivo))
- Silence Ripple RPC errors to prevent script from failing and leaving all other currencies unprocessed. [\#202](https://github.com/rubykube/peatio/pull/202) ([yivo](https://github.com/yivo))
- Add guides on how to get BTC and XRP in testnet. [\#198](https://github.com/rubykube/peatio/pull/198) ([yivo](https://github.com/yivo))
- Remove leftovers after removal of 2fa auth [\#196](https://github.com/rubykube/peatio/pull/196) ([ymasiuk](https://github.com/ymasiuk))
- Prevent user from focusing on disabled form elements when editing proof [\#195](https://github.com/rubykube/peatio/pull/195) ([ymasiuk](https://github.com/ymasiuk))
- Update charts [\#194](https://github.com/rubykube/peatio/pull/194) ([dmk](https://github.com/dmk))
- Fix translations for flash message in case member is disabled [\#192](https://github.com/rubykube/peatio/pull/192) ([ymasiuk](https://github.com/ymasiuk))
- Change symbol ¥ to $ [\#190](https://github.com/rubykube/peatio/pull/190) ([ysv](https://github.com/ysv))
- Convert views/shared Slim templates to ERB [\#154](https://github.com/rubykube/peatio/pull/154) ([spavlishak](https://github.com/spavlishak))
-  Convert views/private Slim templates to ERB [\#152](https://github.com/rubykube/peatio/pull/152) ([spavlishak](https://github.com/spavlishak))
- Convert views/admin Slim templates to ERB [\#132](https://github.com/rubykube/peatio/pull/132) ([spavlishak](https://github.com/spavlishak))
- Add task which feeds database with demo members [\#96](https://github.com/rubykube/peatio/pull/96) ([yivo](https://github.com/yivo))

## [0.2.4](https://github.com/rubykube/peatio/tree/0.2.4) (2017-12-22)
[Full Changelog](https://github.com/rubykube/peatio/compare/0.2.3...0.2.4)

**Closed issues:**

- Need to fix ability to copy \(clipboard.js\) [\#167](https://github.com/rubykube/peatio/issues/167)
- Replace all peatio.com with peatio.tech [\#166](https://github.com/rubykube/peatio/issues/166)
- Remove gem meta\_request [\#165](https://github.com/rubykube/peatio/issues/165)
- Remove gem test-unit [\#164](https://github.com/rubykube/peatio/issues/164)
- Remove gem whenever \(+configs\) [\#163](https://github.com/rubykube/peatio/issues/163)
- Remove gem bcrypt [\#161](https://github.com/rubykube/peatio/issues/161)
- Remove gem jbuilder [\#160](https://github.com/rubykube/peatio/issues/160)
- Remove gem dotenv-rails [\#159](https://github.com/rubykube/peatio/issues/159)
- Replace gems pry-rails & byebug with pry-byebug [\#158](https://github.com/rubykube/peatio/issues/158)
- Remove gem launchy [\#156](https://github.com/rubykube/peatio/issues/156)
- Remove transifex [\#155](https://github.com/rubykube/peatio/issues/155)
- Redis error: ERR Client sent AUTH, but no password is set [\#133](https://github.com/rubykube/peatio/issues/133)
- Filter by markets doesn't work for XRP [\#128](https://github.com/rubykube/peatio/issues/128)
- QR code at deposits isn't rendered [\#118](https://github.com/rubykube/peatio/issues/118)
- CSRF error at withdraws [\#116](https://github.com/rubykube/peatio/issues/116)
- Error getaddrinfo: Name or service not known [\#114](https://github.com/rubykube/peatio/issues/114)
- Not possible to generate new address \(403 Forbidden\) [\#108](https://github.com/rubykube/peatio/issues/108)
- Error when you try to copy the address [\#107](https://github.com/rubykube/peatio/issues/107)
- Exception when building form at withdraws [\#104](https://github.com/rubykube/peatio/issues/104)
- Generation of new deposit address is broken [\#101](https://github.com/rubykube/peatio/issues/101)
- Several specs are failing \(seed 63928\) [\#86](https://github.com/rubykube/peatio/issues/86)
- Invalid link to Peatio GitHub repository at API Tokens page  [\#85](https://github.com/rubykube/peatio/issues/85)
- Layout issue when window is less than ~ 1000px [\#84](https://github.com/rubykube/peatio/issues/84)
- hot\_wallets daemon doesn't work because exception is raised when using Ripple JSON RPC [\#83](https://github.com/rubykube/peatio/issues/83)
- Missing translations when replying to ticket with empty message [\#82](https://github.com/rubykube/peatio/issues/82)
- Invalid paths in stylesheet when creating new document in admin panel [\#81](https://github.com/rubykube/peatio/issues/81)
- Duplicate item in "Deposits" menu in admin panel [\#80](https://github.com/rubykube/peatio/issues/80)
- No E-Mail is sent when manually registering on Peatio \(via sign up form\) [\#79](https://github.com/rubykube/peatio/issues/79)
- Outdated README: PhantomJS & ChromeDriver [\#78](https://github.com/rubykube/peatio/issues/78)
- Invalid E-Mail \(peatio.com\) in README [\#77](https://github.com/rubykube/peatio/issues/77)
- There are no headings & texts on main page when language is set to non-English  [\#76](https://github.com/rubykube/peatio/issues/76)
- When submitting invalid data to KYC form layout of date of birth input becomes broken [\#75](https://github.com/rubykube/peatio/issues/75)
- When you set phone number it actually allows to set password [\#74](https://github.com/rubykube/peatio/issues/74)
- Exception at "Solvency" page on fresh Peatio installation [\#73](https://github.com/rubykube/peatio/issues/73)
- "Funds" page doesn't work because of JS errors \(deposit & withdraw are broken\) [\#72](https://github.com/rubykube/peatio/issues/72)
- Application is shipped with different binaries than Rails defaults [\#71](https://github.com/rubykube/peatio/issues/71)
- Something strange occurs when exiting Rails application [\#70](https://github.com/rubykube/peatio/issues/70)
- Test failing with seed 17488 [\#58](https://github.com/rubykube/peatio/issues/58)
- Create complete kubernetes install documentation [\#57](https://github.com/rubykube/peatio/issues/57)
- Specs are failing due to missing ID in document [\#50](https://github.com/rubykube/peatio/issues/50)
- Specs are failing due to possible changes how capybara matches text \(after gem update\) [\#49](https://github.com/rubykube/peatio/issues/49)
- Specs are failing due to removed \#to\_d method from Rails 4.0 [\#47](https://github.com/rubykube/peatio/issues/47)
- Remove doorkeeper entirely [\#43](https://github.com/rubykube/peatio/issues/43)
- Spec features/sign\_up\_spec.rb fails when "Sign in with Google" & "Sign in with Auth0" are enabled [\#39](https://github.com/rubykube/peatio/issues/39)
- Generic JWT support [\#31](https://github.com/rubykube/peatio/issues/31)

**Merged pull requests:**

- Removed bcrypt gem \#161 [\#181](https://github.com/rubykube/peatio/pull/181) ([gfedorenko](https://github.com/gfedorenko))
- Fix broken copy button for API tokens \(fixes \#167\) [\#180](https://github.com/rubykube/peatio/pull/180) ([gfedorenko](https://github.com/gfedorenko))
- Use $ as the default currency [\#179](https://github.com/rubykube/peatio/pull/179) ([ysv](https://github.com/ysv))
- Removed test-unit \#164 [\#178](https://github.com/rubykube/peatio/pull/178) ([gfedorenko](https://github.com/gfedorenko))
- Replaced peatio.com with demo.peatio.tech [\#177](https://github.com/rubykube/peatio/pull/177) ([gfedorenko](https://github.com/gfedorenko))
- Remove several unused gems. [\#176](https://github.com/rubykube/peatio/pull/176) ([yivo](https://github.com/yivo))
- Clean database before running tests \(fixes ci tests fails\) [\#175](https://github.com/rubykube/peatio/pull/175) ([dmk](https://github.com/dmk))
- Add ability to set config template from file \(makes configmap works\) [\#174](https://github.com/rubykube/peatio/pull/174) ([dmk](https://github.com/dmk))
-  Remove gem meta\_request [\#171](https://github.com/rubykube/peatio/pull/171) ([ysv](https://github.com/ysv))
- Remove gem whenever + configs [\#170](https://github.com/rubykube/peatio/pull/170) ([ysv](https://github.com/ysv))
- remove transifex [\#169](https://github.com/rubykube/peatio/pull/169) ([dmk](https://github.com/dmk))
- Remove views/api issue \#160 [\#168](https://github.com/rubykube/peatio/pull/168) ([ysv](https://github.com/ysv))
- Convert views/sessions Slim templates to ERB [\#153](https://github.com/rubykube/peatio/pull/153) ([spavlishak](https://github.com/spavlishak))
- \[slim2erb\] errors/ pages [\#151](https://github.com/rubykube/peatio/pull/151) ([spavlishak](https://github.com/spavlishak))
- \[slim2erb\] members/ pages [\#150](https://github.com/rubykube/peatio/pull/150) ([spavlishak](https://github.com/spavlishak))
- Convert views/layouts Slim templates to ERB [\#149](https://github.com/rubykube/peatio/pull/149) ([spavlishak](https://github.com/spavlishak))
- Convert views/identities Slim templates to ERB [\#148](https://github.com/rubykube/peatio/pull/148) ([spavlishak](https://github.com/spavlishak))
- \[slim2erb\] authentications/ pages [\#147](https://github.com/rubykube/peatio/pull/147) ([spavlishak](https://github.com/spavlishak))
- Convert views/activations Slim templates to ERB [\#146](https://github.com/rubykube/peatio/pull/146) ([spavlishak](https://github.com/spavlishak))
- Removed Doorkeeper gem [\#145](https://github.com/rubykube/peatio/pull/145) ([gfedorenko](https://github.com/gfedorenko))
- Fix 403 when generating deposit address [\#144](https://github.com/rubykube/peatio/pull/144) ([yivo](https://github.com/yivo))
- Update Redis variables [\#143](https://github.com/rubykube/peatio/pull/143) ([yivo](https://github.com/yivo))
- Fix titles markup issue at Solvency page [\#142](https://github.com/rubykube/peatio/pull/142) ([ymasiuk](https://github.com/ymasiuk))
- Fix automated fetching transactions [\#141](https://github.com/rubykube/peatio/pull/141) ([dmk](https://github.com/dmk))
- Update rails configuration; start using secrets.yml [\#140](https://github.com/rubykube/peatio/pull/140) ([dmk](https://github.com/dmk))
- Update Ripple config&docs [\#139](https://github.com/rubykube/peatio/pull/139) ([dmk](https://github.com/dmk))
- Updated documentations with rake task for generating liability proofs [\#138](https://github.com/rubykube/peatio/pull/138) ([gfedorenko](https://github.com/gfedorenko))
- Add God process monitoring for daemons [\#137](https://github.com/rubykube/peatio/pull/137) ([yivo](https://github.com/yivo))
- Fix error raising due to removed to\_d method [\#135](https://github.com/rubykube/peatio/pull/135) ([ysv](https://github.com/ysv))
- Filter by markets for XRP [\#131](https://github.com/rubykube/peatio/pull/131) ([ymasiuk](https://github.com/ymasiuk))
- Added csrf token to withdraws post \#116 [\#129](https://github.com/rubykube/peatio/pull/129) ([gfedorenko](https://github.com/gfedorenko))
- Send CORS headers for API [\#124](https://github.com/rubykube/peatio/pull/124) ([yivo](https://github.com/yivo))
- Fix assets in production [\#122](https://github.com/rubykube/peatio/pull/122) ([dmk](https://github.com/dmk))
- Add 'responders' gem [\#120](https://github.com/rubykube/peatio/pull/120) ([dmk](https://github.com/dmk))
- Added translation for welcome page [\#119](https://github.com/rubykube/peatio/pull/119) ([ymasiuk](https://github.com/ymasiuk))
- Replace ZeroClipboard with clipboard.js \#107 [\#117](https://github.com/rubykube/peatio/pull/117) ([gfedorenko](https://github.com/gfedorenko))
- Make amqp.yml static \(same as database.yml\) [\#112](https://github.com/rubykube/peatio/pull/112) ([dmk](https://github.com/dmk))
- Fix binaries [\#110](https://github.com/rubykube/peatio/pull/110) ([dmk](https://github.com/dmk))
- Pass authenticity\_token as param \#101 [\#109](https://github.com/rubykube/peatio/pull/109) ([gfedorenko](https://github.com/gfedorenko))
- updated readme [\#106](https://github.com/rubykube/peatio/pull/106) ([ymasiuk](https://github.com/ymasiuk))
- return broken styles for date form on update page [\#105](https://github.com/rubykube/peatio/pull/105) ([ymasiuk](https://github.com/ymasiuk))
- fixed comment\_fail [\#102](https://github.com/rubykube/peatio/pull/102) ([ymasiuk](https://github.com/ymasiuk))
- Changed size of window for tests \#39 [\#100](https://github.com/rubykube/peatio/pull/100) ([gfedorenko](https://github.com/gfedorenko))
- changed email in readme docs [\#99](https://github.com/rubykube/peatio/pull/99) ([ymasiuk](https://github.com/ymasiuk))
- Flexible redirect URL for sign in with Auth0|Google [\#98](https://github.com/rubykube/peatio/pull/98) ([yivo](https://github.com/yivo))
- Invalid paths in stylesheet [\#97](https://github.com/rubykube/peatio/pull/97) ([ysv](https://github.com/ysv))
- Set correct name and description for Change Password setting [\#95](https://github.com/rubykube/peatio/pull/95) ([gfedorenko](https://github.com/gfedorenko))
- Changed angularjs version to 1.3.15 [\#93](https://github.com/rubykube/peatio/pull/93) ([gfedorenko](https://github.com/gfedorenko))
- Layout issue when window is less than [\#92](https://github.com/rubykube/peatio/pull/92) ([ymasiuk](https://github.com/ymasiuk))
- correct name deposits field [\#90](https://github.com/rubykube/peatio/pull/90) ([ymasiuk](https://github.com/ymasiuk))
- Fixed link to Peatio GitHub repository at API Tokens page [\#89](https://github.com/rubykube/peatio/pull/89) ([ymasiuk](https://github.com/ymasiuk))
- Specs are failing due to missing ID in document [\#87](https://github.com/rubykube/peatio/pull/87) ([ysv](https://github.com/ysv))
- Fix CI badge in the README [\#69](https://github.com/rubykube/peatio/pull/69) ([dmk](https://github.com/dmk))
- Add k8s deployment documentation [\#68](https://github.com/rubykube/peatio/pull/68) ([dmk](https://github.com/dmk))
- Add more generic way to configure k8s deployment [\#63](https://github.com/rubykube/peatio/pull/63) ([dmk](https://github.com/dmk))
- Test failing with seed 17488 [\#59](https://github.com/rubykube/peatio/pull/59) ([ysv](https://github.com/ysv))
- Support for generic JWT [\#56](https://github.com/rubykube/peatio/pull/56) ([yivo](https://github.com/yivo))

## [0.2.3](https://github.com/rubykube/peatio/tree/0.2.3) (2017-12-07)
[Full Changelog](https://github.com/rubykube/peatio/compare/0.1.1...0.2.3)

**Closed issues:**

- assets.config.precompile is missing some assets [\#61](https://github.com/rubykube/peatio/issues/61)
- Resolve warnings after update to ruby 2.4 & gems update  [\#51](https://github.com/rubykube/peatio/issues/51)
- Remove hardcoded secrets in config/initializers/secret\_token.rb [\#42](https://github.com/rubykube/peatio/issues/42)
- Signatures randomly don't match when using keypair token authentication [\#41](https://github.com/rubykube/peatio/issues/41)
- SocketError [\#36](https://github.com/rubykube/peatio/issues/36)
- Sign up via Auth0 \(should be optional\) [\#18](https://github.com/rubykube/peatio/issues/18)
- Sign up via Google [\#17](https://github.com/rubykube/peatio/issues/17)
- Remove 2-way authentification [\#15](https://github.com/rubykube/peatio/issues/15)

**Merged pull requests:**

- Add ability to set password for rabbitmq and redis [\#66](https://github.com/rubykube/peatio/pull/66) ([dmk](https://github.com/dmk))
- Update binstubs [\#65](https://github.com/rubykube/peatio/pull/65) ([dmk](https://github.com/dmk))
- Fix \#61 [\#62](https://github.com/rubykube/peatio/pull/62) ([yivo](https://github.com/yivo))
- Fix \#41 [\#60](https://github.com/rubykube/peatio/pull/60) ([yivo](https://github.com/yivo))
- Fix typo: expire\_at -\> expires\_at [\#55](https://github.com/rubykube/peatio/pull/55) ([yivo](https://github.com/yivo))
- Resolve warnings [\#54](https://github.com/rubykube/peatio/pull/54) ([yivo](https://github.com/yivo))
- Update grape to 1.0.1, grape-entity to 0.5.2, grape-swagger to 0.27.3 [\#53](https://github.com/rubykube/peatio/pull/53) ([yivo](https://github.com/yivo))
- Remove hardcoded cookies secret key \(fixes \#42\) [\#48](https://github.com/rubykube/peatio/pull/48) ([yivo](https://github.com/yivo))
- Update grape to 0.15.0 [\#46](https://github.com/rubykube/peatio/pull/46) ([yivo](https://github.com/yivo))
- Update grape to 0.9.0 [\#44](https://github.com/rubykube/peatio/pull/44) ([yivo](https://github.com/yivo))
- Preparations for JWT auth [\#38](https://github.com/rubykube/peatio/pull/38) ([yivo](https://github.com/yivo))
- Run tests on push [\#37](https://github.com/rubykube/peatio/pull/37) ([dmk](https://github.com/dmk))
- Optional sign in with Auth0 [\#29](https://github.com/rubykube/peatio/pull/29) ([yivo](https://github.com/yivo))
- Optional sign in with Google account [\#28](https://github.com/rubykube/peatio/pull/28) ([yivo](https://github.com/yivo))
- Fixed QR code [\#27](https://github.com/rubykube/peatio/pull/27) ([spavlishak](https://github.com/spavlishak))
- Minor fixes [\#12](https://github.com/rubykube/peatio/pull/12) ([spavlishak](https://github.com/spavlishak))
- Lock ruby version [\#11](https://github.com/rubykube/peatio/pull/11) ([yivo](https://github.com/yivo))
- Add ripple support [\#9](https://github.com/rubykube/peatio/pull/9) ([dmk](https://github.com/dmk))
- Cleanup [\#7](https://github.com/rubykube/peatio/pull/7) ([dmk](https://github.com/dmk))
- Make it work on k8s [\#6](https://github.com/rubykube/peatio/pull/6) ([dmk](https://github.com/dmk))
- Fix Pusher [\#4](https://github.com/rubykube/peatio/pull/4) ([dmk](https://github.com/dmk))
- Deployment [\#3](https://github.com/rubykube/peatio/pull/3) ([shal](https://github.com/shal))
- updated gem file and added mysql adapter [\#2](https://github.com/rubykube/peatio/pull/2) ([kashlo](https://github.com/kashlo))

## [0.1.1](https://github.com/rubykube/peatio/tree/0.1.1) (2015-09-25)
