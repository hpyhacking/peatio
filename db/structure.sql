
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
) ENGINE=InnoDB AUTO_INCREMENT=32001 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assets_on_currency_id` (`currency_id`),
  KEY `index_assets_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
  `step` int(11) NOT NULL DEFAULT '6',
  `explorer_address` varchar(255) DEFAULT NULL,
  `explorer_transaction` varchar(255) DEFAULT NULL,
  `min_confirmations` int(11) NOT NULL DEFAULT '6',
  `status` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_blockchains_on_key` (`key`),
  KEY `index_blockchains_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currencies` (
  `id` varchar(10) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `blockchain_key` varchar(32) DEFAULT NULL,
  `symbol` varchar(1) NOT NULL,
  `type` varchar(30) NOT NULL DEFAULT 'coin',
  `deposit_fee` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_deposit_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_collection_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `withdraw_fee` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_withdraw_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `withdraw_limit_24h` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `withdraw_limit_72h` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `position` int(11) NOT NULL DEFAULT '0',
  `options` varchar(1000) DEFAULT '{}',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `base_factor` bigint(20) NOT NULL DEFAULT '1',
  `precision` tinyint(4) NOT NULL DEFAULT '8',
  `icon_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_currencies_on_enabled` (`enabled`),
  KEY `index_currencies_on_position` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
  `spread` varchar(1000) DEFAULT NULL,
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
DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expenses_on_currency_id` (`currency_id`),
  KEY `index_expenses_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `liabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `liabilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `member_id` int(11) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_liabilities_on_currency_id` (`currency_id`),
  KEY `index_liabilities_on_member_id` (`member_id`),
  KEY `index_liabilities_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8335 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `markets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `markets` (
  `id` varchar(20) NOT NULL,
  `ask_unit` varchar(10) NOT NULL,
  `bid_unit` varchar(10) NOT NULL,
  `ask_fee` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
  `bid_fee` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_ask_price` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `max_bid_price` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_ask_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_bid_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
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
DROP TABLE IF EXISTS `members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(12) NOT NULL,
  `email` varchar(255) NOT NULL,
  `level` int(11) NOT NULL,
  `role` varchar(16) NOT NULL,
  `state` varchar(16) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_members_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4001 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `operations_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operations_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` mediumint(9) NOT NULL,
  `type` varchar(10) NOT NULL,
  `kind` varchar(30) NOT NULL,
  `currency_type` varchar(10) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `scope` varchar(10) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_operations_accounts_on_code` (`code`),
  UNIQUE KEY `index_operations_accounts_on_type_and_kind_and_currency_type` (`type`,`kind`,`currency_type`),
  KEY `index_operations_accounts_on_type` (`type`),
  KEY `index_operations_accounts_on_currency_type` (`currency_type`),
  KEY `index_operations_accounts_on_scope` (`scope`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
  KEY `index_orders_on_type_and_member_id` (`type`,`member_id`),
  KEY `index_orders_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4001 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
DROP TABLE IF EXISTS `revenues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `revenues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `member_id` int(11) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_revenues_on_currency_id` (`currency_id`),
  KEY `index_revenues_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3597 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
  KEY `index_trades_on_ask_member_id_and_bid_member_id` (`ask_member_id`,`bid_member_id`),
  KEY `index_trades_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=1799 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transfers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` int(11) NOT NULL,
  `kind` varchar(30) NOT NULL,
  `desc` varchar(255) DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_transfers_on_key` (`key`),
  KEY `index_transfers_on_kind` (`kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `triggers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) NOT NULL,
  `order_type` tinyint(3) unsigned NOT NULL,
  `value` varbinary(128) NOT NULL,
  `state` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_triggers_on_order_id` (`order_id`),
  KEY `index_triggers_on_order_type` (`order_type`),
  KEY `index_triggers_on_state` (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
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
  `note` varchar(256) DEFAULT NULL,
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
