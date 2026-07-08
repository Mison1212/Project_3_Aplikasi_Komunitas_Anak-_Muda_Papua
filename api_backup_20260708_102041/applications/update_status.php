<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$id = (int)($input['id'] ?? 0);
$status = trim((string)($input['status'] ?? ''));
$allowed = ['pending', 'accepted', 'rejected'];

if ($id <= 0) {
    response_json(false, 'ID lamaran wajib diisi.', null, 422);
}

if (!in_array($status, $allowed, true)) {
    response_json(false, 'Status lamaran tidak valid.', null, 422);
}

$statement = $pdo->prepare('UPDATE applications SET status = ? WHERE id = ?');
$statement->execute([$status, $id]);

response_json(true, 'Status lamaran berhasil diperbarui.');
