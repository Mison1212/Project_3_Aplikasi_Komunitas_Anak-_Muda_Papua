<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$query = trim((string)($_GET['q'] ?? ''));
$search = "%$query%";

$statement = $pdo->prepare(
    'SELECT id, firebase_uid, email, name, district, phone, skill, role, created_at
     FROM users
     WHERE name LIKE :search OR email LIKE :search OR district LIKE :search OR skill LIKE :search
     ORDER BY created_at DESC
     LIMIT 100'
);
$statement->execute(['search' => $search]);

response_json(true, 'Data user ditemukan.', $statement->fetchAll());
