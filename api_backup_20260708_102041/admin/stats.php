<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$users = (int)$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
$jobs = (int)$pdo->query('SELECT COUNT(*) FROM jobs')->fetchColumn();
$applications = (int)$pdo->query('SELECT COUNT(*) FROM applications')->fetchColumn();
$accepted = (int)$pdo->query('SELECT COUNT(*) FROM applications WHERE status = "accepted"')->fetchColumn();

$byDistrict = $pdo->query(
    'SELECT district, COUNT(*) AS total
     FROM users
     GROUP BY district
     ORDER BY total DESC, district ASC'
)->fetchAll();

$byStatus = $pdo->query(
    'SELECT status, COUNT(*) AS total
     FROM applications
     GROUP BY status
     ORDER BY status ASC'
)->fetchAll();

$byJob = $pdo->query(
    'SELECT jobs.title, COUNT(applications.id) AS total
     FROM jobs
     LEFT JOIN applications ON applications.job_id = jobs.id
     GROUP BY jobs.id, jobs.title
     ORDER BY total DESC, jobs.title ASC
     LIMIT 10'
)->fetchAll();

response_json(true, 'Statistik ditemukan.', [
    'users' => $users,
    'jobs' => $jobs,
    'applications' => $applications,
    'accepted' => $accepted,
    'by_district' => $byDistrict,
    'by_status' => $byStatus,
    'by_job' => $byJob,
]);
