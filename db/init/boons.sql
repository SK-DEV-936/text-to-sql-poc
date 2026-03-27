CREATE DATABASE  IF NOT EXISTS `ecommerce_db_test` /*!40100 DEFAULT CHARACTER SET latin1 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `ecommerce_db_test`;
-- MySQL dump 10.13  Distrib 8.0.45, for macos15 (arm64)
--
-- Host: boons-dev-ecommerce.corsd9eir0e2.us-east-2.rds.amazonaws.com    Database: ecommerce_db_test
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `a2b_routing`
--

DROP TABLE IF EXISTS `a2b_routing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `a2b_routing` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mode` tinyint(1) NOT NULL DEFAULT '0',
  `url` longtext NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `a2b_routing_pass`
--

DROP TABLE IF EXISTS `a2b_routing_pass`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `a2b_routing_pass` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mode` varchar(255) DEFAULT NULL,
  `uid` bigint DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` longtext,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `access_menu`
--

DROP TABLE IF EXISTS `access_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `access_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mode` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `url` longtext,
  `icon` text,
  `menu_id` int DEFAULT '0',
  `order_sorting` int DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `show_status` tinyint(1) DEFAULT '1',
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_deletion_reasons`
--

DROP TABLE IF EXISTS `account_deletion_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_deletion_reasons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reasons` longtext,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `address_check`
--

DROP TABLE IF EXISTS `address_check`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_check` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `res_id` int DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `guest_id` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `added_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analytics_email_marketing`
--

DROP TABLE IF EXISTS `analytics_email_marketing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `analytics_email_marketing` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `analytics_sender_name` varchar(25) DEFAULT NULL,
  `analytics_sender_id` int NOT NULL,
  `suppression_group_id` int DEFAULT NULL,
  `analytics_api_key` text NOT NULL,
  `analytics_email` varchar(255) DEFAULT NULL,
  `analytics_engine` varchar(50) DEFAULT 'sendgrid',
  `analytics_account_id` bigint DEFAULT NULL,
  `analytics_master_contact_list_id` varchar(255) DEFAULT NULL,
  `domain_name` varchar(255) DEFAULT NULL,
  `ip_address` varchar(50) DEFAULT NULL,
  `status` tinyint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_email_logs`
--

DROP TABLE IF EXISTS `api_email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_email_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `api_status` varchar(255) DEFAULT NULL,
  `status_code` varchar(255) DEFAULT NULL,
  `message` longtext,
  `page` varchar(255) DEFAULT NULL,
  `functions` varchar(255) DEFAULT NULL,
  `request` longtext,
  `response` longtext,
  `api_url` varchar(255) DEFAULT NULL,
  `time_format` bigint DEFAULT '0',
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19564 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `app_logs`
--

DROP TABLE IF EXISTS `app_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rid` int NOT NULL,
  `log_det` longtext,
  `status` int NOT NULL DEFAULT '1',
  `time_format` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `app_version_details`
--

DROP TABLE IF EXISTS `app_version_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_version_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `version_type` varchar(255) DEFAULT NULL,
  `version_name` varchar(255) DEFAULT NULL,
  `description` longtext,
  `created_at` int NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_info`
--

DROP TABLE IF EXISTS `blocked_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blocked_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mode` varchar(255) DEFAULT NULL,
  `value` text,
  `remarks` text,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blog`
--

DROP TABLE IF EXISTS `blog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `blog_title` varchar(255) NOT NULL,
  `Category` varchar(255) NOT NULL,
  `summary` longtext NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `Author` varchar(255) NOT NULL,
  `img` varchar(255) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blog_category`
--

DROP TABLE IF EXISTS `blog_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `boons_config`
--

DROP TABLE IF EXISTS `boons_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `boons_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` text,
  `value` text,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_timestamp` bigint DEFAULT NULL,
  `last_modify_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_modify_timestamp` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `boons_events_email_marketing`
--

DROP TABLE IF EXISTS `boons_events_email_marketing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `boons_events_email_marketing` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` varchar(255) NOT NULL,
  `event` varchar(100) NOT NULL,
  `event_payload` json NOT NULL,
  `event_processed_data` json NOT NULL,
  `event_process_status` varchar(100) NOT NULL,
  `event_process_job_id` varchar(255) DEFAULT NULL,
  `source` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2423 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `boons_location_connections`
--

DROP TABLE IF EXISTS `boons_location_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `boons_location_connections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `location_id` varchar(100) NOT NULL,
  `status` enum('connected','disconnected') NOT NULL DEFAULT 'connected',
  `connected` tinyint(1) NOT NULL DEFAULT '1',
  `connected_at` timestamp NULL DEFAULT NULL,
  `disconnected_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_location_id` (`location_id`),
  KEY `idx_restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cart_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pos_mode` tinyint(1) DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `menu_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `event_id` int DEFAULT NULL,
  `name` text COLLATE utf8mb3_unicode_ci,
  `unit` text COLLATE utf8mb3_unicode_ci,
  `has_discount` text COLLATE utf8mb3_unicode_ci,
  `discounted_price` text COLLATE utf8mb3_unicode_ci,
  `thumbnail` text COLLATE utf8mb3_unicode_ci,
  `availability` text COLLATE utf8mb3_unicode_ci,
  `details` text COLLATE utf8mb3_unicode_ci,
  `status` text COLLATE utf8mb3_unicode_ci,
  `restaurant_id` int DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `price` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `time_price` longtext COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `guest_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0',
  `date_added` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_mode` enum('Regular','Catering','Event') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'Regular',
  `original_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `menu_id` (`menu_id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17019 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories_time`
--

DROP TABLE IF EXISTS `categories_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories_time` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `category_id` int NOT NULL,
  `timeslots` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'JSON object with days and time',
  `categorytime_status` enum('0','1') COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0' COMMENT 'Category time slot status',
  `updated_on` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_categories_time_restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=374 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_cart`
--

DROP TABLE IF EXISTS `catering_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_cart` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pos_mode` tinyint(1) DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `menu_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` text COLLATE utf8mb3_unicode_ci,
  `unit` text COLLATE utf8mb3_unicode_ci,
  `has_discount` text COLLATE utf8mb3_unicode_ci,
  `discounted_price` text COLLATE utf8mb3_unicode_ci,
  `thumbnail` text COLLATE utf8mb3_unicode_ci,
  `availability` text COLLATE utf8mb3_unicode_ci,
  `details` text COLLATE utf8mb3_unicode_ci,
  `status` text COLLATE utf8mb3_unicode_ci,
  `restaurant_id` int DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `price` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `time_price` longtext COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `guest_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0',
  `date_added` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `menu_id` (`menu_id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_commission_details`
--

DROP TABLE IF EXISTS `catering_commission_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_commission_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_bill` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_menu_bill` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `comm_val` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `comm_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'percent',
  `admin_commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `owner_commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_charge` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cat_service_fee` text COLLATE utf8mb3_unicode_ci,
  `bulk_order_fees` text COLLATE utf8mb3_unicode_ci,
  `inhouse_fees` decimal(10,2) DEFAULT '0.00',
  `cc_charge` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tips` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `merchant_tips` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `refunds` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stripe_refund` float(20,2) DEFAULT '0.00',
  `coupon` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_added` int DEFAULT NULL,
  `order_date` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `rewards_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Redemption amount',
  `rewards_settings_id` int DEFAULT NULL COMMENT 'Reward settings id used at the time of redemption',
  PRIMARY KEY (`id`),
  KEY `fk_catering_commission_details_reward_settings` (`rewards_settings_id`),
  KEY `idx_restaurant_date` (`restaurant_id`,`date_added`),
  CONSTRAINT `fk_catering_commission_details_reward_settings` FOREIGN KEY (`rewards_settings_id`) REFERENCES `reward_settings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3151 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_f_order_details`
--

DROP TABLE IF EXISTS `catering_f_order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_f_order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `menu_id` int DEFAULT NULL,
  `menu_name` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `total` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_code` (`order_code`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_f_order_log`
--

DROP TABLE IF EXISTS `catering_f_order_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_f_order_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` text,
  `cart_date` longtext,
  `rid` bigint DEFAULT NULL,
  `cid` bigint DEFAULT NULL,
  `name` text,
  `email` text,
  `mobile` text,
  `address` text,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_f_orders`
--

DROP TABLE IF EXISTS `catering_f_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_f_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `failed_reason` text COLLATE utf8mb3_unicode_ci,
  `dc` bigint DEFAULT '0',
  `delay_status` tinyint(1) DEFAULT '0',
  `show_status` tinyint(1) DEFAULT '0',
  `delivery_track_id` text COLLATE utf8mb3_unicode_ci,
  `quote_estimate_id` text COLLATE utf8mb3_unicode_ci,
  `cancel_fee` text COLLATE utf8mb3_unicode_ci,
  `increment_val` bigint DEFAULT NULL,
  `increment_status` tinyint(1) DEFAULT '0',
  `cart_data` text COLLATE utf8mb3_unicode_ci,
  `strip_pass_amt` text COLLATE utf8mb3_unicode_ci,
  `order_amount` text COLLATE utf8mb3_unicode_ci,
  `admin_discount` double(10,2) DEFAULT '0.00',
  `admin_add` double(10,2) DEFAULT '0.00',
  `admin_reason` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array_data` text COLLATE utf8mb3_unicode_ci,
  `pack` tinyint(1) DEFAULT '0',
  `strip_payment_key` text COLLATE utf8mb3_unicode_ci,
  `delivery_api_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_notes` text COLLATE utf8mb3_unicode_ci,
  `complete_email` tinyint(1) DEFAULT '0',
  `code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `oid` bigint DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `customer_address_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `order_placed_at` int DEFAULT NULL,
  `order_approved_at` int DEFAULT NULL,
  `order_preparing_at` int DEFAULT NULL,
  `order_prepared_at` int DEFAULT NULL,
  `order_ready_at` int DEFAULT NULL,
  `order_initiated_at` int DEFAULT NULL,
  `order_trip_created_at` int DEFAULT NULL,
  `order_in_progress_at` int DEFAULT NULL,
  `order_returned_at` int DEFAULT NULL,
  `order_delayed_at` int DEFAULT NULL,
  `order_pickup_at` int DEFAULT NULL,
  `order_picked_up_at` int DEFAULT NULL,
  `order_auto_cancel_at` int DEFAULT NULL,
  `order_delivered_at` int DEFAULT NULL,
  `order_pickuped_at` bigint DEFAULT NULL,
  `order_canceled_at` int DEFAULT NULL,
  `order_assigned_at` bigint DEFAULT NULL,
  `order_scheduled_at` bigint DEFAULT NULL,
  `order_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `note` longtext COLLATE utf8mb3_unicode_ci,
  `total_menu_price` float(65,2) DEFAULT '0.00',
  `total_delivery_charge` float(65,2) DEFAULT '0.00',
  `total_vat_amount` float(65,2) DEFAULT '0.00',
  `tips_amount` float(65,2) DEFAULT '0.00',
  `coupon_amount` float(65,2) NOT NULL DEFAULT '0.00',
  `coupon_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `grand_total` float(65,2) DEFAULT '0.00',
  `payment_method` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_details` longtext COLLATE utf8mb3_unicode_ci,
  `payment_timestamp` longtext COLLATE utf8mb3_unicode_ci,
  `payment_status` longtext COLLATE utf8mb3_unicode_ci,
  `type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'pickup',
  `order_schedule_mode` text COLLATE utf8mb3_unicode_ci,
  `strip_status` bigint DEFAULT '0',
  `store_address` longtext COLLATE utf8mb3_unicode_ci,
  `store_location` text COLLATE utf8mb3_unicode_ci,
  `day` text COLLATE utf8mb3_unicode_ci,
  `schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `apartment` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_add` longtext COLLATE utf8mb3_unicode_ci,
  `deliver_cod` longtext COLLATE utf8mb3_unicode_ci,
  `order_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule_time` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `deliveryStatus` tinyint(1) DEFAULT '0',
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `receipt_url` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_charge` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_capture` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_cancel` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `driver_id` (`driver_id`),
  KEY `code` (`code`),
  KEY `order_status` (`order_status`),
  KEY `order_placed_at` (`order_placed_at`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_food_categories`
--

DROP TABLE IF EXISTS `catering_food_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_food_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `is_featured` int NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `status` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_food_menus`
--

DROP TABLE IF EXISTS `catering_food_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_food_menus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `special` tinyint(1) DEFAULT '0',
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `subtitle` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `item_limit` text COLLATE utf8mb3_unicode_ci,
  `category_id` int DEFAULT NULL,
  `subcategory` enum('V','NV') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `items` longtext COLLATE utf8mb3_unicode_ci,
  `details` longtext COLLATE utf8mb3_unicode_ci,
  `nutrition_fact` longtext COLLATE utf8mb3_unicode_ci,
  `options` longtext COLLATE utf8mb3_unicode_ci,
  `modifiers` longtext COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Modifier ids in CSV format',
  `multi` int DEFAULT '0',
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `package_type` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `num_guests` int NOT NULL,
  `min_quantity` int NOT NULL,
  `perunit` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'person',
  `servings_unit` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `quantity_unit` int DEFAULT '1',
  `availability` int DEFAULT NULL,
  `has_discount` longtext COLLATE utf8mb3_unicode_ci,
  `price` longtext COLLATE utf8mb3_unicode_ci,
  `discounted_price` longtext COLLATE utf8mb3_unicode_ci,
  `time_price` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax_details` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tag_popular` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `sort_order` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_catering_food_menus_restaurant_status_category` (`restaurant_id`,`status`,`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1930 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_menu_log`
--

DROP TABLE IF EXISTS `catering_menu_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_menu_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `menu_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `admin_id` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_notification_log`
--

DROP TABLE IF EXISTS `catering_notification_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_notification_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` text,
  `oidd` bigint DEFAULT '0',
  `notification_content` longtext,
  `status` int DEFAULT '0',
  `send_date` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_order_details`
--

DROP TABLE IF EXISTS `catering_order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `edit_status` tinyint(1) NOT NULL DEFAULT '0',
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `menu_id` text COLLATE utf8mb3_unicode_ci,
  `menu_name` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `order_quantity` bigint DEFAULT NULL,
  `total` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10889 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_order_refund`
--

DROP TABLE IF EXISTS `catering_order_refund`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_order_refund` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `amount` varchar(255) DEFAULT '0',
  `remarks` text,
  `stripe_key` text,
  `refund_response` text,
  `refund_key` text,
  `transaction_key` text,
  `mode_status` varchar(255) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_orders`
--

DROP TABLE IF EXISTS `catering_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `delivery_to_pickup` tinyint(1) DEFAULT '0',
  `delivery_to_pickup_time` bigint DEFAULT NULL,
  `delivery_to_pickup_time_15` bigint DEFAULT NULL,
  `auto_cancel` tinyint(1) DEFAULT '0',
  `delivery_api_failed` tinyint(1) NOT NULL DEFAULT '0',
  `flag` tinyint(1) NOT NULL DEFAULT '1',
  `rs` tinyint(1) DEFAULT '0',
  `pos` tinyint(1) DEFAULT '0',
  `dc` bigint DEFAULT '0',
  `pu_status` int DEFAULT '0',
  `spu_status` int DEFAULT '0',
  `delay_status` tinyint(1) DEFAULT '0',
  `show_status` tinyint(1) DEFAULT '0',
  `delivery_track_id` text COLLATE utf8mb3_unicode_ci,
  `quote_estimate_id` text COLLATE utf8mb3_unicode_ci,
  `cancel_fee` text COLLATE utf8mb3_unicode_ci,
  `increment_val` bigint DEFAULT NULL,
  `increment_status` tinyint(1) DEFAULT '0',
  `cart_data` text COLLATE utf8mb3_unicode_ci,
  `strip_pass_amt` text COLLATE utf8mb3_unicode_ci,
  `order_amount` text COLLATE utf8mb3_unicode_ci,
  `pos_different_amount` text COLLATE utf8mb3_unicode_ci,
  `admin_discount` double(10,2) DEFAULT '0.00',
  `admin_add` double(10,2) DEFAULT '0.00',
  `admin_reason` text COLLATE utf8mb3_unicode_ci,
  `pack` tinyint(1) DEFAULT '0',
  `strip_payment_key` text COLLATE utf8mb3_unicode_ci,
  `delivery_api_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_notes` text COLLATE utf8mb3_unicode_ci,
  `complete_email` tinyint(1) DEFAULT '0',
  `code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `oid` bigint DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `customer_address_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `order_placed_at` int DEFAULT NULL,
  `order_approved_at` int DEFAULT NULL,
  `order_preparing_at` int DEFAULT NULL,
  `order_prepared_at` int DEFAULT NULL,
  `order_ready_at` int DEFAULT NULL,
  `order_initiated_at` int DEFAULT NULL,
  `order_trip_created_at` int DEFAULT NULL,
  `order_in_progress_at` int DEFAULT NULL,
  `order_returned_at` int DEFAULT NULL,
  `order_delayed_at` int DEFAULT NULL,
  `order_pickup_at` int DEFAULT NULL,
  `order_picked_up_at` int DEFAULT NULL,
  `order_auto_cancel_at` int DEFAULT NULL,
  `order_delivered_at` int DEFAULT NULL,
  `order_pickuped_at` bigint DEFAULT NULL,
  `order_canceled_at` int DEFAULT NULL,
  `order_delivery_canceled_at` bigint DEFAULT NULL,
  `order_assigned_at` bigint DEFAULT NULL,
  `order_scheduled_at` bigint DEFAULT NULL,
  `order_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `note` longtext COLLATE utf8mb3_unicode_ci,
  `total_menu_price` float(65,2) DEFAULT '0.00',
  `total_delivery_charge` float(65,2) DEFAULT '0.00',
  `total_vat_amount` float(65,2) DEFAULT '0.00',
  `service_fee` text COLLATE utf8mb3_unicode_ci,
  `tips_amount` float(65,2) DEFAULT '0.00',
  `coupon_amount` float(65,2) NOT NULL DEFAULT '0.00',
  `coupon_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `coupon_id` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT '',
  `caterign_charge_percentage_value` bigint DEFAULT NULL,
  `catering_change_title` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `catering_change` float(65,2) DEFAULT '0.00',
  `grand_total` float(65,2) DEFAULT '0.00',
  `payment_method` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_details` longtext COLLATE utf8mb3_unicode_ci,
  `payment_timestamp` longtext COLLATE utf8mb3_unicode_ci,
  `payment_status` longtext COLLATE utf8mb3_unicode_ci,
  `type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'pickup',
  `order_schedule_mode` text COLLATE utf8mb3_unicode_ci,
  `strip_status` bigint DEFAULT '0',
  `store_address` longtext COLLATE utf8mb3_unicode_ci,
  `store_location` text COLLATE utf8mb3_unicode_ci,
  `day` text COLLATE utf8mb3_unicode_ci,
  `schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `phone_isd_code` varchar(5) COLLATE utf8mb3_unicode_ci DEFAULT '+1',
  `apartment` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_add` longtext COLLATE utf8mb3_unicode_ci,
  `delivery_address_type` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `deliver_cod` longtext COLLATE utf8mb3_unicode_ci,
  `order_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_mode` int NOT NULL DEFAULT '0',
  `partyware` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `order_schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule_time` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `deliveryStatus` tinyint(1) DEFAULT '0',
  `admin_refund` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `pos_note` text COLLATE utf8mb3_unicode_ci,
  `pos_order_api` text COLLATE utf8mb3_unicode_ci,
  `pos_order_request` text COLLATE utf8mb3_unicode_ci,
  `pos_order_response` text COLLATE utf8mb3_unicode_ci,
  `pos_orderId` text COLLATE utf8mb3_unicode_ci,
  `pos_cancel_api` text COLLATE utf8mb3_unicode_ci,
  `pos_cancel_request` text COLLATE utf8mb3_unicode_ci,
  `pos_cancel_response` text COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_data` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_create_array` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array_data` text COLLATE utf8mb3_unicode_ci,
  `alert_5` tinyint(1) DEFAULT '0',
  `alert_10` tinyint(1) DEFAULT '0',
  `alert_15` tinyint(1) DEFAULT '0',
  `alert_20` tinyint(1) DEFAULT '0',
  `alert_25` tinyint(1) DEFAULT '0',
  `alert_30` tinyint(1) DEFAULT '0',
  `alert_60` tinyint(1) DEFAULT '0',
  `alert_120` tinyint(1) DEFAULT '0',
  `alert_180` tinyint(1) DEFAULT '0',
  `receipt_url` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_charge` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_capture` longtext COLLATE utf8mb3_unicode_ci,
  `refund_details` json DEFAULT NULL,
  `tracking_info` json DEFAULT NULL,
  `stripe_payment_intent_id` text COLLATE utf8mb3_unicode_ci,
  `order_source` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `tracking_token` varchar(34) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `show_order_in_app` tinyint NOT NULL DEFAULT '1',
  `redemption_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Redemption amount used in this order',
  `user_selection` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `kiosk_order_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_token` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_expiry` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_status` enum('0','1','2','3','4','5') COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '0 - Unused\r\n\r\n1-Used,2-Expired,3-Order accepted from merchant app,4-Order accepted from super admin,5-Order accepted from merchant portal',
  PRIMARY KEY (`id`),
  UNIQUE KEY `tracking_token` (`tracking_token`),
  KEY `idx_catering_orders_coupon` (`customer_id`,`coupon_code`,`coupon_id`),
  KEY `idx_orders_restaurant_date` (`oid`,`order_schedule_time`)
) ENGINE=InnoDB AUTO_INCREMENT=8029 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_paid_commissions`
--

DROP TABLE IF EXISTS `catering_paid_commissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_paid_commissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `marketing_des` text COLLATE utf8mb3_unicode_ci,
  `payout_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_provider_payout_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_provider` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `status` enum('paid','pending','failed') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `response_data` longtext COLLATE utf8mb3_unicode_ci,
  `payout_note` text COLLATE utf8mb3_unicode_ci,
  `start_date` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `end_date` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `balance_amount` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `paid_amount` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `marketing_fees` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `marketing_added_date` int DEFAULT NULL,
  `date_added` int DEFAULT NULL,
  `payment_method` enum('ach','other') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_rate_estimate`
--

DROP TABLE IF EXISTS `catering_rate_estimate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_rate_estimate` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `hit_count` bigint DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `cid` bigint DEFAULT NULL,
  `order_id` varchar(100) DEFAULT NULL,
  `quot_id` varchar(255) DEFAULT NULL,
  `request` longtext,
  `response` longtext,
  `message` longtext,
  `api_status` varchar(255) DEFAULT NULL,
  `date_time` varchar(255) DEFAULT NULL,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catering_webex_log`
--

DROP TABLE IF EXISTS `catering_webex_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catering_webex_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `req` longtext,
  `response` longtext,
  `time` varchar(255) DEFAULT NULL,
  `time_format` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ci_sessions`
--

DROP TABLE IF EXISTS `ci_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ci_sessions` (
  `id` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb3_unicode_ci NOT NULL,
  `timestamp` int unsigned NOT NULL DEFAULT '0',
  `data` blob NOT NULL,
  KEY `id` (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `id_2` (`id`),
  KEY `timestamp_2` (`timestamp`),
  KEY `timestamp_3` (`timestamp`),
  KEY `id_3` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `commission_details`
--

DROP TABLE IF EXISTS `commission_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `commission_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_bill` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_menu_bill` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `comm_val` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `comm_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'percent',
  `admin_commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `owner_commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_charge` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reg_service_fee` text COLLATE utf8mb3_unicode_ci,
  `inhouse_fees` decimal(10,2) DEFAULT '0.00',
  `bulk_order_fees` text COLLATE utf8mb3_unicode_ci,
  `cc_charge` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tips` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `merchant_tips` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `refunds` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stripe_refund` float(20,2) DEFAULT '0.00',
  `coupon` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_added` int DEFAULT NULL,
  `order_date` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `rewards_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Redemption amount',
  `rewards_settings_id` int DEFAULT NULL COMMENT 'Reward settings id used at the time of redemption',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `fk_commission_details_reward_settings` (`rewards_settings_id`),
  KEY `idx_restaurant_date` (`restaurant_id`,`date_added`),
  CONSTRAINT `fk_commission_details_reward_settings` FOREIGN KEY (`rewards_settings_id`) REFERENCES `reward_settings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4387 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cuisines`
--

DROP TABLE IF EXISTS `cuisines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuisines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `created_by` int DEFAULT NULL,
  `is_featured` int DEFAULT '0',
  `display_order` int NOT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `status` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `symbol` varchar(255) DEFAULT NULL,
  `paypal_supported` int DEFAULT NULL,
  `stripe_supported` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_reward_summary`
--

DROP TABLE IF EXISTS `customer_reward_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_reward_summary` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incremented primary key',
  `customer_id` int NOT NULL COMMENT 'Customer id from users table',
  `restaurant_id` int NOT NULL COMMENT 'Restaurant id from restaurants table',
  `total_points` int NOT NULL DEFAULT '0' COMMENT 'Total points currently available',
  `last_updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of the last update',
  PRIMARY KEY (`id`),
  KEY `fk_points_summary_customer` (`customer_id`),
  KEY `fk_points_summary_restaurant` (`restaurant_id`),
  CONSTRAINT `fk_points_summary_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_points_summary_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `address_1` longtext COLLATE utf8mb3_unicode_ci,
  `coordinate_1` longtext COLLATE utf8mb3_unicode_ci,
  `address_2` longtext COLLATE utf8mb3_unicode_ci,
  `coordinate_2` longtext COLLATE utf8mb3_unicode_ci,
  `address_3` longtext COLLATE utf8mb3_unicode_ci,
  `deliverysddress` longtext COLLATE utf8mb3_unicode_ci,
  `delivery_pincode` int DEFAULT '0',
  `deli_coordinate` longtext COLLATE utf8mb3_unicode_ci,
  `coordinate_3` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_customerid` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_customerdet` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=275 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_address_suggestions`
--

DROP TABLE IF EXISTS `delivery_address_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_address_suggestions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `address_id` varchar(225) COLLATE utf8mb4_general_ci NOT NULL,
  `user_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `default` tinyint(1) NOT NULL,
  `address_line_1` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `address_line_2` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `complete_address` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `place_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `region` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `zipcode` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `latitude` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `longitude` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `timezone` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `suite` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `landmark` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `main_text` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `secondary_text` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_address_id` (`address_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=372 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_charge`
--

DROP TABLE IF EXISTS `delivery_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_charge` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` bigint DEFAULT '0',
  `code` bigint NOT NULL DEFAULT '0',
  `charge` float(20,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=178 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_percentage`
--

DROP TABLE IF EXISTS `delivery_percentage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_percentage` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` bigint DEFAULT '0',
  `base_price` float(65,2) NOT NULL DEFAULT '0.00',
  `blwamount` float(20,2) NOT NULL DEFAULT '0.00',
  `deli_percentage` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_settings`
--

DROP TABLE IF EXISTS `delivery_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_slot`
--

DROP TABLE IF EXISTS `delivery_slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_slot` (
  `pickup_slot_id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT '0',
  `name` text NOT NULL,
  `slot_count` bigint DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`pickup_slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `demo_schedule`
--

DROP TABLE IF EXISTS `demo_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `demo_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fname` varchar(255) DEFAULT NULL,
  `lname` varchar(255) DEFAULT NULL,
  `emaill` varchar(255) DEFAULT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `zip` int DEFAULT NULL,
  `vehicle_code` varchar(255) DEFAULT NULL,
  `itype` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `status` int DEFAULT '1',
  `types` varchar(255) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `drivers`
--

DROP TABLE IF EXISTS `drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drivers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `vehicle_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_log`
--

DROP TABLE IF EXISTS `email_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` text,
  `restaurant_id` bigint DEFAULT NULL,
  `r_slug` varchar(255) DEFAULT 'Boons',
  `smtpuser` text,
  `smtppassword` text,
  `from_email` text,
  `to_mail` varchar(255) DEFAULT NULL,
  `subject` text,
  `webex_subject` text,
  `message` longtext,
  `merchant_message` longtext,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `send_date` varchar(255) DEFAULT NULL,
  `email_log` text,
  `sms_log_customer` text,
  `sms_log_4087689078` text,
  `sms_log_4088236172` text,
  `sms_log_9994705245` text,
  `sms_log_store` text,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22417 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_log_bk`
--

DROP TABLE IF EXISTS `email_log_bk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_log_bk` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` text,
  `restaurant_id` bigint DEFAULT NULL,
  `r_slug` varchar(255) DEFAULT 'Boons',
  `smtpuser` text,
  `smtppassword` text,
  `from_email` text,
  `to_mail` varchar(255) DEFAULT NULL,
  `subject` text,
  `message` longtext,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `send_date` varchar(255) DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=766 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_campaign`
--

DROP TABLE IF EXISTS `email_marketing_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_campaign` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `template_id` int NOT NULL,
  `campaign_name` varchar(255) NOT NULL,
  `campaign_subject` varchar(50) NOT NULL,
  `campaign_preview_text` varchar(50) DEFAULT NULL,
  `campaign_id` varchar(255) NOT NULL,
  `campaign_analytics_engine_status` varchar(50) DEFAULT 'pending' COMMENT 'This column stores engine campaign status (draft, scheduled, trigerred)',
  `campaign_status` varchar(50) DEFAULT 'draft' COMMENT 'This column stores boons campaign status (draft, scheduled, sent)',
  `campaign_type` enum('draft','instant','schedule','recurring') DEFAULT 'instant',
  `audience_criteria` json NOT NULL,
  `schedule_criteria` json NOT NULL,
  `audience` longtext NOT NULL COMMENT 'This column stores audience data',
  `recipient_list_id` varchar(255) DEFAULT NULL COMMENT 'This column stores contacts segment ID',
  `analytics_engine` varchar(50) DEFAULT 'sendgrid',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_campaign_status_logs`
--

DROP TABLE IF EXISTS `email_marketing_campaign_status_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_campaign_status_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `campaign_id` varchar(255) NOT NULL,
  `sendgrid_status` varchar(50) NOT NULL,
  `created_at` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_field`
--

DROP TABLE IF EXISTS `email_marketing_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_field` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `field_name` varchar(255) DEFAULT NULL,
  `field_value` varchar(255) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_recurring_campaign`
--

DROP TABLE IF EXISTS `email_marketing_recurring_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_recurring_campaign` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `template_id` int NOT NULL,
  `campaign_name` varchar(255) NOT NULL,
  `campaign_subject` varchar(50) NOT NULL,
  `campaign_preview_text` varchar(50) DEFAULT NULL,
  `parent_campaign_id` varchar(255) NOT NULL,
  `campaign_id` varchar(255) NOT NULL,
  `campaign_analytics_engine_status` varchar(50) DEFAULT 'pending' COMMENT 'This column stores engine campaign status (draft, scheduled, trigerred)',
  `campaign_status` varchar(50) DEFAULT 'draft' COMMENT 'This column stores boons campaign status (draft, scheduled, sent)',
  `campaign_type` enum('draft','instant','schedule','recurring') DEFAULT 'instant',
  `audience_criteria` json NOT NULL,
  `schedule_criteria` json NOT NULL,
  `audience` longtext NOT NULL COMMENT 'This column stores audience data',
  `recipient_list_id` varchar(255) DEFAULT NULL COMMENT 'This column stores contacts segment ID',
  `analytics_engine` varchar(50) DEFAULT 'sendgrid',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_segment`
--

DROP TABLE IF EXISTS `email_marketing_segment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_segment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `segment_id` varchar(255) NOT NULL,
  `restaurant_id` int NOT NULL,
  `email` longtext NOT NULL,
  `created_at` int NOT NULL,
  `updated_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_template`
--

DROP TABLE IF EXISTS `email_marketing_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL COMMENT 'Reference to the restaurant.If restaurant_id 0 means global template',
  `template_type` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Saved template or global template(standard or holiday)',
  `template_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Human-readable template name',
  `template_category_id` int NOT NULL COMMENT 'Reference to email_marketing_category',
  `template_content` longtext COLLATE utf8mb4_general_ci NOT NULL COMMENT 'HTML/Email body content with S3 image URLs',
  `thumbnail_image` mediumblob,
  `thumbnail_image_name` text COLLATE utf8mb4_general_ci COMMENT 'Image name',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '0 = Inactive, 1 = Active',
  `created_date` int NOT NULL COMMENT 'Creation timestamp in Unix epoch format',
  `updated_date` int NOT NULL COMMENT 'Last update timestamp in Unix epoch format',
  PRIMARY KEY (`id`),
  KEY `template_category_id` (`template_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=660 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_template_bk`
--

DROP TABLE IF EXISTS `email_marketing_template_bk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_template_bk` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL COMMENT 'Reference to the restaurant',
  `template_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Human-readable template name',
  `template_content` longtext COLLATE utf8mb4_general_ci NOT NULL COMMENT 'HTML/Email body content',
  `thumbnail_image` blob COMMENT 'image base64 URL',
  `thumbnail_image_name` text COLLATE utf8mb4_general_ci COMMENT 'image name',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '0 = Inactive, 1 = Active',
  `created_date` int NOT NULL COMMENT 'Creation timestamp in Unix epoch format',
  `updated_date` int NOT NULL COMMENT 'Last update timestamp in Unix epoch format',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_template_category`
--

DROP TABLE IF EXISTS `email_marketing_template_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_template_category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Category name (Standard, Holiday, etc.)',
  `display_order` int NOT NULL COMMENT 'Defines order of display',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '0 = Inactive, 1 = Active',
  `created_date` int NOT NULL COMMENT 'Creation timestamp in Unix epoch format',
  `updated_date` int NOT NULL COMMENT 'Last update timestamp in Unix epoch format',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_marketing_template_images`
--

DROP TABLE IF EXISTS `email_marketing_template_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_marketing_template_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int NOT NULL COMMENT 'Reference to email_marketing_template',
  `image_type` enum('thumbnail','banner','section','social_media_instagram','social_media_facebook','social_media_linkedin') COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Defines the type of image',
  `image_url` json NOT NULL COMMENT 'JSON array of S3 URLs for the image type',
  `created_date` int NOT NULL COMMENT 'Creation timestamp in Unix epoch format',
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `email_marketing_template_images_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `email_marketing_template` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_template`
--

DROP TABLE IF EXISTS `email_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_template` (
  `email_template_id` int NOT NULL AUTO_INCREMENT,
  `sid` int NOT NULL DEFAULT '0',
  `title` longtext NOT NULL,
  `subject` longtext NOT NULL,
  `body` longtext NOT NULL,
  `image` varchar(255) NOT NULL,
  `added_by` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '1',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`email_template_id`)
) ENGINE=InnoDB AUTO_INCREMENT=218 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emailsubs`
--

DROP TABLE IF EXISTS `emailsubs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emailsubs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subs_email` varchar(255) DEFAULT NULL,
  `rest_id` varchar(255) NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '1',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_commission_details`
--

DROP TABLE IF EXISTS `event_commission_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_commission_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_bill` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_menu_bill` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `comm_val` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `comm_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'percent',
  `admin_commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `owner_commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reg_service_fee` text COLLATE utf8mb3_unicode_ci,
  `cc_charge` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tips` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `merchant_tips` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `refunds` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stripe_refund` float(20,2) DEFAULT '0.00',
  `coupon` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_added` int DEFAULT NULL,
  `order_date` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_order_details`
--

DROP TABLE IF EXISTS `event_order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `edit_status` tinyint(1) NOT NULL DEFAULT '0',
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `menu_id` text COLLATE utf8mb3_unicode_ci,
  `menu_name` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `order_quantity` bigint DEFAULT NULL,
  `total` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `orig_details` text COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_orders`
--

DROP TABLE IF EXISTS `event_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `auto_cancel` tinyint(1) DEFAULT '0',
  `rs` tinyint(1) DEFAULT '0',
  `pu_status` int DEFAULT '0',
  `spu_status` int DEFAULT '0',
  `show_status` tinyint(1) DEFAULT '0',
  `cancel_fee` text COLLATE utf8mb3_unicode_ci,
  `increment_val` bigint DEFAULT NULL,
  `increment_status` tinyint(1) DEFAULT '0',
  `cart_data` text COLLATE utf8mb3_unicode_ci,
  `strip_pass_amt` text COLLATE utf8mb3_unicode_ci,
  `order_amount` text COLLATE utf8mb3_unicode_ci,
  `admin_discount` double(10,2) DEFAULT '0.00',
  `admin_add` double(10,2) DEFAULT '0.00',
  `admin_reason` text COLLATE utf8mb3_unicode_ci,
  `strip_payment_key` text COLLATE utf8mb3_unicode_ci,
  `delivery_notes` text COLLATE utf8mb3_unicode_ci,
  `code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `oid` bigint DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `customer_address_id` int DEFAULT NULL,
  `order_placed_at` int DEFAULT NULL,
  `order_approved_at` int DEFAULT NULL,
  `order_preparing_at` int DEFAULT NULL,
  `order_prepared_at` int DEFAULT NULL,
  `order_ready_at` int DEFAULT NULL,
  `order_initiated_at` int DEFAULT NULL,
  `order_trip_created_at` int DEFAULT NULL,
  `order_in_progress_at` int DEFAULT NULL,
  `order_returned_at` int DEFAULT NULL,
  `order_delayed_at` int DEFAULT NULL,
  `order_pickup_at` int DEFAULT NULL,
  `order_picked_up_at` int DEFAULT NULL,
  `order_auto_cancel_at` int DEFAULT NULL,
  `order_pickuped_at` bigint DEFAULT NULL,
  `order_canceled_at` int DEFAULT NULL,
  `order_assigned_at` bigint DEFAULT NULL,
  `order_scheduled_at` bigint DEFAULT NULL,
  `order_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `note` longtext COLLATE utf8mb3_unicode_ci,
  `total_menu_price` float(65,2) DEFAULT '0.00',
  `total_vat_amount` float(65,2) DEFAULT '0.00',
  `service_fee` text COLLATE utf8mb3_unicode_ci,
  `tips_amount` float(65,2) DEFAULT '0.00',
  `coupon_amount` float(65,2) NOT NULL DEFAULT '0.00',
  `coupon_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `coupon_id` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `grand_total` float(65,2) DEFAULT '0.00',
  `payment_method` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_details` longtext COLLATE utf8mb3_unicode_ci,
  `payment_timestamp` longtext COLLATE utf8mb3_unicode_ci,
  `payment_status` longtext COLLATE utf8mb3_unicode_ci,
  `type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'pickup',
  `order_schedule_mode` text COLLATE utf8mb3_unicode_ci,
  `strip_status` bigint DEFAULT '0',
  `store_address` longtext COLLATE utf8mb3_unicode_ci,
  `store_location` text COLLATE utf8mb3_unicode_ci,
  `day` text COLLATE utf8mb3_unicode_ci,
  `schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `apartment` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_mode` int NOT NULL DEFAULT '0',
  `order_schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule_time` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `admin_refund` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_data` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_create_array` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array_data` text COLLATE utf8mb3_unicode_ci,
  `alert_5` tinyint(1) DEFAULT '0',
  `alert_10` tinyint(1) DEFAULT '0',
  `alert_15` tinyint(1) DEFAULT '0',
  `alert_20` tinyint(1) DEFAULT '0',
  `receipt_url` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_charge` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_capture` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_cancel` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Event id for event url',
  `restaurant_id` int NOT NULL,
  `event_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `event_description` text COLLATE utf8mb4_general_ci NOT NULL,
  `event_date` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Event date and time',
  `event_type` enum('Pickup','Dine-in') COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Event type - Pickup or Dine in',
  `event_address` text COLLATE utf8mb4_general_ci NOT NULL,
  `event_url` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `event_cutoff` longtext COLLATE utf8mb4_general_ci COMMENT 'Event cutoff time',
  `event_status` enum('0','1','2') COLLATE utf8mb4_general_ci NOT NULL COMMENT '''0'' - Disable,''1'' - Enable,''2'' - delete',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Event_id` (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='For events management';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events_food_menus`
--

DROP TABLE IF EXISTS `events_food_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events_food_menus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `details` longtext COLLATE utf8mb3_unicode_ci,
  `nutrition_fact` longtext COLLATE utf8mb3_unicode_ci,
  `options` longtext COLLATE utf8mb3_unicode_ci,
  `multi` int DEFAULT '0',
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `availability` int DEFAULT NULL,
  `has_discount` longtext COLLATE utf8mb3_unicode_ci,
  `price` longtext COLLATE utf8mb3_unicode_ci,
  `discounted_price` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax_details` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tag_popular` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `normal_limit` int NOT NULL DEFAULT '0',
  `normal_totalitems_ordered` int NOT NULL DEFAULT '0',
  `created_type` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Menu created type - new or copied from regular menu',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `f_order_details`
--

DROP TABLE IF EXISTS `f_order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `f_order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `menu_id` int DEFAULT NULL,
  `menu_name` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `total` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_code` (`order_code`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `f_order_log`
--

DROP TABLE IF EXISTS `f_order_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `f_order_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` text,
  `cart_date` longtext,
  `rid` bigint DEFAULT NULL,
  `cid` bigint DEFAULT NULL,
  `name` text,
  `email` text,
  `mobile` text,
  `address` text,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `f_orders`
--

DROP TABLE IF EXISTS `f_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `f_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `failed_reason` text COLLATE utf8mb3_unicode_ci,
  `dc` bigint DEFAULT '0',
  `delay_status` tinyint(1) DEFAULT '0',
  `show_status` tinyint(1) DEFAULT '0',
  `delivery_track_id` text COLLATE utf8mb3_unicode_ci,
  `quote_estimate_id` text COLLATE utf8mb3_unicode_ci,
  `cancel_fee` text COLLATE utf8mb3_unicode_ci,
  `increment_val` bigint DEFAULT NULL,
  `increment_status` tinyint(1) DEFAULT '0',
  `cart_data` text COLLATE utf8mb3_unicode_ci,
  `strip_pass_amt` text COLLATE utf8mb3_unicode_ci,
  `order_amount` text COLLATE utf8mb3_unicode_ci,
  `admin_discount` double(10,2) DEFAULT '0.00',
  `admin_add` double(10,2) DEFAULT '0.00',
  `admin_reason` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array_data` text COLLATE utf8mb3_unicode_ci,
  `pack` tinyint(1) DEFAULT '0',
  `strip_payment_key` text COLLATE utf8mb3_unicode_ci,
  `delivery_api_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_notes` text COLLATE utf8mb3_unicode_ci,
  `complete_email` tinyint(1) DEFAULT '0',
  `code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `oid` bigint DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `customer_address_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `order_placed_at` int DEFAULT NULL,
  `order_approved_at` int DEFAULT NULL,
  `order_preparing_at` int DEFAULT NULL,
  `order_prepared_at` int DEFAULT NULL,
  `order_ready_at` int DEFAULT NULL,
  `order_initiated_at` int DEFAULT NULL,
  `order_trip_created_at` int DEFAULT NULL,
  `order_in_progress_at` int DEFAULT NULL,
  `order_returned_at` int DEFAULT NULL,
  `order_delayed_at` int DEFAULT NULL,
  `order_pickup_at` int DEFAULT NULL,
  `order_picked_up_at` int DEFAULT NULL,
  `order_auto_cancel_at` int DEFAULT NULL,
  `order_delivered_at` int DEFAULT NULL,
  `order_pickuped_at` bigint DEFAULT NULL,
  `order_canceled_at` int DEFAULT NULL,
  `order_assigned_at` bigint DEFAULT NULL,
  `order_scheduled_at` bigint DEFAULT NULL,
  `order_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `note` longtext COLLATE utf8mb3_unicode_ci,
  `total_menu_price` float(65,2) DEFAULT '0.00',
  `total_delivery_charge` float(65,2) DEFAULT '0.00',
  `total_vat_amount` float(65,2) DEFAULT '0.00',
  `tips_amount` float(65,2) DEFAULT '0.00',
  `coupon_amount` float(65,2) NOT NULL DEFAULT '0.00',
  `coupon_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `grand_total` float(65,2) DEFAULT '0.00',
  `payment_method` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_details` longtext COLLATE utf8mb3_unicode_ci,
  `payment_timestamp` longtext COLLATE utf8mb3_unicode_ci,
  `payment_status` longtext COLLATE utf8mb3_unicode_ci,
  `type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'pickup',
  `order_schedule_mode` text COLLATE utf8mb3_unicode_ci,
  `strip_status` bigint DEFAULT '0',
  `store_address` longtext COLLATE utf8mb3_unicode_ci,
  `store_location` text COLLATE utf8mb3_unicode_ci,
  `day` text COLLATE utf8mb3_unicode_ci,
  `schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `apartment` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_add` longtext COLLATE utf8mb3_unicode_ci,
  `deliver_cod` longtext COLLATE utf8mb3_unicode_ci,
  `order_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule_time` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `deliveryStatus` tinyint(1) DEFAULT '0',
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `receipt_url` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_charge` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_capture` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_cancel` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `driver_id` (`driver_id`),
  KEY `code` (`code`),
  KEY `order_status` (`order_status`),
  KEY `order_placed_at` (`order_placed_at`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `f_rewards_log`
--

DROP TABLE IF EXISTS `f_rewards_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `f_rewards_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incremented primary key',
  `customer_id` int NOT NULL COMMENT 'Customer id',
  `restaurant_id` int NOT NULL COMMENT 'Restaurant id from restaurants table',
  `order_id` varchar(100) NOT NULL COMMENT 'Order code',
  `error_message` varchar(255) DEFAULT NULL,
  `notes` varchar(100) DEFAULT NULL COMMENT 'Completion or Cancellation of order',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the record insertion',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `favourites`
--

DROP TABLE IF EXISTS `favourites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favourites` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int DEFAULT NULL,
  `menu_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fees_history`
--

DROP TABLE IF EXISTS `fees_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fees_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `paid_commission_id` int NOT NULL,
  `fees` decimal(10,2) NOT NULL DEFAULT '0.00',
  `usage_month` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usage_type` enum('reward_commission','marketing_fees','disputes') COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_id` (`restaurant_id`),
  KEY `idx_paid_commission_id` (`paid_commission_id`),
  KEY `idx_usage_month` (`usage_month`),
  KEY `idx_status` (`status`),
  KEY `idx_usage_type` (`usage_type`),
  CONSTRAINT `fk_fees_paid_commission` FOREIGN KEY (`paid_commission_id`) REFERENCES `paid_commissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `food_categories`
--

DROP TABLE IF EXISTS `food_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `is_featured` int NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `status` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=943 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `food_menus`
--

DROP TABLE IF EXISTS `food_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_menus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `special` tinyint(1) DEFAULT '0',
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `item_limit` text COLLATE utf8mb3_unicode_ci,
  `category_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `items` longtext COLLATE utf8mb3_unicode_ci,
  `details` longtext COLLATE utf8mb3_unicode_ci,
  `nutrition_fact` longtext COLLATE utf8mb3_unicode_ci,
  `options` longtext COLLATE utf8mb3_unicode_ci,
  `modifiers` longtext COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Modifier ids in CSV format',
  `multi` int DEFAULT '0',
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `availability` int DEFAULT NULL,
  `has_discount` longtext COLLATE utf8mb3_unicode_ci,
  `price` longtext COLLATE utf8mb3_unicode_ci,
  `discounted_price` longtext COLLATE utf8mb3_unicode_ci,
  `time_price` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax_details` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tag_popular` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `sort_order` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_food_menus_restaurant_status_category` (`restaurant_id`,`status`,`category_id`),
  CONSTRAINT `food_menus_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `food_menus_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `food_categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22378 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `food_menus_bk`
--

DROP TABLE IF EXISTS `food_menus_bk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_menus_bk` (
  `id` int NOT NULL AUTO_INCREMENT,
  `special` tinyint(1) DEFAULT '0',
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `item_limit` text COLLATE utf8mb3_unicode_ci,
  `category_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `items` longtext COLLATE utf8mb3_unicode_ci,
  `details` longtext COLLATE utf8mb3_unicode_ci,
  `nutrition_fact` longtext COLLATE utf8mb3_unicode_ci,
  `options` longtext COLLATE utf8mb3_unicode_ci,
  `multi` int DEFAULT '0',
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `availability` int DEFAULT NULL,
  `has_discount` longtext COLLATE utf8mb3_unicode_ci,
  `price` longtext COLLATE utf8mb3_unicode_ci,
  `discounted_price` longtext COLLATE utf8mb3_unicode_ci,
  `time_price` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax_details` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tag_popular` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15603 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `google_conversion_tracking`
--

DROP TABLE IF EXISTS `google_conversion_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `google_conversion_tracking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_tracking` longtext NOT NULL,
  `rwg_token` text NOT NULL,
  `merchant_id` varchar(255) NOT NULL,
  `user_id` int DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL,
  `expired_at` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `google_conversion_tracking_log`
--

DROP TABLE IF EXISTS `google_conversion_tracking_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `google_conversion_tracking_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_data` text,
  `endpoint` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `created_at` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gr_delivery_api`
--

DROP TABLE IF EXISTS `gr_delivery_api`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gr_delivery_api` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` text,
  `mode` text,
  `oid` bigint DEFAULT NULL,
  `url` text,
  `request` text,
  `response` text,
  `created_Date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  `api_status` text,
  `origin` text,
  `executionTime` text,
  `uid` text,
  `sessionid` text,
  `delivery_id` text,
  `org_id` text,
  `count` text,
  `failed` tinyint(1) DEFAULT '0',
  `processed_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4761 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kiosk_order_sequence`
--

DROP TABLE IF EXISTS `kiosk_order_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kiosk_order_sequence` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `order_date` bigint NOT NULL,
  `last_sequence` int NOT NULL,
  `updated_at` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_sequence` (`restaurant_id`,`order_date`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `code` char(2) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location_connections`
--

DROP TABLE IF EXISTS `location_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location_connections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `location_id` varchar(100) NOT NULL,
  `status` enum('connected','disconnected') NOT NULL DEFAULT 'connected',
  `connected` tinyint(1) NOT NULL DEFAULT '1',
  `connected_at` int DEFAULT NULL,
  `disconnected_at` int DEFAULT NULL,
  `menu_ingestion_status` varchar(100) DEFAULT NULL,
  `menu_ingestion_s3_url` json DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `login_log`
--

DROP TABLE IF EXISTS `login_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` varchar(255) NOT NULL,
  `deviceToken` longtext,
  `appname` varchar(255) DEFAULT NULL,
  `created_at` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `status` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1034 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `master_pos_type`
--

DROP TABLE IF EXISTS `master_pos_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `master_pos_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pos_type` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu_log`
--

DROP TABLE IF EXISTS `menu_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `menu_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `admin_id` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `modifiers`
--

DROP TABLE IF EXISTS `modifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `modifiers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `modifier` longtext COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Modifier details in JSON format',
  `type` enum('Regular','Catering') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Regular',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1740 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='For restaurant modifiers';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `newsletter`
--

DROP TABLE IF EXISTS `newsletter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletter` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_email` varchar(255) DEFAULT NULL,
  `to_email` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `content` text,
  `status` tinyint(1) DEFAULT '1',
  `created_status` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notification_log`
--

DROP TABLE IF EXISTS `notification_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` text,
  `oidd` bigint DEFAULT '0',
  `notification_content` longtext,
  `status` int DEFAULT '0',
  `send_date` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=596827 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notification_preference`
--

DROP TABLE IF EXISTS `notification_preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_preference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `role` enum('Super Admin','Merchant','Custom') COLLATE utf8mb4_general_ci NOT NULL,
  `custom_type` enum('email','phone') COLLATE utf8mb4_general_ci DEFAULT NULL,
  `custom_email` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `custom_phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `order_placed` tinyint(1) DEFAULT '0',
  `order_completed` tinyint(1) DEFAULT '0',
  `order_cancelled` tinyint(1) DEFAULT '0',
  `order_not_accepted` tinyint(1) DEFAULT '0',
  `delivery_failed` tinyint(1) DEFAULT '0',
  `other_failures` tinyint(1) DEFAULT '0',
  `regular` tinyint(1) DEFAULT '0',
  `catering` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_role` (`restaurant_id`,`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_details`
--

DROP TABLE IF EXISTS `order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `edit_status` tinyint(1) NOT NULL DEFAULT '0',
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `menu_id` text COLLATE utf8mb3_unicode_ci,
  `menu_name` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `order_quantity` bigint DEFAULT NULL,
  `total` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `add_on` longtext COLLATE utf8mb3_unicode_ci,
  `orig_details` text COLLATE utf8mb3_unicode_ci,
  `instructions` longtext COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `original_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_code` (`order_code`)
) ENGINE=InnoDB AUTO_INCREMENT=16879 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_history`
--

DROP TABLE IF EXISTS `order_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `process_by` varchar(50) NOT NULL,
  `particulars` text NOT NULL,
  `time_format` bigint NOT NULL,
  `created_data` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=165233 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_log`
--

DROP TABLE IF EXISTS `order_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` text,
  `cart_date` longtext,
  `rid` bigint DEFAULT NULL,
  `cid` bigint DEFAULT NULL,
  `name` text,
  `email` text,
  `mobile` text,
  `address` text,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=126091 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_refund`
--

DROP TABLE IF EXISTS `order_refund`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_refund` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `amount` varchar(255) DEFAULT '0',
  `remarks` text,
  `refund_item_details` longtext COMMENT 'Refunded item details with name, price, quantity and tax',
  `stripe_key` text,
  `refund_response` text,
  `refund_key` text,
  `transaction_key` text,
  `mode_status` varchar(255) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=212 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `delivery_to_pickup` tinyint(1) DEFAULT '0',
  `delivery_to_pickup_time` bigint DEFAULT NULL,
  `delivery_to_pickup_time_15` bigint DEFAULT NULL,
  `auto_cancel` tinyint(1) DEFAULT '0',
  `delivery_api_failed` tinyint(1) NOT NULL DEFAULT '0',
  `flag` tinyint(1) NOT NULL DEFAULT '1',
  `rs` tinyint(1) DEFAULT '0',
  `pos` tinyint(1) DEFAULT '0',
  `dc` bigint DEFAULT '0',
  `pu_status` int DEFAULT '0',
  `spu_status` int DEFAULT '0',
  `delay_status` tinyint(1) DEFAULT '0',
  `show_status` tinyint(1) DEFAULT '0',
  `delivery_track_id` text COLLATE utf8mb3_unicode_ci,
  `quote_estimate_id` text COLLATE utf8mb3_unicode_ci,
  `cancel_fee` text COLLATE utf8mb3_unicode_ci,
  `increment_val` bigint DEFAULT NULL,
  `increment_status` tinyint(1) DEFAULT '0',
  `cart_data` text COLLATE utf8mb3_unicode_ci,
  `strip_pass_amt` decimal(10,2) DEFAULT NULL,
  `order_amount` text COLLATE utf8mb3_unicode_ci,
  `pos_different_amount` text COLLATE utf8mb3_unicode_ci,
  `admin_discount` double(10,2) DEFAULT '0.00',
  `admin_add` double(10,2) DEFAULT '0.00',
  `admin_reason` text COLLATE utf8mb3_unicode_ci,
  `email_sending_status` tinyint(1) DEFAULT '0',
  `strip_payment_key` text COLLATE utf8mb3_unicode_ci,
  `delivery_api_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_notes` text COLLATE utf8mb3_unicode_ci,
  `complete_email` tinyint(1) DEFAULT '0',
  `code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `oid` bigint DEFAULT '0',
  `customer_id` int DEFAULT NULL,
  `customer_address_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `order_placed_at` int DEFAULT NULL,
  `order_approved_at` int DEFAULT NULL,
  `order_preparing_at` int DEFAULT NULL,
  `order_prepared_at` int DEFAULT NULL,
  `order_ready_at` int DEFAULT NULL,
  `order_initiated_at` int DEFAULT NULL,
  `order_trip_created_at` int DEFAULT NULL,
  `order_in_progress_at` int DEFAULT NULL,
  `order_returned_at` int DEFAULT NULL,
  `order_delayed_at` int DEFAULT NULL,
  `order_pickup_at` int DEFAULT NULL,
  `order_picked_up_at` int DEFAULT NULL,
  `order_auto_cancel_at` int DEFAULT NULL,
  `order_delivered_at` int DEFAULT NULL,
  `order_pickuped_at` bigint DEFAULT NULL,
  `order_canceled_at` int DEFAULT NULL,
  `order_delivery_canceled_at` bigint DEFAULT NULL,
  `order_assigned_at` bigint DEFAULT NULL,
  `order_scheduled_at` bigint DEFAULT NULL,
  `order_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `note` longtext COLLATE utf8mb3_unicode_ci,
  `total_menu_price` float(65,2) DEFAULT '0.00',
  `total_delivery_charge` float(65,2) DEFAULT '0.00',
  `total_vat_amount` float(65,2) DEFAULT '0.00',
  `service_fee` text COLLATE utf8mb3_unicode_ci,
  `tips_amount` float(65,2) DEFAULT '0.00',
  `coupon_amount` float(65,2) DEFAULT '0.00',
  `coupon_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `coupon_id` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `caterign_charge_percentage_value` bigint DEFAULT NULL,
  `catering_change_title` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `catering_change` float(65,2) DEFAULT '0.00',
  `grand_total` float(65,2) DEFAULT '0.00',
  `payment_method` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_details` longtext COLLATE utf8mb3_unicode_ci,
  `payment_timestamp` longtext COLLATE utf8mb3_unicode_ci,
  `payment_status` longtext COLLATE utf8mb3_unicode_ci,
  `type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'pickup',
  `order_schedule_mode` text COLLATE utf8mb3_unicode_ci,
  `strip_status` bigint DEFAULT '0',
  `store_address` longtext COLLATE utf8mb3_unicode_ci,
  `store_location` text COLLATE utf8mb3_unicode_ci,
  `day` text COLLATE utf8mb3_unicode_ci,
  `schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `phone_isd_code` varchar(5) COLLATE utf8mb3_unicode_ci DEFAULT '+1',
  `apartment` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_add` longtext COLLATE utf8mb3_unicode_ci,
  `delivery_address_type` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `deliver_cod` longtext COLLATE utf8mb3_unicode_ci,
  `order_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_mode` int NOT NULL DEFAULT '0',
  `order_schedule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_schedule_time` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `deliveryStatus` tinyint(1) DEFAULT '0',
  `admin_refund` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `pos_note` text COLLATE utf8mb3_unicode_ci,
  `pos_order_api` text COLLATE utf8mb3_unicode_ci,
  `pos_order_request` text COLLATE utf8mb3_unicode_ci,
  `pos_order_response` text COLLATE utf8mb3_unicode_ci,
  `pos_orderId` text COLLATE utf8mb3_unicode_ci,
  `pos_cancel_api` text COLLATE utf8mb3_unicode_ci,
  `pos_cancel_request` text COLLATE utf8mb3_unicode_ci,
  `pos_cancel_response` text COLLATE utf8mb3_unicode_ci,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_data` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_create_array` text COLLATE utf8mb3_unicode_ci,
  `stripe_create_array_data` text COLLATE utf8mb3_unicode_ci,
  `alert_5` tinyint(1) DEFAULT '0',
  `alert_10` tinyint(1) DEFAULT '0',
  `alert_15` tinyint(1) DEFAULT '0',
  `alert_20` tinyint(1) DEFAULT '0',
  `alert_25` tinyint(1) DEFAULT '0',
  `alert_30` tinyint(1) DEFAULT '0',
  `alert_60` tinyint(1) DEFAULT '0',
  `alert_120` tinyint(1) DEFAULT '0',
  `alert_180` tinyint(1) DEFAULT '0',
  `receipt_url` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_charge` longtext COLLATE utf8mb3_unicode_ci,
  `stripe_capture` longtext COLLATE utf8mb3_unicode_ci,
  `refund_details` json DEFAULT NULL,
  `tracking_info` json DEFAULT NULL,
  `stripe_payment_intent_id` text COLLATE utf8mb3_unicode_ci,
  `partyware` text COLLATE utf8mb3_unicode_ci,
  `order_source` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `tracking_token` varchar(32) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `show_order_in_app` tinyint NOT NULL DEFAULT '1',
  `redemption_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Redemption amount used in this order',
  `user_selection` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `kiosk_order_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `order_token` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_expiry` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_status` enum('0','1','2','3','4','5') COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '0 - Unused,1-Used,2-Expired,3-Order accepted from merchant app,4-Order accepted from super admin,5-Order accepted from merchant portal',
  PRIMARY KEY (`id`),
  UNIQUE KEY `tracking_token` (`tracking_token`),
  KEY `customer_id` (`customer_id`),
  KEY `driver_id` (`driver_id`),
  KEY `code` (`code`),
  KEY `order_status` (`order_status`),
  KEY `order_placed_at` (`order_placed_at`),
  KEY `type` (`type`),
  KEY `idx_orders_coupon` (`customer_id`,`coupon_code`,`coupon_id`),
  KEY `idx_orders_restaurant_date` (`oid`,`order_schedule_time`)
) ENGINE=InnoDB AUTO_INCREMENT=12603 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `otp_request`
--

DROP TABLE IF EXISTS `otp_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `otp_request` (
  `id` int NOT NULL AUTO_INCREMENT,
  `request_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Unique Id',
  `message_data` text COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Restaurant data',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=608 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `owner_audit_log`
--

DROP TABLE IF EXISTS `owner_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owner_audit_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `action_type` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `performed_by` int NOT NULL,
  `remarks` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `owner_restaurant_mapping`
--

DROP TABLE IF EXISTS `owner_restaurant_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owner_restaurant_mapping` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `assigned_by` int NOT NULL,
  `status` tinyint(1) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `owner_role_management`
--

DROP TABLE IF EXISTS `owner_role_management`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owner_role_management` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paid_commissions`
--

DROP TABLE IF EXISTS `paid_commissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paid_commissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rewards_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Commission fee for every month or remaining amount to be paid',
  `rewards_month` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Year and month of commission (e.g., 2025-08)',
  `restaurant_id` int DEFAULT NULL,
  `marketing_des` text COLLATE utf8mb3_unicode_ci,
  `payout_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_provider_payout_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payment_provider` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `status` enum('paid','pending','failed','') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `start_date` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `end_date` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `balance_amount` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `paid_amount` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `marketing_fees` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `marketing_added_date` int DEFAULT NULL,
  `date_added` int DEFAULT NULL,
  `response_data` json NOT NULL,
  `payout_note` text COLLATE utf8mb3_unicode_ci,
  `payment_method` enum('ach','other') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `base_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Base commission for the month rewards',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=452 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payout_email`
--

DROP TABLE IF EXISTS `payout_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_email` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `to_email` text NOT NULL,
  `created_at` int unsigned NOT NULL,
  `updated_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pickup_slot`
--

DROP TABLE IF EXISTS `pickup_slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_slot` (
  `pickup_slot_id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT '0',
  `name` text NOT NULL,
  `slot_count` bigint DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`pickup_slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_categories_time`
--

DROP TABLE IF EXISTS `pos_categories_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_categories_time` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `category_id` int NOT NULL,
  `timeslots` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'JSON object with days and time',
  `categorytime_status` enum('0','1') COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0' COMMENT 'Category time slot status',
  `updated_on` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_categories_time_restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=183 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_configuration`
--

DROP TABLE IF EXISTS `pos_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_configuration` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `pos_type` varchar(50) NOT NULL,
  `pos_restaurant_id` varchar(255) NOT NULL,
  `webhooks` json DEFAULT NULL,
  `scheduled_delivery_trip_creation` varchar(255) DEFAULT NULL,
  `pos_integration_config` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `schedule_cutoff_time` json DEFAULT NULL,
  `closure_date` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `pos_configuration_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_food_categories`
--

DROP TABLE IF EXISTS `pos_food_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_food_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restaurant_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `is_featured` int NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `status` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_food_menus`
--

DROP TABLE IF EXISTS `pos_food_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_food_menus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `special` tinyint(1) DEFAULT '0',
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `item_limit` text COLLATE utf8mb3_unicode_ci,
  `category_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `items` longtext COLLATE utf8mb3_unicode_ci,
  `details` longtext COLLATE utf8mb3_unicode_ci,
  `nutrition_fact` longtext COLLATE utf8mb3_unicode_ci,
  `options` longtext COLLATE utf8mb3_unicode_ci,
  `modifiers` longtext COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Modifier ids in CSV format',
  `multi` int DEFAULT '0',
  `servings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `availability` int DEFAULT NULL,
  `has_discount` longtext COLLATE utf8mb3_unicode_ci,
  `price` longtext COLLATE utf8mb3_unicode_ci,
  `discounted_price` longtext COLLATE utf8mb3_unicode_ci,
  `time_price` longtext COLLATE utf8mb3_unicode_ci,
  `unit` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tax_details` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tag_popular` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `sort_order` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_food_menus_restaurant_status_category` (`restaurant_id`,`status`,`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22155 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_log`
--

DROP TABLE IF EXISTS `pos_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `api_url` varchar(255) DEFAULT NULL,
  `oid` bigint DEFAULT NULL,
  `cid` bigint DEFAULT NULL,
  `org_id` varchar(255) DEFAULT NULL,
  `request` text,
  `response` text,
  `code` varchar(100) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1601362 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_modifiers`
--

DROP TABLE IF EXISTS `pos_modifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_modifiers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `modifier` longtext COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Modifier details in JSON format',
  `type` enum('Regular','Catering') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Regular',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='For restaurant modifiers';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_submodifiers`
--

DROP TABLE IF EXISTS `pos_submodifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_submodifiers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_modifier_id` int NOT NULL,
  `option_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `submodifier_id` int NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `printer`
--

DROP TABLE IF EXISTS `printer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `printer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `identifier` varchar(255) DEFAULT NULL,
  `mode` varchar(255) DEFAULT NULL,
  `Encoding` text,
  `alias` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `device` text,
  `fontsize` text,
  `textalign` varchar(100) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=497 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `promocode`
--

DROP TABLE IF EXISTS `promocode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promocode` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(30) DEFAULT NULL,
  `promo_code` varchar(255) NOT NULL,
  `discount_on` varchar(2000) DEFAULT NULL,
  `discount_type` varchar(255) NOT NULL,
  `discount_value` int NOT NULL,
  `maximum_discount` int NOT NULL DEFAULT '0',
  `usage_limit` int NOT NULL DEFAULT '0',
  `maximum_promocode_discount` int NOT NULL DEFAULT '0',
  `order_fulfillment` enum('P','D','B') NOT NULL DEFAULT 'B' COMMENT 'Order fulfillment type: P - Pickup, D - Delivery, B - Both',
  `order_type` enum('R','C','B') NOT NULL DEFAULT 'R' COMMENT 'Order type: R - Regular, C - Catering, B - Both',
  `apply_to` json DEFAULT NULL COMMENT 'Specific items or categories the promocode applies to',
  `organization_id` text,
  `is_happy_hour` json DEFAULT NULL,
  `is_first_time_customer` tinyint(1) NOT NULL DEFAULT '0',
  `usage_type` enum('S','M') NOT NULL DEFAULT 'M',
  `valid_from` varchar(255) DEFAULT NULL,
  `valid_till` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL COMMENT '0 - Inactive, 1 - Active, 2 - Expired',
  `del_status` enum('0','1') NOT NULL DEFAULT '0',
  `created_at` varchar(255) NOT NULL,
  `created_by` varchar(255) NOT NULL,
  `created_by_id` varchar(255) NOT NULL,
  `updated_at` varchar(255) NOT NULL,
  `subtitle` varchar(60) DEFAULT NULL COMMENT 'Optional subtitle for the promocode',
  `max_free_quantity` int DEFAULT '0' COMMENT 'Max free quantity per order for BOGO',
  PRIMARY KEY (`id`),
  KEY `idx_promocode_filter` (`status`,`del_status`,`valid_till`,`order_type`,`usage_type`,`organization_id`(255))
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rate_estimate`
--

DROP TABLE IF EXISTS `rate_estimate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rate_estimate` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `hit_count` bigint DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `cid` bigint DEFAULT NULL,
  `cart_id` varchar(50) DEFAULT NULL,
  `order_id` varchar(100) DEFAULT NULL,
  `quot_id` varchar(255) DEFAULT NULL,
  `request` longtext,
  `response` longtext,
  `message` longtext,
  `api_status` varchar(255) DEFAULT NULL,
  `date_time` varchar(255) DEFAULT NULL,
  `time_format` bigint DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30600 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `person` varchar(255) DEFAULT NULL,
  `rdate` varchar(255) DEFAULT NULL,
  `startTime` varchar(255) DEFAULT NULL,
  `remail` varchar(255) DEFAULT NULL,
  `rname` varchar(255) DEFAULT NULL,
  `rmobile` varchar(255) DEFAULT NULL,
  `res_id` bigint DEFAULT NULL,
  `time_stamp` bigint DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reset_password_log`
--

DROP TABLE IF EXISTS `reset_password_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reset_password_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` text NOT NULL,
  `uid` bigint NOT NULL,
  `date` varchar(255) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_holidays`
--

DROP TABLE IF EXISTS `restaurant_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_holidays` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `closure_date` varchar(255) NOT NULL,
  `store_status` enum('Close','Open') NOT NULL,
  `special_hours` varchar(255) DEFAULT NULL,
  `recurring_yearly` tinyint(1) DEFAULT '0',
  `updated_on` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `a2b_mode` tinyint(1) DEFAULT '0',
  `email_status` int NOT NULL DEFAULT '0',
  `ad_email` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sms_status` int NOT NULL DEFAULT '0',
  `ad_sms` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `emailsms_mode` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '[{"email":"Both","sms":"Both"}]' COMMENT 'Email and sms notification settings for order types',
  `delivery_mode` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'both',
  `pos_mode` tinyint(1) DEFAULT '0',
  `audio` text COLLATE utf8mb3_unicode_ci,
  `catering_order_above_value` bigint DEFAULT '200',
  `caterign_charge_percentage_value` bigint DEFAULT '5',
  `catering_change_title` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'Bulk Order Fees',
  `c_order_above_value` bigint DEFAULT '1000',
  `c_charge_percentage_value` bigint DEFAULT '3',
  `c_change_title` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'Handling Charges',
  `category_order` longtext COLLATE utf8mb3_unicode_ci,
  `c_category_order` longtext COLLATE utf8mb3_unicode_ci,
  `catering_mode` enum('0','1','2') COLLATE utf8mb3_unicode_ci DEFAULT '1' COMMENT '0: Both, 1: Normal, 2: Catering',
  `serving_style` enum('0','1') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  `regular_cutoff` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '{"pickup":"20","delivery":"35"}' COMMENT 'Cutoff time json data for regular pickup and delivery in minutes',
  `catering_cutoff` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT '{"type":"slot","slot":"10:00 PM"}' COMMENT 'Catering cutoff time json',
  `servings_style` enum('0','1') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stripe_description` text COLLATE utf8mb3_unicode_ci,
  `stripe_statement_description` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `city` text COLLATE utf8mb3_unicode_ci,
  `cuisine` longtext COLLATE utf8mb3_unicode_ci,
  `tax` longtext COLLATE utf8mb3_unicode_ci,
  `tax_catering` text COLLATE utf8mb3_unicode_ci,
  `servicefee_reg` text COLLATE utf8mb3_unicode_ci,
  `servicefee_cat` text COLLATE utf8mb3_unicode_ci,
  `commission` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `comm_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'percent',
  `tips_share_status_d` tinyint(1) DEFAULT '0',
  `tips_sharing_percent_d` decimal(5,2) DEFAULT '50.00',
  `tips_share_type_d` enum('percent','amount') COLLATE utf8mb3_unicode_ci DEFAULT 'percent',
  `tips_sharing_status` int NOT NULL DEFAULT '0',
  `tips_sharing_percentage` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tips_sharing_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `catering_settings` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `address` longtext COLLATE utf8mb3_unicode_ci,
  `phone` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `schedule` longtext COLLATE utf8mb3_unicode_ci COMMENT 'a json object with time',
  `time_based` longtext COLLATE utf8mb3_unicode_ci,
  `owner_id` int DEFAULT NULL,
  `sub_owner_id` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png',
  `fav` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'placeholder.png ',
  `storeclosestatus` tinyint(1) DEFAULT '1',
  `storeopentime` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `storeopentime_format` bigint DEFAULT NULL,
  `smtpuser` text COLLATE utf8mb3_unicode_ci,
  `smtppassword` text COLLATE utf8mb3_unicode_ci,
  `partner_id` text COLLATE utf8mb3_unicode_ci,
  `api_url` text COLLATE utf8mb3_unicode_ci,
  `apiorg_id` text COLLATE utf8mb3_unicode_ci,
  `api_key` text COLLATE utf8mb3_unicode_ci,
  `api_km_limit` int DEFAULT '15',
  `api_max_km_fee` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `deli_address` text COLLATE utf8mb3_unicode_ci,
  `zip_code` longtext COLLATE utf8mb3_unicode_ci,
  `deli_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'api',
  `delivery_charge` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `minium_amount` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `catering_min_order_pickup` decimal(10,2) NOT NULL DEFAULT '0.00',
  `gallery` longtext COLLATE utf8mb3_unicode_ci COMMENT 'a json object with 4 images',
  `options` longtext COLLATE utf8mb3_unicode_ci,
  `latitude` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `longitude` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `seo_tags` longtext COLLATE utf8mb3_unicode_ci,
  `seo_description` longtext COLLATE utf8mb3_unicode_ci,
  `status` int DEFAULT '0',
  `coming_soon` tinyint(1) NOT NULL DEFAULT '0',
  `slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `user_ratings_total` text COLLATE utf8mb3_unicode_ci,
  `g_place_id` text COLLATE utf8mb3_unicode_ci,
  `rating_data` longtext COLLATE utf8mb3_unicode_ci,
  `rating` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0',
  `type` int NOT NULL DEFAULT '1',
  `order_time_mode` enum('ASAP','Scheduled','Both') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'Both',
  `cc_fees` text COLLATE utf8mb3_unicode_ci,
  `address_details` text COLLATE utf8mb3_unicode_ci,
  `schedule_cat` json DEFAULT NULL,
  `partyware_status` enum('0','1') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  `timezone` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT 'America/Los_Angeles',
  `white_label_app_name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `categories_print` tinyint(1) NOT NULL DEFAULT '1',
  `events_enabled` enum('disabled','enabled') COLLATE utf8mb3_unicode_ci DEFAULT 'disabled',
  `receipt_settings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '{"price_on_receipt": 0, "price_option": "both"}',
  `partyware_settings` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT '{"partyware_status": 0, "partyware_mode": "Catering"}',
  `pickup_regular_distance_coverage` int DEFAULT '30',
  `pickup_catering_distance_coverage` int DEFAULT '30',
  `print_status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Catering orders receipt print status',
  `catering_delivery_coverage` int DEFAULT '20',
  `print_receipt_modifier` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Print Receipt Modifier Status',
  `regular_pickup_threshold` decimal(10,2) DEFAULT '200.00',
  `regular_pickup_charge_percentage` decimal(5,2) DEFAULT '3.00',
  `regular_pickup_charge_title` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'Bulk Order Fees',
  `catering_pickup_threshold` decimal(10,2) DEFAULT '1500.00',
  `catering_pickup_charge_percentage` decimal(5,2) DEFAULT '3.00',
  `catering_pickup_charge_title` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT 'Handling Charges',
  `maximum_time_to_deliver` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stripe_account_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stripe_payout_verify` tinyint(1) DEFAULT NULL,
  `tips_settings` varchar(400) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '{"regular":{"pickup":{"values":[0,5,10,"custom"],"type":["%","%","%",""]},"delivery":{"values":[10,15,20,"custom"],"type":["%","%","%",""]}},"catering":{"pickup":{"values":[0,5,10,"custom"],"type":["%","%","%",""]},"delivery":{"values":[10,15,20,"custom"],"type":["%","%","%",""]}}}' COMMENT 'Tips settings for regular and catering ',
  `rewards_enable` enum('0','1') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Indicates whether the loyalty program is enabled for this restaurant',
  `rewards_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Fixed monthly fee charged when loyalty is enabled (e.g., $20.00/month)',
  `redeem_enable` enum('0','1') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Indicates whether redemption is enabled for this restaurant',
  `kiosk_enabled` enum('enabled','disabled') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'disabled',
  `auto_accept_config` longtext COLLATE utf8mb3_unicode_ci,
  `google_gtm_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `restaurants_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1190 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_code` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `rating` int DEFAULT NULL,
  `review` longtext COLLATE utf8mb3_unicode_ci,
  `restaurant_id` int DEFAULT NULL,
  `timestamp` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `customer_id` (`customer_id`),
  KEY `order_code` (`order_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reward_points_history`
--

DROP TABLE IF EXISTS `reward_points_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reward_points_history` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incremented primary key',
  `customer_id` int NOT NULL COMMENT 'Customer id from users table',
  `restaurant_id` int NOT NULL COMMENT 'Restaurant id from restaurants table',
  `order_id` varchar(100) DEFAULT NULL COMMENT 'Order code from orders table, if linked to a specific order',
  `points` int NOT NULL DEFAULT '0' COMMENT 'Points earned, redeemed, or expired based on usage_type field',
  `points_balance` int NOT NULL DEFAULT '0' COMMENT 'Total remaining points after this order',
  `discount_value` decimal(10,2) DEFAULT '0.00' COMMENT 'Value of discount received using points (if applicable)',
  `expiration_date` bigint unsigned DEFAULT NULL,
  `usage_type` enum('earned','redeemed','expired','adjusted') NOT NULL COMMENT 'Type of points transaction',
  `source_order_id` varchar(100) DEFAULT NULL COMMENT 'If redeemed, link to original earning order',
  `reward_settings_id` int DEFAULT NULL COMMENT 'Current reward settings id used for redemption, earned, or expiry',
  `note` varchar(255) DEFAULT NULL COMMENT 'Optional note (e.g., manual adjustment)',
  `status` enum('0','1','2') DEFAULT '0' COMMENT 'Status of the redeemed or earned records 0-pending,1-active,2-cancelled',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When order is placed or record inserted',
  PRIMARY KEY (`id`),
  KEY `fk_points_ledger_customer` (`customer_id`),
  KEY `fk_points_ledger_restaurant` (`restaurant_id`),
  CONSTRAINT `fk_points_ledger_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_points_ledger_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=374 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reward_settings`
--

DROP TABLE IF EXISTS `reward_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reward_settings` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `restaurant_id` int NOT NULL COMMENT 'Restaurant id from restaurants table',
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Amount to be spent to earn points (e.g., $1)',
  `points` int NOT NULL DEFAULT '0' COMMENT 'Points to be earned per spend or points needed to redeem',
  `reward_type` enum('earning','redemption') NOT NULL COMMENT 'Earning or Redemption based on the policy type',
  `redemption` json DEFAULT NULL COMMENT 'Type of discount ($ or %) and discount value in JSON format',
  `expiration_type` enum('fixed','no expiry') DEFAULT 'fixed' COMMENT 'Type of expiration',
  `expiry_months` int DEFAULT NULL COMMENT 'No. of months for expiry (e.g., 1 or 2)',
  `user_id` int DEFAULT NULL COMMENT 'User id of merchant or admin',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Current active rule',
  `max_earning_points_per_customer_monthly` int NOT NULL DEFAULT '5000',
  `max_earning_points_per_order` int NOT NULL DEFAULT '2500',
  `redeem_order_value` decimal(10,2) NOT NULL DEFAULT '500.00',
  `max_redeemable_points_per_order` int NOT NULL DEFAULT '500',
  `redeemable_percentage_of_order` decimal(5,2) NOT NULL DEFAULT '50.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
  PRIMARY KEY (`id`),
  KEY `fk_reward_rules_restaurant` (`restaurant_id`),
  CONSTRAINT `fk_reward_rules_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=193 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reward_settings_audit_log`
--

DROP TABLE IF EXISTS `reward_settings_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reward_settings_audit_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Auto-incremented primary key',
  `user_id` int NOT NULL COMMENT 'Admin or merchant id from users table to know which user updated the settings',
  `restaurant_id` int NOT NULL COMMENT 'Restaurant id from restaurants table',
  `field_changed` varchar(100) NOT NULL COMMENT 'Field name that is changed',
  `old_value` varchar(100) DEFAULT NULL COMMENT 'Previous value',
  `new_value` varchar(100) DEFAULT NULL COMMENT 'New value',
  `notes` varchar(100) DEFAULT NULL COMMENT 'Any extra information about the change',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the record insertion',
  PRIMARY KEY (`id`),
  KEY `fk_settings_audit_log_user` (`user_id`),
  KEY `fk_settings_audit_log_restaurant` (`restaurant_id`),
  CONSTRAINT `fk_settings_audit_log_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`),
  CONSTRAINT `fk_settings_audit_log_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role_management`
--

DROP TABLE IF EXISTS `role_management`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_management` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `level` int NOT NULL DEFAULT '0',
  `permission` varchar(100) DEFAULT NULL,
  `description` longtext,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) DEFAULT NULL,
  `search_key` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_log`
--

DROP TABLE IF EXISTS `sms_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_number` bigint NOT NULL,
  `to_number` bigint NOT NULL,
  `country_code` varchar(20) NOT NULL,
  `message` longtext NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_logs`
--

DROP TABLE IF EXISTS `sms_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `page` varchar(255) NOT NULL,
  `functions` varchar(255) NOT NULL,
  `mobile` varchar(255) NOT NULL,
  `country_code` varchar(10) NOT NULL,
  `subject` longtext NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `time_format` bigint NOT NULL,
  `request` longtext NOT NULL,
  `response` longtext NOT NULL,
  `api_url` text NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7468 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smtp_settings`
--

DROP TABLE IF EXISTS `smtp_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `smtp_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `store_holidays`
--

DROP TABLE IF EXISTS `store_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_holidays` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `closure_date` varchar(100) NOT NULL,
  `store_status` varchar(50) NOT NULL,
  `special_hours` varchar(100) DEFAULT NULL,
  `recurring_yearly` tinyint(1) DEFAULT '0',
  `updated_on` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `store_print`
--

DROP TABLE IF EXISTS `store_print`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_print` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sid` bigint NOT NULL,
  `code` varchar(255) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5319 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_category_map`
--

DROP TABLE IF EXISTS `stream_category_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_category_map` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `category_id` int NOT NULL,
  `stream_category_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `category_map` (`restaurant_id`,`stream_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=572 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_menu_ingestion`
--

DROP TABLE IF EXISTS `stream_menu_ingestion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_menu_ingestion` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `location_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `request_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `restaurant_id` int NOT NULL,
  `status` enum('initiated','inprogress','neglected','completed','failed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `error` json DEFAULT NULL,
  `menu_ingestion_s3_data` json DEFAULT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_location_id` (`location_id`),
  KEY `idx_status` (`status`),
  KEY `idx_request_id` (`request_id`)
) ENGINE=InnoDB AUTO_INCREMENT=549 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_menu_map`
--

DROP TABLE IF EXISTS `stream_menu_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_menu_map` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `menu_id` int NOT NULL,
  `stream_category_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `stream_menu_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `stream_family_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `status` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=882 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_menu_update`
--

DROP TABLE IF EXISTS `stream_menu_update`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_menu_update` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `request_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `restaurant_id` int NOT NULL,
  `status` enum('initiated','inprogress','completed','failed','not_found','bad_request') COLLATE utf8mb4_unicode_ci DEFAULT 'initiated',
  `error` json DEFAULT NULL,
  `menu_update_object` json NOT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_location_id` (`location_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=215 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_modifier_map`
--

DROP TABLE IF EXISTS `stream_modifier_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_modifier_map` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `modifier_id` int NOT NULL,
  `stream_modifier_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `menu_id` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_id` (`restaurant_id`),
  KEY `idx_stream_modifier_id` (`stream_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=392 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_order_accept_event_status`
--

DROP TABLE IF EXISTS `stream_order_accept_event_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_order_accept_event_status` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `location_id` varchar(100) NOT NULL,
  `pos_order_id` varchar(100) NOT NULL,
  `status` varchar(50) NOT NULL,
  `error` json DEFAULT NULL,
  `marketplace_payload` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=308 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_order_cancel_event_status`
--

DROP TABLE IF EXISTS `stream_order_cancel_event_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_order_cancel_event_status` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `location_id` varchar(100) NOT NULL,
  `pos_order_id` varchar(100) NOT NULL,
  `status` varchar(50) NOT NULL,
  `error` json DEFAULT NULL,
  `marketplace_payload` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_order_failed_event_status`
--

DROP TABLE IF EXISTS `stream_order_failed_event_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_order_failed_event_status` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `location_id` varchar(100) NOT NULL,
  `pos_order_id` varchar(100) NOT NULL,
  `status` varchar(50) NOT NULL,
  `error` json DEFAULT NULL,
  `marketplace_payload` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stream_ready_for_pick_up_status`
--

DROP TABLE IF EXISTS `stream_ready_for_pick_up_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_ready_for_pick_up_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `location_id` varchar(100) NOT NULL,
  `pos_order_id` varchar(45) NOT NULL,
  `status` varchar(45) DEFAULT NULL,
  `error_status` varchar(45) DEFAULT NULL,
  `marketplace_payload` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_transfer_history`
--

DROP TABLE IF EXISTS `stripe_transfer_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_transfer_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `transfer_id` varchar(100) DEFAULT NULL,
  `batch_id` varchar(100) DEFAULT NULL,
  `status` enum('success','failed','dry_run') NOT NULL,
  `response_json` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `batch_id` (`batch_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `submodifiers`
--

DROP TABLE IF EXISTS `submodifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submodifiers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_modifier_id` int NOT NULL,
  `option_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `submodifier_id` int NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=440 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `support`
--

DROP TABLE IF EXISTS `support`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support` (
  `id` int NOT NULL,
  `customer_id` int NOT NULL,
  `title` text COLLATE utf8mb4_general_ci NOT NULL,
  `order_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `mobile` int NOT NULL,
  `description` text COLLATE utf8mb4_general_ci NOT NULL,
  `sentdate` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `image` varchar(100) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testri`
--

DROP TABLE IF EXISTS `testri`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testri` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reasons` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `textmoni`
--

DROP TABLE IF EXISTS `textmoni`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `textmoni` (
  `id` int NOT NULL AUTO_INCREMENT,
  `text` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL,
  `status` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trans_email`
--

DROP TABLE IF EXISTS `trans_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trans_email` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mode` varchar(255) DEFAULT 'admin',
  `rid` int NOT NULL,
  `from_email` text,
  `to_emails` longtext,
  `subject` text,
  `templateid` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `schdates` varchar(255) DEFAULT NULL,
  `schtime` varchar(255) DEFAULT NULL,
  `content` longtext,
  `craetedata` varchar(255) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `mail_status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=180 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_data`
--

DROP TABLE IF EXISTS `transaction_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_data` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(225) COLLATE utf8mb4_general_ci NOT NULL,
  `transaction_status` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `order_data` json NOT NULL,
  `order_id` tinyint(1) NOT NULL,
  `payment_method` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `payment_intent` json NOT NULL,
  `payment_status` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `payment_error` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_account_source_log`
--

DROP TABLE IF EXISTS `user_account_source_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_account_source_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `action_type` enum('created','activated','deleted') NOT NULL,
  `feedback_to_delete` varchar(255) DEFAULT NULL,
  `reason_id_to_delete` varchar(255) DEFAULT NULL,
  `source` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6284 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_activity`
--

DROP TABLE IF EXISTS `user_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activity` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `username` text,
  `data_post` text,
  `data_get` text,
  `delivery_api` text,
  `type` enum('admin','owner','customer','common','merchant app','user app') NOT NULL DEFAULT 'common',
  `action` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `ip` varchar(150) DEFAULT NULL,
  `time` varchar(20) NOT NULL,
  `time_format` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ua_users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=235111 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_audit`
--

DROP TABLE IF EXISTS `user_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_audit` (
  `audit_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `action_type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `action_details` text COLLATE utf8mb4_general_ci,
  `timestamp` int NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_audit_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=798 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_audit_trails`
--

DROP TABLE IF EXISTS `user_audit_trails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_audit_trails` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` text,
  `event` enum('insert','update','delete') DEFAULT NULL,
  `table_name` text,
  `old_values` text,
  `new_values` text,
  `url` text,
  `name` text,
  `ip_address` text,
  `user_agent` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33997 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ip_data` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `access` text COLLATE utf8mb3_unicode_ci,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `phone_isd_code` varchar(5) COLLATE utf8mb3_unicode_ci DEFAULT '+1',
  `password` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `forgot_password` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `forgot_status` tinyint(1) NOT NULL DEFAULT '0',
  `forgot_date` int DEFAULT NULL,
  `forgot_date_expire` text COLLATE utf8mb3_unicode_ci,
  `role_id` int DEFAULT NULL,
  `role_admin_id` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` int DEFAULT NULL,
  `updated_at` int DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'placeholder.png',
  `lname` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `vehicle` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sound` tinyint(1) DEFAULT '1',
  `receipt_count` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  `r_slug` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `total_order` int DEFAULT NULL,
  `total_cancel` int DEFAULT NULL,
  `sendgrid_id` bigint DEFAULT NULL,
  `sendgrid_request` longtext COLLATE utf8mb3_unicode_ci,
  `sendgrid_response` longtext COLLATE utf8mb3_unicode_ci,
  `sendgrid_api_key` longtext COLLATE utf8mb3_unicode_ci,
  `sendgrid_response_n1` longtext COLLATE utf8mb3_unicode_ci,
  `sendgrid_api_key_id` longtext COLLATE utf8mb3_unicode_ci,
  `main_org_name` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `is_first_login` tinyint(1) NOT NULL,
  `last_login_restaurant` int NOT NULL,
  `owner_token` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `owner_token_expiry` int NOT NULL,
  `login_mode` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stepup_otp` varchar(6) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `otp_expiry_time` int DEFAULT NULL,
  `otp_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verification_type` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `otp_expired_message` tinyint(1) DEFAULT '0',
  `otp_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `consumer_auth_token` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `social_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `social_login_type` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `social_login_token` varchar(1000) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `account_deletion_reason` json DEFAULT NULL,
  `identity_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `is_app_login` tinyint(1) NOT NULL DEFAULT '0',
  `is_web_login` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7090 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `webex_log`
--

DROP TABLE IF EXISTS `webex_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webex_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `req` longtext,
  `response` longtext,
  `time` varchar(255) DEFAULT NULL,
  `time_format` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43076 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `webhook`
--

DROP TABLE IF EXISTS `webhook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `response` text,
  `order_id` text,
  `type` text,
  `items` text,
  `note` text,
  `payment_status` text,
  `response_status` text,
  `order_amount` text,
  `service_charge` text,
  `orderLevelDiscountAmount` text,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cron_status` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18415 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `website_settings`
--

DROP TABLE IF EXISTS `website_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `website_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-26 13:22:18
