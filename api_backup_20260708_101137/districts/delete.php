<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$name = trim(required_value($input, 'name'));

if ($name === '') {
    response_json(false, 'Nama kabupaten wajib diisi.', null, 422);
}

$statement = $pdo->prepare('DELETE FROM districts WHERE LOWER(name) = LOWER(?)');
$statement->execute([$name]);

if ($statement->rowCount() === 0) {
    response_json(false, 'Kabupaten tidak ditemukan.', null, 404);
}

response_json(true, 'Kabupaten berhasil dihapus.');
