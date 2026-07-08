<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';

$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) {
    response_json(false, 'ID lowongan wajib diisi.', null, 422);
}

$salaryColumn = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'salary'")->fetch();
$salarySelect = $salaryColumn ? 'salary' : "'' AS salary";
$statement = $pdo->prepare(
    "SELECT id, title, company, location, category, $salarySelect, description, requirements, deadline
     FROM jobs
     WHERE id = ?
     LIMIT 1"
);
$statement->execute([$id]);
$job = $statement->fetch();

if (!$job) {
    response_json(false, 'Lowongan tidak ditemukan.', null, 404);
}

response_json(true, 'Detail lowongan ditemukan.', $job);
