<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

auth_require_admin();

$input = input_json();
$id = (int)($input['id'] ?? 0);
$title = required_value($input, 'title');
$company = required_value($input, 'company');
$location = required_value($input, 'location');
$category = required_value($input, 'category');
$salary = required_value($input, 'salary');
$description = required_value($input, 'description');
$requirements = required_value($input, 'requirements');
$deadline = required_value($input, 'deadline');

if ($id <= 0) {
    response_json(false, 'ID lowongan wajib diisi.', null, 422);
}

$salaryColumn = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'salary'")->fetch();

if ($salaryColumn) {
    $statement = $pdo->prepare(
        'UPDATE jobs
         SET title = ?, company = ?, location = ?, category = ?, salary = ?,
             description = ?, requirements = ?, deadline = ?
         WHERE id = ?'
    );
    $statement->execute([$title, $company, $location, $category, $salary, $description, $requirements, $deadline, $id]);
} else {
    $statement = $pdo->prepare(
        'UPDATE jobs
         SET title = ?, company = ?, location = ?, category = ?,
             description = ?, requirements = ?, deadline = ?
         WHERE id = ?'
    );
    $statement->execute([$title, $company, $location, $category, $description, $requirements, $deadline, $id]);
}

if ($statement->rowCount() === 0) {
    $check = $pdo->prepare('SELECT id FROM jobs WHERE id = ? LIMIT 1');
    $check->execute([$id]);
    if (!$check->fetch()) {
        response_json(false, 'Lowongan tidak ditemukan.', null, 404);
    }
}

response_json(true, 'Lowongan berhasil diperbarui.');
