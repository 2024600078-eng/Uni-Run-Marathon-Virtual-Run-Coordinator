-- =====================================================================
-- Uni-Run: Marathon & Virtual Run Coordinator
-- Database setup script for MySQL / MariaDB
--
-- Import this file into phpMyAdmin, or run it from the MySQL client:
--     mysql -u root < unirun_db.sql
--
-- Running it again drops the existing data and recreates everything
-- from scratch.
-- =====================================================================

DROP DATABASE IF EXISTS `unirun_db`;
CREATE DATABASE `unirun_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `unirun_db`;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- ---------------------------------------------------------------------
-- users
--
-- `password` stores a SHA-256 hash produced by util.PasswordUtil, never
-- the password itself. A hash is always 64 hexadecimal characters.
-- ---------------------------------------------------------------------
CREATE TABLE `users` (
  `user_id`    INT(11)      NOT NULL AUTO_INCREMENT,
  `full_name`  VARCHAR(100) NOT NULL,
  `email`      VARCHAR(100) NOT NULL,
  `password`   VARCHAR(100) NOT NULL,
  `role`       VARCHAR(20)  NOT NULL DEFAULT 'participant',
  `created_at` TIMESTAMP    NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- events
-- ---------------------------------------------------------------------
CREATE TABLE `events` (
  `event_id`    INT(11)      NOT NULL AUTO_INCREMENT,
  `event_name`  VARCHAR(255) NOT NULL,
  `description` TEXT         DEFAULT NULL,
  `event_date`  DATE         DEFAULT NULL,
  `distance`    DOUBLE       NOT NULL,
  `fee`         DECIMAL(10,2) DEFAULT 0.00,
  PRIMARY KEY (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- registrations
--
-- The unique key stops a participant from joining the same event twice.
-- Deleting a user or an event removes their registrations with it.
-- ---------------------------------------------------------------------
CREATE TABLE `registrations` (
  `registration_id`   INT(11)   NOT NULL AUTO_INCREMENT,
  `user_id`           INT(11)   NOT NULL,
  `event_id`          INT(11)   NOT NULL,
  `registration_date` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  `status`            VARCHAR(50) DEFAULT 'Pending',
  PRIMARY KEY (`registration_id`),
  UNIQUE KEY `uq_registration_user_event` (`user_id`, `event_id`),
  KEY `fk_registrations_event` (`event_id`),
  CONSTRAINT `fk_registrations_user`
      FOREIGN KEY (`user_id`)  REFERENCES `users` (`user_id`)   ON DELETE CASCADE,
  CONSTRAINT `fk_registrations_event`
      FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- results
--
-- One result per registration, so the unique key sits on registration_id.
-- ---------------------------------------------------------------------
CREATE TABLE `results` (
  `result_id`         INT(11)   NOT NULL AUTO_INCREMENT,
  `registration_id`   INT(11)   NOT NULL,
  `distance_achieved` DOUBLE    NOT NULL,
  `duration`          VARCHAR(100) DEFAULT NULL,
  `proof_image`       VARCHAR(255) DEFAULT NULL,
  `submission_date`   TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  `approval_status`   VARCHAR(50)  DEFAULT 'Pending',
  PRIMARY KEY (`result_id`),
  UNIQUE KEY `uq_results_registration` (`registration_id`),
  CONSTRAINT `fk_results_registration`
      FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`registration_id`)
      ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================================
-- Sample data
--
-- The passwords below are SHA-256 hashes. The plain text values are
-- listed so the system can be demonstrated:
--
--     admin@unirun.com   admin123    (administrator)
--     ali@email.com      ali123
--     aisya@gmail.com    aisya123
--     nina@gmail.com     nina123
--     ahmad@gmail.com    ahmad123
-- =====================================================================

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Admin User',                  'admin@unirun.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin',       '2026-07-07 11:06:48'),
(2, 'Ali Participant',             'ali@email.com',    'd5083e34522626dd10e151c78c1ba502a3d67427b752c3fd43bd3b944072d1e7', 'participant', '2026-07-07 11:06:48'),
(5, 'Aisya Sofea Binti Abdul Halim','aisya@gmail.com', '3d8f1cb105a62349d9fece8c519eec531ba18a7e380f2589dca11838947b11b0', 'participant', '2026-07-14 12:20:50'),
(6, 'Nina Kamarul',                'nina@gmail.com',   '3c408f46ae562d86b5f96053615809838513bbf425c86d21285ae027785f4acd', 'participant', '2026-07-14 13:38:13'),
(7, 'Ahmad Bin Abdul Rahman',      'ahmad@gmail.com',  '306098fa01257f8e4809cbdfca258d8c22c7fb12937cc2616ef06aa20fd8008e', 'participant', '2026-07-14 13:46:01');

INSERT INTO `events` (`event_id`, `event_name`, `description`, `event_date`, `distance`, `fee`) VALUES
(1, 'KL Tower International Virtual Run', 'A virtual run held in conjunction with Federal Territory Day. Build your stamina at your own pace.', '2026-08-15', 5,  30.00),
(2, 'Penang Bridge Virtual Marathon',     'Experience the famous bridge crossing virtually, from wherever you are.',                            '2026-09-20', 21, 50.00),
(3, 'Merdeka Virtual Run 2026',           'Celebrate Independence Day with a healthy run together with your family.',                           '2026-08-31', 10,  0.00);

INSERT INTO `registrations` (`registration_id`, `user_id`, `event_id`, `registration_date`, `status`) VALUES
(1, 2, 1, '2026-07-09 09:17:51', 'Registered'),
(2, 2, 2, '2026-07-13 12:59:36', 'Registered'),
(3, 5, 2, '2026-07-14 13:36:52', 'Registered'),
(4, 5, 3, '2026-07-14 13:36:58', 'Registered'),
(5, 6, 1, '2026-07-15 10:02:11', 'Registered');

-- One result is left Pending so the approval screen has something to act on.
INSERT INTO `results` (`result_id`, `registration_id`, `distance_achieved`, `duration`, `proof_image`, `submission_date`, `approval_status`) VALUES
(1, 1, 5.20,  '00:31:44', NULL, '2026-07-16 08:12:00', 'Approved'),
(2, 3, 21.40, '02:15:09', NULL, '2026-07-18 09:40:00', 'Pending'),
(3, 5, 5.05,  '00:29:58', NULL, '2026-07-19 07:55:00', 'Pending');

ALTER TABLE `users`         AUTO_INCREMENT = 8;
ALTER TABLE `events`        AUTO_INCREMENT = 4;
ALTER TABLE `registrations` AUTO_INCREMENT = 6;
ALTER TABLE `results`       AUTO_INCREMENT = 4;
