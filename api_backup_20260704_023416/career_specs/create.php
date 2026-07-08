<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$name = required_value($input, 'name');
$description = trim((string)($input['description'] ?? ''));

try {
    $statement = $pdo->prepare(
        'INSERT INTO career_specs (name, description) VALUES (?, ?)'
    );
    $statement->execute([$name, $description]);
} catch (PDOException $exception) {
    response_json(false, 'Spesifikasi karir sudah ada atau data tidak valid.', null, 409);
}

response_json(true, 'Spesifikasi karir berhasil ditambahkan.', ['id' => $pdo->lastInsertId()], 201);
