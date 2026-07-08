<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$id = (int)required_value($input, 'id');

if ($id <= 0) {
    response_json(false, 'ID spesifikasi karir tidak valid.', null, 422);
}

$statement = $pdo->prepare('DELETE FROM career_specs WHERE id = ?');
$statement->execute([$id]);

if ($statement->rowCount() === 0) {
    response_json(false, 'Spesifikasi karir tidak ditemukan.', null, 404);
}

response_json(true, 'Spesifikasi karir berhasil dihapus.');
