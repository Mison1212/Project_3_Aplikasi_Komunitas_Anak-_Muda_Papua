<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

$uid = trim((string)($_GET['uid'] ?? ''));
if ($uid === '') {
    response_json(false, 'UID wajib diisi.', null, 422);
}

auth_require_self_or_admin($uid, true);

$statement = $pdo->prepare(
    'SELECT applications.id, applications.status, applications.created_at,
            jobs.title, jobs.company, jobs.location
     FROM applications
     INNER JOIN users ON users.id = applications.user_id
     INNER JOIN jobs ON jobs.id = applications.job_id
     WHERE users.firebase_uid = ?
     ORDER BY applications.created_at DESC'
);
$statement->execute([$uid]);

response_json(true, 'Data lamaran ditemukan.', $statement->fetchAll());
