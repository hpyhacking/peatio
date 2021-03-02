
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `adjustments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reason` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `creator_id` bigint(20) NOT NULL,
  `validator_id` bigint(20) DEFAULT NULL,
  `amount` decimal(32,16) NOT NULL,
  `asset_account_code` smallint(5) unsigned NOT NULL,
  `receiving_account_number` varchar(64) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `category` tinyint(4) NOT NULL,
  `state` tinyint(4) NOT NULL,
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_adjustments_on_currency_id` (`currency_id`),
  KEY `index_adjustments_on_currency_id_and_state` (`currency_id`,`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assets_on_currency_id` (`currency_id`),
  KEY `index_assets_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `beneficiaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `beneficiaries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(20) NOT NULL,
  `currency_id` varchar(10) NOT NULL,
  `name` varchar(64) NOT NULL,
  `description` varchar(255) DEFAULT '',
  `data` json DEFAULT NULL,
  `pin` mediumint(8) unsigned NOT NULL,
  `sent_at` datetime DEFAULT NULL,
  `state` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_beneficiaries_on_member_id` (`member_id`),
  KEY `index_beneficiaries_on_currency_id` (`currency_id`)
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
  `height` bigint(20) NOT NULL,
  `explorer_address` varchar(255) DEFAULT NULL,
  `explorer_transaction` varchar(255) DEFAULT NULL,
  `min_confirmations` int(11) NOT NULL DEFAULT '6',
  `status` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_blockchains_on_key` (`key`),
  KEY `index_blockchains_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currencies` (
  `id` varchar(10) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `blockchain_key` varchar(32) DEFAULT NULL,
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
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `deposit_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `withdrawal_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `base_factor` bigint(20) NOT NULL DEFAULT '1',
  `precision` tinyint(4) NOT NULL DEFAULT '8',
  `icon_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_currencies_on_visible` (`visible`),
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
  `from_addresses` text DEFAULT NULL,
  `txid` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `txout` int(11) DEFAULT NULL,
  `aasm_state` varchar(30) NOT NULL,
  `block_number` int(11) DEFAULT NULL,
  `type` varchar(30) NOT NULL,
  `tid` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `spread` varchar(1000) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  `completed_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_deposits_on_currency_id_and_txid_and_txout` (`currency_id`,`txid`,`txout`),
  KEY `index_deposits_on_currency_id` (`currency_id`),
  KEY `index_deposits_on_type` (`type`),
  KEY `index_deposits_on_member_id_and_txid` (`member_id`,`txid`),
  KEY `index_deposits_on_aasm_state_and_member_id_and_currency_id` (`aasm_state`,`member_id`,`currency_id`),
  KEY `index_deposits_on_tid` (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `engines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `engines` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `driver` varchar(255) NOT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `key_encrypted` varchar(255) DEFAULT NULL,
  `secret_encrypted` varchar(255) DEFAULT NULL,
  `data_encrypted` varchar(1024) DEFAULT NULL,
  `state` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `currency_id` varchar(255) NOT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_expenses_on_currency_id` (`currency_id`),
  KEY `index_expenses_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `pointer` int(10) unsigned DEFAULT NULL,
  `counter` int(11) DEFAULT NULL,
  `data` json DEFAULT NULL,
  `error_code` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `error_message` varchar(255) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
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
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
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
DROP TABLE IF EXISTS `markets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `markets` (
  `id` varchar(20) NOT NULL,
  `base_unit` varchar(10) NOT NULL,
  `quote_unit` varchar(10) NOT NULL,
  `engine_id` bigint(20) NOT NULL,
  `amount_precision` tinyint(4) NOT NULL DEFAULT '4',
  `price_precision` tinyint(4) NOT NULL DEFAULT '4',
  `min_price` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `max_price` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `min_amount` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `position` int(11) NOT NULL DEFAULT '0',
  `data` json DEFAULT NULL,
  `state` varchar(32) NOT NULL DEFAULT 'enabled',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_markets_on_base_unit_and_quote_unit` (`base_unit`,`quote_unit`),
  KEY `index_markets_on_base_unit` (`base_unit`),
  KEY `index_markets_on_quote_unit` (`quote_unit`),
  KEY `index_markets_on_position` (`position`),
  KEY `index_markets_on_engine_id` (`engine_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(32) NOT NULL,
  `email` varchar(255) NOT NULL,
  `level` int(11) NOT NULL,
  `role` varchar(16) NOT NULL,
  `group` varchar(32) NOT NULL DEFAULT 'vip-0',
  `state` varchar(16) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_members_on_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
  `uuid` varbinary(16) NOT NULL,
  `remote_id` varchar(255) DEFAULT NULL,
  `bid` varchar(10) NOT NULL,
  `ask` varchar(10) NOT NULL,
  `market_id` varchar(20) NOT NULL,
  `price` decimal(32,16) DEFAULT NULL,
  `volume` decimal(32,16) NOT NULL,
  `origin_volume` decimal(32,16) NOT NULL,
  `maker_fee` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
  `taker_fee` decimal(17,16) NOT NULL DEFAULT '0.0000000000000000',
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
  UNIQUE KEY `index_orders_on_uuid` (`uuid`),
  KEY `index_orders_on_member_id` (`member_id`) USING BTREE,
  KEY `index_orders_on_state` (`state`) USING BTREE,
  KEY `index_orders_on_type_and_state_and_member_id` (`type`,`state`,`member_id`),
  KEY `index_orders_on_type_and_state_and_market_id` (`type`,`state`,`market_id`),
  KEY `index_orders_on_type_and_market_id` (`type`,`market_id`),
  KEY `index_orders_on_type_and_member_id` (`type`,`member_id`),
  KEY `index_orders_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `payment_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `currency_id` varchar(10) NOT NULL,
  `account_id` int(11) NOT NULL,
  `address` varchar(95) DEFAULT NULL,
  `secret_encrypted` varchar(255) DEFAULT NULL,
  `details_encrypted` varchar(1024) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_payment_addresses_on_currency_id_and_address` (`currency_id`,`address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `refunds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_id` bigint(20) NOT NULL,
  `state` varchar(30) NOT NULL,
  `address` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_refunds_on_deposit_id` (`deposit_id`),
  KEY `index_refunds_on_state` (`state`)
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
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `debit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `credit` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_revenues_on_currency_id` (`currency_id`),
  KEY `index_revenues_on_reference_type_and_reference_id` (`reference_type`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stats_member_pnl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stats_member_pnl` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `pnl_currency_id` varchar(10) NOT NULL,
  `currency_id` varchar(10) NOT NULL,
  `total_credit` decimal(48,16) DEFAULT '0.0000000000000000',
  `total_credit_fees` decimal(48,16) DEFAULT '0.0000000000000000',
  `total_debit_fees` decimal(48,16) DEFAULT '0.0000000000000000',
  `total_debit` decimal(48,16) DEFAULT '0.0000000000000000',
  `total_credit_value` decimal(48,16) DEFAULT '0.0000000000000000',
  `total_debit_value` decimal(48,16) DEFAULT '0.0000000000000000',
  `total_balance_value` decimal(48,16) DEFAULT '0.0000000000000000',
  `average_balance_price` decimal(48,16) DEFAULT '0.0000000000000000',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_currency_ids_and_member_id` (`pnl_currency_id`,`currency_id`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stats_member_pnl_idx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stats_member_pnl_idx` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `pnl_currency_id` varchar(10) NOT NULL,
  `currency_id` varchar(10) NOT NULL,
  `reference_type` varchar(255) NOT NULL,
  `last_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_currency_ids_and_type` (`pnl_currency_id`,`currency_id`,`reference_type`),
  KEY `index_currency_ids_and_last_id` (`pnl_currency_id`,`currency_id`,`last_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `trades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `price` decimal(32,16) NOT NULL,
  `amount` decimal(32,16) NOT NULL,
  `total` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `maker_order_id` int(11) NOT NULL,
  `taker_order_id` int(11) NOT NULL,
  `market_id` varchar(20) NOT NULL,
  `maker_id` int(11) NOT NULL,
  `taker_id` int(11) NOT NULL,
  `taker_type` varchar(20) NOT NULL,
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_trades_on_maker_order_id` (`maker_order_id`) USING BTREE,
  KEY `index_trades_on_taker_order_id` (`taker_order_id`) USING BTREE,
  KEY `index_trades_on_market_id_and_created_at` (`market_id`,`created_at`),
  KEY `index_trades_on_maker_id_and_taker_id` (`maker_id`,`taker_id`),
  KEY `index_trades_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `trading_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trading_fees` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `market_id` varchar(20) NOT NULL DEFAULT 'any',
  `group` varchar(32) NOT NULL DEFAULT 'any',
  `maker` decimal(7,6) NOT NULL DEFAULT '0.000000',
  `taker` decimal(7,6) NOT NULL DEFAULT '0.000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_trading_fees_on_market_id_and_group` (`market_id`,`group`),
  KEY `index_trading_fees_on_market_id` (`market_id`),
  KEY `index_trading_fees_on_group` (`group`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transfers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(30) NOT NULL,
  `category` tinyint(4) NOT NULL,
  `description` varchar(255) DEFAULT '',
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_transfers_on_key` (`key`)
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
  `gateway` varchar(20) NOT NULL DEFAULT '',
  `settings_encrypted` varchar(1024) DEFAULT NULL,
  `max_balance` decimal(32,16) NOT NULL DEFAULT '0.0000000000000000',
  `status` varchar(32) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wallets_on_status` (`status`),
  KEY `index_wallets_on_kind` (`kind`),
  KEY `index_wallets_on_currency_id` (`currency_id`),
  KEY `index_wallets_on_kind_and_currency_id_and_status` (`kind`,`currency_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `withdraws`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `withdraws` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `beneficiary_id` bigint(20) DEFAULT NULL,
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
  `error` json DEFAULT NULL,
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  `completed_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_withdraws_on_currency_id_and_txid` (`currency_id`,`txid`),
  KEY `index_withdraws_on_currency_id` (`currency_id`),
  KEY `index_withdraws_on_aasm_state` (`aasm_state`),
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

INSERT INTO `schema_migrations` (version) VALUES
('20180112151205'),
('20180212115002'),
('20180212115751'),
('20180213160501'),
('20180215124645'),
('20180215131129'),
('20180215144645'),
('20180215144646'),
('20180216145412'),
('20180227163417'),
('20180303121013'),
('20180303211737'),
('20180305111648'),
('20180315132521'),
('20180315145436'),
('20180315150348'),
('20180315185255'),
('20180325001828'),
('20180327020701'),
('20180329145257'),
('20180329145557'),
('20180329154130'),
('20180403115050'),
('20180403134930'),
('20180403135744'),
('20180403145234'),
('20180403231931'),
('20180406080444'),
('20180406185130'),
('20180407082641'),
('20180409115144'),
('20180409115902'),
('20180416160438'),
('20180417085823'),
('20180417111305'),
('20180417175453'),
('20180419122223'),
('20180425094920'),
('20180425152420'),
('20180425224307'),
('20180501082703'),
('20180501141718'),
('20180516094307'),
('20180516101606'),
('20180516104042'),
('20180516105035'),
('20180516110336'),
('20180516124235'),
('20180516131005'),
('20180516133138'),
('20180517084245'),
('20180517101842'),
('20180517110003'),
('20180522105709'),
('20180522121046'),
('20180522165830'),
('20180524170927'),
('20180525101406'),
('20180529125011'),
('20180530122201'),
('20180605104154'),
('20180613140856'),
('20180613144712'),
('20180704103131'),
('20180704115110'),
('20180708014826'),
('20180708171446'),
('20180716115113'),
('20180718113111'),
('20180719123616'),
('20180719172203'),
('20180720165705'),
('20180726110440'),
('20180727054453'),
('20180803144827'),
('20180808144704'),
('20180813105100'),
('20180905112301'),
('20180925123806'),
('20181004114428'),
('20181017114624'),
('20181027192001'),
('20181028000150'),
('20181105102116'),
('20181105102422'),
('20181105102537'),
('20181105120211'),
('20181120113445'),
('20181126101312'),
('20181210162905'),
('20181219115439'),
('20181219133822'),
('20181226170925'),
('20181229051129'),
('20190110164859'),
('20190115165813'),
('20190116140939'),
('20190204142656'),
('20190213104708'),
('20190225171726'),
('20190401121727'),
('20190402130148'),
('20190426145506'),
('20190502103256'),
('20190529142209'),
('20190617090551'),
('20190624102330'),
('20190711114027'),
('20190723202251'),
('20190725131843'),
('20190726161540'),
('20190807092706'),
('20190813121822'),
('20190814102636'),
('20190816125948'),
('20190829035814'),
('20190829152927'),
('20190830082950'),
('20190902134819'),
('20190902141139'),
('20190904143050'),
('20190905050444'),
('20190910105717'),
('20190923085927'),
('20200117160600'),
('20200211124707'),
('20200220133250'),
('20200305140516'),
('20200316132213'),
('20200317080916'),
('20200414155144'),
('20200420141636'),
('20200504183201'),
('20200513153429'),
('20200527130534'),
('20200622185615'),
('20200804091304'),
('20200805102000'),
('20200805102001'),
('20200805102002'),
('20200805144308');


