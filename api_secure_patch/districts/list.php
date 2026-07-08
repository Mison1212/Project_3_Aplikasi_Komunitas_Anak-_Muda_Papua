<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';

$statement = $pdo->query('SELECT name FROM districts ORDER BY name ASC');
$districts = array_map(
    static fn($row) => $row['name'],
    $statement->fetchAll()
);

response_json(true, 'Data kabupaten ditemukan.', $districts);
