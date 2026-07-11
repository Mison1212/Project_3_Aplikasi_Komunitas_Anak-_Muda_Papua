-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 11, 2026 at 05:55 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `papua_youth_career`
--

-- --------------------------------------------------------

--
-- Table structure for table `applications`
--

CREATE TABLE `applications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `status` enum('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `applications`
--

INSERT INTO `applications` (`id`, `user_id`, `job_id`, `status`, `created_at`) VALUES
(7, 13, 6, 'accepted', '2026-07-02 20:14:27'),
(8, 13, 5, 'rejected', '2026-07-02 20:14:59'),
(9, 13, 4, 'accepted', '2026-07-02 20:15:05'),
(12, 13, 3, 'accepted', '2026-07-02 20:56:36'),
(15, 19, 1, 'accepted', '2026-07-04 05:16:34'),
(16, 19, 2, 'rejected', '2026-07-04 05:16:43'),
(19, 13, 1, 'accepted', '2026-07-04 06:22:38');

-- --------------------------------------------------------

--
-- Table structure for table `career_specs`
--

CREATE TABLE `career_specs` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `career_specs`
--

INSERT INTO `career_specs` (`id`, `name`, `description`) VALUES
(1, 'Software Development', 'Pengembangan aplikasi web, mobile, dan backend.'),
(2, 'Digital Marketing', 'Pemasaran digital, media sosial, dan konten.'),
(3, 'Administrasi', 'Pengelolaan data, arsip, dan administrasi kantor.'),
(4, 'Desain Grafis', 'Desain visual untuk kebutuhan publikasi dan promosi.'),
(5, 'Data Entry', 'Input, validasi, dan pengolahan data dasar.'),
(6, 'Manajemen', 'akuntan');

-- --------------------------------------------------------

--
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`id`, `name`) VALUES
(2, 'Biak Numfor'),
(1, 'Jayapura'),
(8, 'Jayawijaya'),
(14, 'Karubaga'),
(18, 'kota serui mantap sekali'),
(9, 'Lanny Jaya'),
(5, 'Merauke'),
(4, 'Mimika'),
(3, 'Nabire'),
(17, 'Nduga'),
(6, 'Paniai'),
(10, 'Tolikara'),
(15, 'Wamena'),
(7, 'Yahukimo');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
  `title` varchar(160) NOT NULL,
  `company` varchar(160) NOT NULL,
  `location` varchar(120) NOT NULL,
  `category` varchar(120) NOT NULL,
  `salary` varchar(100) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `requirements` text NOT NULL,
  `deadline` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `title`, `company`, `location`, `category`, `salary`, `description`, `requirements`, `deadline`, `created_at`) VALUES
(1, 'Junior Flutter Developer', 'Papua Digital Center', 'Jayapura', 'Software Development', '', 'Membantu pengembangan aplikasi mobile komunitas dan pusat karir.', 'Memahami dasar Dart, Flutter, REST API, dan bersedia belajar dalam tim.', '2026-08-31', '2026-06-30 03:34:02'),
(2, 'Admin Data Komunitas', 'Komunitas Anak Muda Papua', 'Nabire', 'Administrasi', '', 'Mengelola dan memvalidasi data anggota komunitas berdasarkan kabupaten.', 'Teliti, mampu menggunakan spreadsheet, dan memahami pendataan anggota.', '2026-08-15', '2026-06-30 03:34:02'),
(3, 'Content Creator Karir', 'Papua Career Hub', 'Mimika', 'Digital Marketing', '', 'Membuat konten informasi lowongan kerja dan pelatihan untuk anak muda Papua.', 'Mampu membuat konten singkat, desain sederhana, dan komunikasi aktif.', '2026-09-05', '2026-06-30 03:34:02'),
(4, 'Desainer Poster Program Pelatihan', 'Papua Skill Academy', 'Merauke', 'Desain Grafis', '', 'Mendesain poster digital untuk program pelatihan karir dan komunitas.', 'Menguasai Canva atau aplikasi desain sejenis dan memiliki portofolio.', '2026-08-25', '2026-06-30 03:34:02'),
(5, 'Operator Data Pemetaan SDM', 'Yayasan Pemuda Papua Mandiri', 'Biak Numfor', 'Data Entry', '', 'Melakukan input data potensi anak muda Papua untuk kebutuhan pemetaan SDM.', 'Teliti, mampu mengetik cepat, dan siap mengikuti arahan koordinator.', '2026-09-10', '2026-06-30 03:34:02'),
(6, 'operator', 'SD THB', 'Jayapura', 'Digital Marketing', '3.500.000', 'bisa ms xl', 'bisa kerja', '2026-07-05', '2026-07-02 10:21:23');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `firebase_uid` varchar(128) NOT NULL,
  `email` varchar(150) NOT NULL,
  `name` varchar(120) NOT NULL,
  `district` varchar(100) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `skill` varchar(150) DEFAULT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `firebase_uid`, `email`, `name`, `district`, `phone`, `skill`, `role`, `created_at`, `updated_at`) VALUES
(12, 'fS32CJH5G8eDBRPOVnt3JUMa2fz2', 'misonwenda20@gmail.com', 'Mison Wenda', 'Tolikara', '', 'Administrasi', 'admin', '2026-07-02 20:07:56', '2026-07-02 20:09:02'),
(13, 'zjX9UXJYXFghRGGqDMC8PxrPYp62', 'misonwenda89@gmail.com', 'Mince Wenda', 'Jayapura', '082251826455', 'Digital Marketing', 'user', '2026-07-02 20:13:25', '2026-07-04 05:05:08'),
(19, 'C5U57uLdL6P9I5O54E4jmDT7tKe2', '1123150103@global.ac.id', 'Wenda', 'Jayawijaya', '085693142680', 'Software Development', 'user', '2026-07-04 05:15:36', '2026-07-04 05:16:19');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_application` (`user_id`,`job_id`),
  ADD KEY `fk_applications_job` (`job_id`);

--
-- Indexes for table `career_specs`
--
ALTER TABLE `career_specs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `firebase_uid` (`firebase_uid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `career_specs`
--
ALTER TABLE `career_specs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `districts`
--
ALTER TABLE `districts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `fk_applications_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_applications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
