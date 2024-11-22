-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-11-2024 a las 17:53:22
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Base de datos: `bank_app`
-- CREATE DATABASE IF NOT EXISTS `bank_app`;
USE `sql8746743`;

-- Estructura de tabla para la tabla `accounts`
CREATE TABLE `accounts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL,
  `account_number` VARCHAR(50) NOT NULL,
  `balance` DECIMAL(10,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_account_number` (`account_number`(20)),
  KEY `username_idx` (`username`(20))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Estructura de tabla para la tabla `transactions`
CREATE TABLE `transactions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `account_number` VARCHAR(50) NOT NULL,
  `type` ENUM('deposit', 'withdrawal') NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `balance_before` DECIMAL(10,2) NOT NULL,
  `balance_after` DECIMAL(10,2) NOT NULL,
  `transaction_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('pending', 'completed', 'failed') DEFAULT 'completed',
  `description` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_number_idx` (`account_number`(20)),
  KEY `user_id_idx` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Estructura de tabla para la tabla `users`
CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `names` VARCHAR(100) NOT NULL,
  `lastnames` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Relaciones entre tablas
ALTER TABLE `accounts`
  ADD CONSTRAINT `fk_accounts_users` FOREIGN KEY (`username`) REFERENCES `users` (`username`);

ALTER TABLE `transactions`
  ADD CONSTRAINT `fk_transactions_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_transactions_accounts` FOREIGN KEY (`account_number`) REFERENCES `accounts` (`account_number`);

-- Volcado de datos para la tabla `users`
INSERT INTO `users` (`id`, `username`, `names`, `lastnames`, `password`, `email`, `created_at`) VALUES
(5, 'cheemita', 'José', 'González', '$2b$10$PdQUkA2TOL2LiK6ybbhSSOANBHAGO0LwgQXHeENY9XGf439EKyukq', 'josemarsp.mzt@gmail.com', '2024-11-20 22:15:34'),
(6, 'RSP', 'Rsp', 'rssp', '$2b$10$ZUhr9hykQw6JV2c7WJK1SORwTHWurBaAHynJkh18gvNio/Sa9Se36', 'rsp@rsp.com', '2024-11-21 20:42:25');

-- Volcado de datos para la tabla `accounts`
INSERT INTO `accounts` (`id`, `username`, `account_number`, `balance`) VALUES
(5, 'cheemita', '202411B01222', 0.00),
(6, 'RSP', '202411142392', 0.00);

-- Volcado de datos para la tabla `transactions`
INSERT INTO `transactions` (`id`, `user_id`, `account_number`, `type`, `amount`, `balance_before`, `balance_after`, `transaction_date`, `status`, `description`) VALUES
(36, 5, '202411B01222', 'withdrawal', 1000.00, 10000.00, 9000.00, '2024-11-21 21:28:36', 'completed', 'Aaaa'),
(37, 5, '202411B01222', 'withdrawal', 2000.00, 10000.00, 8000.00, '2024-11-21 21:47:19', 'completed', 'aaa'),
(38, 5, '202411B01222', 'deposit', 255555.00, 8000.00, 263555.00, '2024-11-21 21:47:41', 'completed', 'aaaa');

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
