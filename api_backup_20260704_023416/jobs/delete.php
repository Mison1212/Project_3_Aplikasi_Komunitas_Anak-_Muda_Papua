<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$id = (int)($input['id'] ?? 0);

if ($id <= 0) {
    response_json(false, 'ID lowongan wajib diisi.', null, 422);
}

$statement = $pdo->prepare('DELETE FROM jobs WHERE id = ?');
$statement->execute([$id]);

if ($statement->rowCount() === 0) {
    response_json(false, 'Lowongan tidak ditemukan.', null, 404);
}

response_json(true, 'Lowongan berhasil dihapus.');
