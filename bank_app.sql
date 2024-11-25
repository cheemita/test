-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-11-2024 a las 17:37:00
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bankapp`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `balance` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `accounts`
--

INSERT INTO `accounts` (`id`, `username`, `account_number`, `balance`) VALUES
(5, 'cheemita', '202411B01222', 1004222.00),
(6, 'RSP', '202411142392', 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `type` enum('deposit','withdrawal') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `balance_before` decimal(10,2) NOT NULL,
  `balance_after` decimal(10,2) NOT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('pending','completed','failed') DEFAULT 'completed',
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `account_number`, `type`, `amount`, `balance_before`, `balance_after`, `transaction_date`, `status`, `description`) VALUES
(36, 5, '202411B01222', 'withdrawal', 1000.00, 10000.00, 9000.00, '2024-11-21 21:28:36', 'completed', 'Aaaa'),
(37, 5, '202411B01222', 'withdrawal', 2000.00, 10000.00, 8000.00, '2024-11-21 21:47:19', 'completed', 'aaa'),
(38, 5, '202411B01222', 'deposit', 255555.00, 8000.00, 263555.00, '2024-11-21 21:47:41', 'completed', 'aaaa'),
(39, 5, '202411B01222', 'withdrawal', 222.00, 263555.00, 263333.00, '2024-11-21 21:49:48', 'completed', 'aaa'),
(40, 5, '202411B01222', 'withdrawal', 222.00, 263333.00, 263111.00, '2024-11-21 21:51:03', 'completed', 'aaa'),
(41, 5, '202411B01222', 'deposit', 2222.00, 263111.00, 265333.00, '2024-11-21 21:51:16', 'completed', 'aaa'),
(42, 5, '202411B01222', 'deposit', 2000.00, 265333.00, 267333.00, '2024-11-21 21:52:17', 'completed', 'aaa'),
(43, 5, '202411B01222', 'withdrawal', 250000.00, 267333.00, 17333.00, '2024-11-21 21:52:29', 'completed', 'aaa'),
(44, 5, '202411B01222', 'withdrawal', 17233.00, 17333.00, 100.00, '2024-11-21 21:52:49', 'completed', 'aaa'),
(45, 5, '202411B01222', 'deposit', 100000.00, 100.00, 100100.00, '2024-11-21 22:54:23', 'completed', 'aaa'),
(46, 5, '202411B01222', 'withdrawal', 10000.00, 100100.00, 90100.00, '2024-11-21 22:54:36', 'completed', 'aa'),
(47, 5, '202411B01222', 'withdrawal', 90100.00, 90100.00, 0.00, '2024-11-21 22:54:48', 'completed', ''),
(48, 5, '202411B01222', 'deposit', 100000.00, 0.00, 100000.00, '2024-11-22 20:39:48', 'completed', 'aaa'),
(49, 5, '202411B01222', 'withdrawal', 256.50, 100000.00, 99743.50, '2024-11-22 20:39:59', 'completed', 'aaa'),
(50, 5, '202411B01222', 'withdrawal', 123333.00, 99743.50, -23589.50, '2024-11-22 20:46:40', 'completed', ''),
(51, 5, '202411B01222', 'deposit', 99999999.99, -23589.50, 99976410.50, '2024-11-22 20:51:00', 'completed', 'a'),
(52, 5, '202411B01222', 'withdrawal', 123456.00, 99976410.50, 99852954.50, '2024-11-22 20:51:12', 'completed', ''),
(53, 5, '202411B01222', 'withdrawal', 1222.00, 99852954.50, 99851732.50, '2024-11-22 20:57:22', 'completed', 'aa'),
(54, 5, '202411B01222', 'withdrawal', 1223.00, 99851732.50, 99850509.50, '2024-11-22 20:59:01', 'completed', 'aa'),
(55, 5, '202411B01222', 'withdrawal', 99850509.50, 99850509.50, 0.00, '2024-11-22 20:59:10', 'completed', 'aa'),
(56, 5, '202411B01222', 'deposit', 1222.00, 0.00, 1222.00, '2024-11-22 21:02:23', 'completed', 'aaa'),
(57, 5, '202411B01222', 'deposit', 10000.00, 1222.00, 11222.00, '2024-11-22 21:02:35', 'completed', 'a'),
(58, 5, '202411B01222', 'withdrawal', 10000.00, 11222.00, 1222.00, '2024-11-22 21:02:41', 'completed', 'a'),
(59, 5, '202411B01222', 'deposit', 1000.00, 1222.00, 2222.00, '2024-11-22 21:03:36', 'completed', 'aa'),
(60, 5, '202411B01222', 'deposit', 1000000.00, 2222.00, 1002222.00, '2024-11-22 21:03:47', 'completed', ''),
(61, 5, '202411B01222', 'deposit', 2000.00, 1002222.00, 1004222.00, '2024-11-22 21:05:00', 'completed', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `names` varchar(100) NOT NULL,
  `lastnames` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `username`, `names`, `lastnames`, `password`, `email`, `created_at`) VALUES
(5, 'cheemita', 'José ', 'González', '$2b$10$PdQUkA2TOL2LiK6ybbhSSOANBHAGO0LwgQXHeENY9XGf439EKyukq', 'josemarsp.mzt@gmail.com', '2024-11-20 22:15:34'),
(6, 'RSP', 'Rsp', 'rssp', '$2b$10$ZUhr9hykQw6JV2c7WJK1SORwTHWurBaAHynJkh18gvNio/Sa9Se36', 'rsp@rsp.com', '2024-11-21 20:42:25');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_number` (`account_number`),
  ADD UNIQUE KEY `account_number_2` (`account_number`),
  ADD KEY `username` (`username`);

--
-- Indices de la tabla `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account_number` (`account_number`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `accounts_ibfk_1` FOREIGN KEY (`username`) REFERENCES `users` (`username`);

--
-- Filtros para la tabla `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`account_number`) REFERENCES `accounts` (`account_number`),
  ADD CONSTRAINT `transactions_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `accounts` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
