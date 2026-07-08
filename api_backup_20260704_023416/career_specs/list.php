<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';

$statement = $pdo->query(
    'SELECT id, name, description
     FROM career_specs
     ORDER BY name ASC'
);

response_json(true, 'Data spesifikasi karir ditemukan.', $statement->fetchAll());
