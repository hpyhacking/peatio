-- MySQL dump 10.16  Distrib 10.1.37-MariaDB, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: peatio_development
-- ------------------------------------------------------
-- Server version	5.7.24

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `currency_id` varchar(10) NOT NULL,
  `balance` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `locked` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_accounts_on_currency_id_and_member_id` (`currency_id`,`member_id`),
  KEY `index_accounts_on_member_id` (`member_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `reference_id` int(11) NOT NULL,
  `reference_type` varchar(255) NOT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assets_on_currency_id` (`currency_id`),
  KEY `index_assets_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authentications`
--

DROP TABLE IF EXISTS `authentications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider` varchar(30) NOT NULL,
  `uid` varchar(255) NOT NULL,
  `token` varchar(1024) DEFAULT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_authentications_on_provider_and_uid` (`provider`,`uid`),
  UNIQUE KEY `index_authentications_on_provider_and_member_id` (`provider`,`member_id`),
  UNIQUE KEY `index_authentications_on_provider_and_member_id_and_uid` (`provider`,`member_id`,`uid`),
  KEY `index_authentications_on_member_id` (`member_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blockchains`
--

DROP TABLE IF EXISTS `blockchains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blockchains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `client` varchar(255) NOT NULL,
  `server` varchar(255) DEFAULT NULL,
  `height` int(11) NOT NULL,
  `explorer_address` varchar(255) DEFAULT NULL,
  `explorer_transaction` varchar(255) DEFAULT NULL,
  `min_confirmations` int(11) NOT NULL DEFAULT '6',
  `status` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_blockchains_on_key` (`key`),
  KEY `index_blockchains_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currencies` (
  `id` varchar(10) NOT NULL,
  `blockchain_key` varchar(32) DEFAULT NULL,
  `symbol` varchar(1) NOT NULL,
  `type` varchar(30) NOT NULL DEFAULT 'coin',
  `deposit_fee` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `withdraw_limit_24h` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `withdraw_limit_72h` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_deposit_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_collection_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `withdraw_fee` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `options` varchar(1000) NOT NULL DEFAULT '{}',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `base_factor` bigint(20) NOT NULL DEFAULT '1',
  `precision` tinyint(4) NOT NULL DEFAULT '8',
  `icon_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_currencies_on_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deposits`
--

DROP TABLE IF EXISTS `deposits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deposits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `currency_id` varchar(10) NOT NULL,
  `amount` decimal(32,16) NOT NULL,
  `fee` decimal(32,16) NOT NULL,
  `address` varchar(95) DEFAULT NULL,
  `txid` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `txout` int(11) DEFAULT NULL,
  `aasm_state` varchar(30) NOT NULL,
  `block_number` int(11) DEFAULT NULL,
  `type` varchar(30) NOT NULL,
  `tid` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_deposits_on_currency_id_and_txid_and_txout` (`currency_id`,`txid`,`txout`),
  KEY `index_deposits_on_currency_id` (`currency_id`),
  KEY `index_deposits_on_type` (`type`),
  KEY `index_deposits_on_member_id_and_txid` (`member_id`,`txid`),
  KEY `index_deposits_on_aasm_state_and_member_id_and_currency_id` (`aasm_state`,`member_id`,`currency_id`),
  KEY `index_deposits_on_tid` (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `reference_id` int(11) NOT NULL,
  `reference_type` varchar(255) NOT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expenses_on_currency_id` (`currency_id`),
  KEY `index_expenses_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `liabilities`
--

DROP TABLE IF EXISTS `liabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `liabilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `member_id` int(11) NOT NULL,
  `reference_id` int(11) NOT NULL,
  `reference_type` varchar(255) NOT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_liabilities_on_currency_id` (`currency_id`),
  KEY `index_liabilities_on_member_id` (`member_id`),
  KEY `index_liabilities_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `markets`
--

DROP TABLE IF EXISTS `markets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `markets` (
  `id` varchar(20) NOT NULL,
  `ask_unit` varchar(10) NOT NULL,
  `bid_unit` varchar(10) NOT NULL,
  `ask_fee` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
  `bid_fee` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
  `max_bid` decimal(17,16) DEFAULT NULL,
  `min_ask` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
  `ask_precision` tinyint(4) NOT NULL DEFAULT '8',
  `bid_precision` tinyint(4) NOT NULL DEFAULT '8',
  `position` int(11) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_markets_on_ask_unit_and_bid_unit` (`ask_unit`,`bid_unit`),
  KEY `index_markets_on_ask_unit` (`ask_unit`),
  KEY `index_markets_on_bid_unit` (`bid_unit`),
  KEY `index_markets_on_position` (`position`),
  KEY `index_markets_on_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` tinyint(4) NOT NULL DEFAULT '0',
  `sn` varchar(12) NOT NULL,
  `email` varchar(255) NOT NULL,
  `disabled` tinyint(1) NOT NULL DEFAULT '0',
  `api_disabled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_members_on_sn` (`sn`),
  UNIQUE KEY `index_members_on_email` (`email`),
  KEY `index_members_on_disabled` (`disabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bid` varchar(10) NOT NULL,
  `ask` varchar(10) NOT NULL,
  `market_id` varchar(20) NOT NULL,
  `price` decimal(32,16) DEFAULT NULL,
  `volume` decimal(32,16) NOT NULL,
  `origin_volume` decimal(32,16) NOT NULL,
  `fee` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `state` int(11) NOT NULL,
  `type` varchar(8) NOT NULL,
  `member_id` int(11) NOT NULL,
  `ord_type` varchar(30) NOT NULL,
  `locked` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `origin_locked` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `funds_received` decimal(32,16) DEFAULT '0.0000000000000000',
  `trades_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_orders_on_member_id` (`member_id`) USING BTREE,
  KEY `index_orders_on_state` (`state`) USING BTREE,
  KEY `index_orders_on_type_and_state_and_member_id` (`type`,`state`,`member_id`),
  KEY `index_orders_on_type_and_state_and_market_id` (`type`,`state`,`market_id`),
  KEY `index_orders_on_type_and_market_id` (`type`,`market_id`),
  KEY `index_orders_on_type_and_member_id` (`type`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_addresses`
--

DROP TABLE IF EXISTS `payment_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `currency_id` varchar(10) NOT NULL,
  `account_id` int(11) NOT NULL,
  `address` varchar(95) DEFAULT NULL,
  `secret` varchar(128) DEFAULT NULL,
  `details` varchar(1024) NOT NULL DEFAULT '{}',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_payment_addresses_on_currency_id_and_address` (`currency_id`,`address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `revenues`
--

DROP TABLE IF EXISTS `revenues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `revenues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `reference_id` int(11) NOT NULL,
  `reference_type` varchar(255) NOT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_revenues_on_currency_id` (`currency_id`),
  KEY `index_revenues_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trades`
--

DROP TABLE IF EXISTS `trades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `price` decimal(32,16) NOT NULL,
  `volume` decimal(32,16) NOT NULL,
  `ask_id` int(11) NOT NULL,
  `bid_id` int(11) NOT NULL,
  `trend` int(11) NOT NULL,
  `market_id` varchar(20) NOT NULL,
  `ask_member_id` int(11) NOT NULL,
  `bid_member_id` int(11) NOT NULL,
  `funds` decimal(32,16) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trades_on_ask_id` (`ask_id`) USING BTREE,
  KEY `index_trades_on_bid_id` (`bid_id`) USING BTREE,
  KEY `index_trades_on_market_id_and_created_at` (`market_id`,`created_at`),
  KEY `index_trades_on_ask_member_id_and_bid_member_id` (`ask_member_id`,`bid_member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blockchain_key` varchar(32) DEFAULT NULL,
  `currency_id` varchar(10) DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `address` varchar(255) NOT NULL,
  `kind` int(11) NOT NULL,
  `nsig` int(11) DEFAULT NULL,
  `gateway` varchar(20) NOT NULL DEFAULT '',
  `settings` varchar(1000) NOT NULL DEFAULT '{}',
  `max_balance` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `parent` int(11) DEFAULT NULL,
  `status` varchar(32) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wallets_on_status` (`status`),
  KEY `index_wallets_on_kind` (`kind`),
  KEY `index_wallets_on_currency_id` (`currency_id`),
  KEY `index_wallets_on_kind_and_currency_id_and_status` (`kind`,`currency_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `withdraws`
--

DROP TABLE IF EXISTS `withdraws`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `withdraws` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `currency_id` varchar(10) NOT NULL,
  `amount` decimal(32,16) NOT NULL,
  `fee` decimal(32,16) NOT NULL,
  `txid` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `aasm_state` varchar(30) NOT NULL,
  `block_number` int(11) DEFAULT NULL,
  `sum` decimal(32,16) NOT NULL,
  `type` varchar(30) NOT NULL,
  `tid` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `rid` varchar(95) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_withdraws_on_currency_id_and_txid` (`currency_id`,`txid`),
  KEY `index_withdraws_on_currency_id` (`currency_id`),
  KEY `index_withdraws_on_aasm_state` (`aasm_state`),
  KEY `index_withdraws_on_account_id` (`account_id`),
  KEY `index_withdraws_on_member_id` (`member_id`),
  KEY `index_withdraws_on_type` (`type`),
  KEY `index_withdraws_on_tid` (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-12-03 14:40:40
INSERT INTO schema_migrations (version) VALUES ('20180112151205');

INSERT INTO schema_migrations (version) VALUES ('20180212115002');

INSERT INTO schema_migrations (version) VALUES ('20180212115751');

INSERT INTO schema_migrations (version) VALUES ('20180213160501');

INSERT INTO schema_migrations (version) VALUES ('20180215124645');

INSERT INTO schema_migrations (version) VALUES ('20180215131129');

INSERT INTO schema_migrations (version) VALUES ('20180215144645');

INSERT INTO schema_migrations (version) VALUES ('20180215144646');

INSERT INTO schema_migrations (version) VALUES ('20180216145412');

INSERT INTO schema_migrations (version) VALUES ('20180227163417');

INSERT INTO schema_migrations (version) VALUES ('20180303121013');

INSERT INTO schema_migrations (version) VALUES ('20180303211737');

INSERT INTO schema_migrations (version) VALUES ('20180305111648');

INSERT INTO schema_migrations (version) VALUES ('20180315132521');

INSERT INTO schema_migrations (version) VALUES ('20180315145436');

INSERT INTO schema_migrations (version) VALUES ('20180315150348');

INSERT INTO schema_migrations (version) VALUES ('20180315185255');

INSERT INTO schema_migrations (version) VALUES ('20180325001828');

INSERT INTO schema_migrations (version) VALUES ('20180327020701');

INSERT INTO schema_migrations (version) VALUES ('20180329145257');

INSERT INTO schema_migrations (version) VALUES ('20180329145557');

INSERT INTO schema_migrations (version) VALUES ('20180329154130');

INSERT INTO schema_migrations (version) VALUES ('20180403115050');

INSERT INTO schema_migrations (version) VALUES ('20180403134930');

INSERT INTO schema_migrations (version) VALUES ('20180403135744');

INSERT INTO schema_migrations (version) VALUES ('20180403145234');

INSERT INTO schema_migrations (version) VALUES ('20180403231931');

INSERT INTO schema_migrations (version) VALUES ('20180406080444');

INSERT INTO schema_migrations (version) VALUES ('20180406185130');

INSERT INTO schema_migrations (version) VALUES ('20180407082641');

INSERT INTO schema_migrations (version) VALUES ('20180409115144');

INSERT INTO schema_migrations (version) VALUES ('20180409115902');

INSERT INTO schema_migrations (version) VALUES ('20180416160438');

INSERT INTO schema_migrations (version) VALUES ('20180417085823');

INSERT INTO schema_migrations (version) VALUES ('20180417111305');

INSERT INTO schema_migrations (version) VALUES ('20180417175453');

INSERT INTO schema_migrations (version) VALUES ('20180419122223');

INSERT INTO schema_migrations (version) VALUES ('20180425094920');

INSERT INTO schema_migrations (version) VALUES ('20180425152420');

INSERT INTO schema_migrations (version) VALUES ('20180425224307');

INSERT INTO schema_migrations (version) VALUES ('20180501082703');

INSERT INTO schema_migrations (version) VALUES ('20180501141718');

INSERT INTO schema_migrations (version) VALUES ('20180516094307');

INSERT INTO schema_migrations (version) VALUES ('20180516101606');

INSERT INTO schema_migrations (version) VALUES ('20180516104042');

INSERT INTO schema_migrations (version) VALUES ('20180516105035');

INSERT INTO schema_migrations (version) VALUES ('20180516110336');

INSERT INTO schema_migrations (version) VALUES ('20180516124235');

INSERT INTO schema_migrations (version) VALUES ('20180516131005');

INSERT INTO schema_migrations (version) VALUES ('20180516133138');

INSERT INTO schema_migrations (version) VALUES ('20180517084245');

INSERT INTO schema_migrations (version) VALUES ('20180517101842');

INSERT INTO schema_migrations (version) VALUES ('20180517110003');

INSERT INTO schema_migrations (version) VALUES ('20180522105709');

INSERT INTO schema_migrations (version) VALUES ('20180522121046');

INSERT INTO schema_migrations (version) VALUES ('20180522165830');

INSERT INTO schema_migrations (version) VALUES ('20180524170927');

INSERT INTO schema_migrations (version) VALUES ('20180525101406');

INSERT INTO schema_migrations (version) VALUES ('20180529125011');

INSERT INTO schema_migrations (version) VALUES ('20180530122201');

INSERT INTO schema_migrations (version) VALUES ('20180605104154');

INSERT INTO schema_migrations (version) VALUES ('20180613140856');

INSERT INTO schema_migrations (version) VALUES ('20180613144712');

INSERT INTO schema_migrations (version) VALUES ('20180704103131');

INSERT INTO schema_migrations (version) VALUES ('20180704115110');

INSERT INTO schema_migrations (version) VALUES ('20180708014826');

INSERT INTO schema_migrations (version) VALUES ('20180708171446');

INSERT INTO schema_migrations (version) VALUES ('20180716115113');

INSERT INTO schema_migrations (version) VALUES ('20180718113111');

INSERT INTO schema_migrations (version) VALUES ('20180719123616');

INSERT INTO schema_migrations (version) VALUES ('20180719172203');

INSERT INTO schema_migrations (version) VALUES ('20180720165705');

INSERT INTO schema_migrations (version) VALUES ('20180726110440');

INSERT INTO schema_migrations (version) VALUES ('20180727054453');

INSERT INTO schema_migrations (version) VALUES ('20180803144827');

INSERT INTO schema_migrations (version) VALUES ('20180808144704');

INSERT INTO schema_migrations (version) VALUES ('20180813105100');

INSERT INTO schema_migrations (version) VALUES ('20180905112301');

INSERT INTO schema_migrations (version) VALUES ('20180925123806');

INSERT INTO schema_migrations (version) VALUES ('20181004114428');

INSERT INTO schema_migrations (version) VALUES ('20181017114624');

INSERT INTO schema_migrations (version) VALUES ('20181105102116');

INSERT INTO schema_migrations (version) VALUES ('20181105102422');

INSERT INTO schema_migrations (version) VALUES ('20181105102537');

INSERT INTO schema_migrations (version) VALUES ('20181105120211');

INSERT INTO schema_migrations (version) VALUES ('20181120113445');

INSERT INTO schema_migrations (version) VALUES ('20181126101312');

