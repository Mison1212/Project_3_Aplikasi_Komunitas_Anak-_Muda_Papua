<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

$uid = trim((string)($_GET['uid'] ?? ''));
if ($uid === '') {
    response_json(false, 'UID wajib diisi.', null, 422);
}

auth_require_self_or_admin($uid, true);

$statement = $pdo->prepare('SELECT * FROM users WHERE firebase_uid = ? LIMIT 1');
$statement->execute([$uid]);
$user = $statement->fetch();

if (!$user) {
    response_json(false, 'Profil belum ditemukan.', null, 404);
}

response_json(true, 'Profil ditemukan.', $user);
