<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$id = (int)required_value($input, 'id');
$name = trim(required_value($input, 'name'));
$description = trim((string)($input['description'] ?? ''));

if ($id <= 0 || $name === '') {
    response_json(false, 'Data spesifikasi karir tidak lengkap.', null, 422);
}

$check = $pdo->prepare(
    'SELECT id FROM career_specs WHERE LOWER(name) = LOWER(?) AND id <> ? LIMIT 1'
);
$check->execute([$name, $id]);
if ($check->fetch()) {
    response_json(false, 'Spesifikasi karir sudah terdaftar.', null, 409);
}

$statement = $pdo->prepare(
    'UPDATE career_specs SET name = ?, description = ? WHERE id = ?'
);
$statement->execute([$name, $description, $id]);

if ($statement->rowCount() === 0) {
    $exists = $pdo->prepare('SELECT id FROM career_specs WHERE id = ? LIMIT 1');
    $exists->execute([$id]);
    if (!$exists->fetch()) {
        response_json(false, 'Spesifikasi karir tidak ditemukan.', null, 404);
    }
}

response_json(true, 'Spesifikasi karir berhasil diperbarui.');
