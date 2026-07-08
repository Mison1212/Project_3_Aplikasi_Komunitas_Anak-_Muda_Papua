<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$statement = $pdo->query(
    'SELECT applications.id, applications.status, applications.created_at,
            users.name, users.email, users.phone, users.district,
            jobs.title, jobs.company
     FROM applications
     INNER JOIN users ON users.id = applications.user_id
     INNER JOIN jobs ON jobs.id = applications.job_id
     ORDER BY applications.created_at DESC
     LIMIT 200'
);

response_json(true, 'Laporan pendaftaran lowongan ditemukan.', $statement->fetchAll());
