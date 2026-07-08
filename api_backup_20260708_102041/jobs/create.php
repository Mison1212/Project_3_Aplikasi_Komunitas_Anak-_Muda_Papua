<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$title = required_value($input, 'title');
$company = required_value($input, 'company');
$location = required_value($input, 'location');
$category = required_value($input, 'category');
$salary = required_value($input, 'salary');
$description = required_value($input, 'description');
$requirements = required_value($input, 'requirements');
$deadline = required_value($input, 'deadline');

$salaryColumn = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'salary'")->fetch();

if ($salaryColumn) {
    $statement = $pdo->prepare(
        'INSERT INTO jobs (title, company, location, category, salary, description, requirements, deadline)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
    );
    $statement->execute([$title, $company, $location, $category, $salary, $description, $requirements, $deadline]);
} else {
    $statement = $pdo->prepare(
        'INSERT INTO jobs (title, company, location, category, description, requirements, deadline)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $statement->execute([$title, $company, $location, $category, $description, $requirements, $deadline]);
}

response_json(true, 'Lowongan berhasil ditambahkan.', ['id' => $pdo->lastInsertId()], 201);
