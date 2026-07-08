<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

$input = input_json();
$uid = required_value($input, 'firebase_uid');
auth_require_self_or_admin($uid, true);

$jobId = (int)($input['job_id'] ?? 0);
if ($jobId <= 0) {
    response_json(false, 'ID lowongan wajib diisi.', null, 422);
}

$userStatement = $pdo->prepare('SELECT id FROM users WHERE firebase_uid = ? LIMIT 1');
$userStatement->execute([$uid]);
$user = $userStatement->fetch();

if (!$user) {
    response_json(false, 'Profil pengguna belum ditemukan.', null, 404);
}

try {
    $statement = $pdo->prepare(
        'INSERT INTO applications (user_id, job_id, status) VALUES (?, ?, "pending")'
    );
    $statement->execute([$user['id'], $jobId]);
} catch (PDOException $exception) {
    response_json(false, 'Lamaran sudah pernah dikirim atau data tidak valid.', null, 409);
}

response_json(true, 'Lamaran berhasil dikirim.');
