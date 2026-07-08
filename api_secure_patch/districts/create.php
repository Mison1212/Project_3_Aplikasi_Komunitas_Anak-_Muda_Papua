<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$name = trim(required_value($input, 'name'));

$check = $pdo->prepare('SELECT id FROM districts WHERE LOWER(name) = LOWER(?) LIMIT 1');
$check->execute([$name]);
if ($check->fetch()) {
    response_json(false, 'Kabupaten sudah terdaftar.', null, 409);
}

try {
    $statement = $pdo->prepare('INSERT INTO districts (name) VALUES (?)');
    $statement->execute([$name]);
} catch (PDOException $exception) {
    response_json(false, 'Kabupaten sudah ada atau data tidak valid.', null, 409);
}

response_json(true, 'Kabupaten berhasil ditambahkan.', ['id' => $pdo->lastInsertId()], 201);
