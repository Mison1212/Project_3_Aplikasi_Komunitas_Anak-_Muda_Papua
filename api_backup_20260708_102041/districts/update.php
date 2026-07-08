<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$oldName = trim(required_value($input, 'old_name'));
$name = trim(required_value($input, 'name'));

if ($oldName === '' || $name === '') {
    response_json(false, 'Nama kabupaten wajib diisi.', null, 422);
}

$check = $pdo->prepare(
    'SELECT id FROM districts WHERE LOWER(name) = LOWER(?) AND LOWER(name) <> LOWER(?) LIMIT 1'
);
$check->execute([$name, $oldName]);
if ($check->fetch()) {
    response_json(false, 'Kabupaten sudah terdaftar.', null, 409);
}

$statement = $pdo->prepare('UPDATE districts SET name = ? WHERE LOWER(name) = LOWER(?)');
$statement->execute([$name, $oldName]);

if ($statement->rowCount() === 0 && strtolower($oldName) !== strtolower($name)) {
    response_json(false, 'Kabupaten lama tidak ditemukan.', null, 404);
}

response_json(true, 'Kabupaten berhasil diperbarui.');
