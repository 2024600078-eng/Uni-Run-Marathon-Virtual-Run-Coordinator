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
--     farah@gmail.com    farah123
--     daniel@gmail.com   daniel123
--     siti@gmail.com     siti123
--     rajesh@gmail.com   rajesh123
-- =====================================================================

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password`, `role`, `created_at`) VALUES
(1,  'Admin User',                    'admin@unirun.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin',       '2026-07-07 11:06:48'),
(2,  'Ali Participant',               'ali@email.com',    'd5083e34522626dd10e151c78c1ba502a3d67427b752c3fd43bd3b944072d1e7', 'participant', '2026-07-07 11:06:48'),
(5,  'Aisya Sofea Binti Abdul Halim', 'aisya@gmail.com',  '3d8f1cb105a62349d9fece8c519eec531ba18a7e380f2589dca11838947b11b0', 'participant', '2026-07-14 12:20:50'),
(6,  'Nina Kamarul',                  'nina@gmail.com',   '3c408f46ae562d86b5f96053615809838513bbf425c86d21285ae027785f4acd', 'participant', '2026-07-14 13:38:13'),
(7,  'Ahmad Bin Abdul Rahman',        'ahmad@gmail.com',  '306098fa01257f8e4809cbdfca258d8c22c7fb12937cc2616ef06aa20fd8008e', 'participant', '2026-07-14 13:46:01'),
(9,  'Farah Nadia Binti Zulkifli',    'farah@gmail.com',  '51cf0790b992c94647ea03923ecf8de272b1f8836fc1cfebb788d02d534f9ed7', 'participant', '2026-07-18 09:12:30'),
(10, 'Daniel Tan Wei Ming',           'daniel@gmail.com', '31da895dff55475c8f24cc504ea9b2ceeceb4daf8446b12a2c113930d82ebf6c', 'participant', '2026-07-18 10:04:11'),
(11, 'Siti Aminah Binti Yusof',       'siti@gmail.com',   '71c6e47969179c1e831fcf41f4979a3557290a65d7925e6760cfd316389f0729', 'participant', '2026-07-19 14:26:52'),
(12, 'Rajesh Kumar A/L Suresh',       'rajesh@gmail.com', '216bfaef293aa2513c011c2643b253f28a0b0aac20a769cb2a15518fb1cf3e7f', 'participant', '2026-07-20 08:47:19');

INSERT INTO `events` (`event_id`, `event_name`, `description`, `event_date`, `distance`, `fee`) VALUES
(4, 'Campus Sunrise 5K',                 'An early morning run around the university campus. Ideal for beginners and anyone starting their running journey.',       '2026-08-08', 5,    15.00),
(1, 'KL Tower International Virtual Run','A virtual run held in conjunction with Federal Territory Day. Build your stamina at your own pace.',                     '2026-08-15', 5,    30.00),
(3, 'Merdeka Virtual Run 2026',          'Celebrate Independence Day with a healthy run together with your family. Free entry for all students.',                   '2026-08-31', 10,    0.00),
(5, 'UiTM Charity Run',                  'A charity run where every entry fee goes to the student welfare fund. Run for a good cause.',                            '2026-09-05', 7,    20.00),
(2, 'Penang Bridge Virtual Marathon',    'Experience the famous bridge crossing virtually, from wherever you are. A half marathon distance.',                      '2026-09-20', 21,   50.00),
(6, 'Titiwangsa Night Run',              'An evening run around the lake gardens under the city lights. Cooler weather and a scenic route.',                       '2026-09-27', 10,   35.00),
(7, 'Langkawi Island Virtual Challenge', 'Cover the distance anywhere and earn the island finisher medal. A step up for intermediate runners.',                    '2026-10-11', 15,   40.00),
(8, 'Uni-Run Grand Marathon 2026',       'The full marathon distance and the flagship event of the season. For experienced runners only.',                         '2026-11-01', 42.2, 80.00);

INSERT INTO `registrations` (`registration_id`, `user_id`, `event_id`, `registration_date`, `status`) VALUES
-- KL Tower International Virtual Run
(1,  2,  1, '2026-07-09 09:17:51', 'Registered'),
(5,  6,  1, '2026-07-15 10:02:11', 'Registered'),
-- Penang Bridge Virtual Marathon
(2,  2,  2, '2026-07-13 12:59:36', 'Registered'),
(3,  5,  2, '2026-07-14 13:36:52', 'Registered'),
-- Merdeka Virtual Run 2026
(4,  5,  3, '2026-07-14 13:36:58', 'Registered'),
(23, 11, 3, '2026-07-21 16:12:04', 'Registered'),
(24, 9,  3, '2026-07-21 17:45:33', 'Registered'),
-- Campus Sunrise 5K
(6,  10, 4, '2026-07-18 10:15:02', 'Registered'),
(7,  9,  4, '2026-07-18 11:30:47', 'Registered'),
(8,  6,  4, '2026-07-18 14:08:19', 'Registered'),
(9,  12, 4, '2026-07-20 09:03:55', 'Registered'),
(10, 11, 4, '2026-07-20 15:41:26', 'Registered'),
(11, 7,  4, '2026-07-21 08:22:37', 'Registered'),
-- UiTM Charity Run
(12, 10, 5, '2026-07-19 09:48:13', 'Registered'),
(13, 9,  5, '2026-07-19 13:27:50', 'Registered'),
(14, 2,  5, '2026-07-20 11:14:08', 'Registered'),
(15, 11, 5, '2026-07-22 10:36:44', 'Registered'),
-- Titiwangsa Night Run
(16, 12, 6, '2026-07-20 19:52:31', 'Registered'),
(17, 6,  6, '2026-07-21 20:18:09', 'Registered'),
(18, 7,  6, '2026-07-22 21:05:57', 'Registered'),
-- Langkawi Island Virtual Challenge
(19, 5,  7, '2026-07-23 09:41:12', 'Registered'),
(20, 10, 7, '2026-07-23 14:55:38', 'Registered'),
-- Uni-Run Grand Marathon 2026
(21, 2,  8, '2026-07-24 10:07:26', 'Registered'),
(22, 12, 8, '2026-07-24 16:33:49', 'Registered');

-- Results are a deliberate mix. Most are approved so the leaderboard has
-- something to rank, two are left Pending so the approval screen has work
-- waiting, and one is Rejected so the resubmission flow can be shown.
INSERT INTO `results` (`result_id`, `registration_id`, `distance_achieved`, `duration`, `proof_image`, `submission_date`, `approval_status`) VALUES
-- KL Tower International Virtual Run
(1,  5,  5.05,  '00:29:58', NULL, '2026-07-19 07:55:00', 'Approved'),
(2,  1,  5.20,  '00:32:50', NULL, '2026-07-19 08:12:00', 'Approved'),
-- Penang Bridge Virtual Marathon
(3,  3,  21.40, '02:15:09', NULL, '2026-07-18 09:40:00', 'Approved'),
-- Campus Sunrise 5K
(4,  6,  5.10,  '00:21:47', NULL, '2026-08-08 08:30:00', 'Approved'),
(5,  7,  5.05,  '00:23:12', NULL, '2026-08-08 08:41:00', 'Approved'),
(6,  8,  5.00,  '00:24:58', NULL, '2026-08-08 09:02:00', 'Approved'),
(7,  9,  5.15,  '00:26:40', NULL, '2026-08-08 09:15:00', 'Approved'),
(8,  10, 5.02,  '00:28:15', NULL, '2026-08-08 09:33:00', 'Approved'),
(9,  11, 5.20,  '00:30:02', NULL, '2026-08-08 10:07:00', 'Approved'),
-- UiTM Charity Run
(10, 12, 7.10,  '00:33:05', NULL, '2026-09-05 08:20:00', 'Approved'),
(11, 13, 7.00,  '00:34:20', NULL, '2026-09-05 08:35:00', 'Approved'),
(12, 14, 7.05,  '00:37:55', NULL, '2026-09-05 09:01:00', 'Approved'),
(13, 15, 7.00,  '00:39:41', NULL, '2026-09-05 09:24:00', 'Pending'),
-- Titiwangsa Night Run
(14, 16, 10.20, '00:52:30', NULL, '2026-09-27 21:40:00', 'Approved'),
(15, 17, 10.05, '00:55:12', NULL, '2026-09-27 21:58:00', 'Approved'),
(16, 18, 10.00, '01:01:47', NULL, '2026-09-27 22:19:00', 'Pending'),
-- Merdeka Virtual Run 2026, rejected so it can be corrected and resubmitted
(17, 23, 10.10, '00:58:20', NULL, '2026-08-31 09:12:00', 'Rejected');

ALTER TABLE `users`         AUTO_INCREMENT = 13;
ALTER TABLE `events`        AUTO_INCREMENT = 9;
ALTER TABLE `registrations` AUTO_INCREMENT = 25;
ALTER TABLE `results`       AUTO_INCREMENT = 18;
