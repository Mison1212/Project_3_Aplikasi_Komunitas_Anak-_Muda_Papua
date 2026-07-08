<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';

$query = trim($_GET['q'] ?? '');
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = 10;
$offset = ($page - 1) * $limit;
$salaryColumn = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'salary'")->fetch();
$salarySelect = $salaryColumn ? 'salary' : "'' AS salary";

if ($query !== '') {
    $statement = $pdo->prepare(
        "SELECT id, title, company, location, category, $salarySelect, description, requirements, deadline
         FROM jobs
         WHERE title LIKE ? OR company LIKE ? OR location LIKE ? OR category LIKE ?
         ORDER BY id DESC
         LIMIT $limit OFFSET $offset"
    );
    $search = '%' . $query . '%';
    $statement->execute([$search, $search, $search, $search]);
} else {
    $statement = $pdo->query(
        "SELECT id, title, company, location, category, $salarySelect, description, requirements, deadline
         FROM jobs
         ORDER BY id DESC
         LIMIT $limit OFFSET $offset"
    );
}

response_json(true, 'Data lowongan ditemukan.', $statement->fetchAll());
