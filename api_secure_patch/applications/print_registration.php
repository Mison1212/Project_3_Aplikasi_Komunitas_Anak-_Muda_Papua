<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

if (!empty($_GET['token'])) {
    $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $_GET['token'];
}

auth_require_admin();

header('Content-Type: text/html; charset=utf-8');

$statement = $pdo->query(
    'SELECT applications.id, applications.status, applications.created_at,
            users.name, users.email, users.phone, users.district, users.skill,
            jobs.title, jobs.company
     FROM applications
     INNER JOIN users ON users.id = applications.user_id
     INNER JOIN jobs ON jobs.id = applications.job_id
     ORDER BY applications.created_at DESC
     LIMIT 500'
);
$rows = $statement->fetchAll();

function e($value): string
{
    return htmlspecialchars((string)($value ?? '-'), ENT_QUOTES, 'UTF-8');
}

function status_label($status): string
{
    $value = strtolower((string)$status);
    if ($value === 'accepted') return 'Diterima';
    if ($value === 'rejected') return 'Ditolak';
    return 'Menunggu';
}

?><!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Laporan Pendaftaran Lowongan</title>
    <style>
        body { font-family: Arial, sans-serif; color: #111; margin: 28px; }
        h1 { text-align: center; font-size: 22px; margin: 0 0 6px; }
        p { text-align: center; margin: 0 0 18px; color: #444; }
        .summary { margin-bottom: 18px; }
        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        th, td { border: 1px solid #333; padding: 7px 8px; vertical-align: top; }
        th { background: #e8e8e8; text-align: left; }
        .actions { margin-bottom: 16px; text-align: right; }
        button { padding: 8px 14px; border: 1px solid #333; background: #fff; cursor: pointer; }
        @media print { .actions { display: none; } body { margin: 12mm; } }
    </style>
</head>
<body>
    <div class="actions"><button onclick="window.print()">Cetak Laporan</button></div>
    <h1>Laporan Pendaftaran Lowongan</h1>
    <p>Daftar seluruh pendaftaran lowongan pada aplikasi Karir Muda Papua.</p>
    <div class="summary">
        <strong>Total pendaftaran:</strong> <?= count($rows) ?><br>
        <strong>Tanggal cetak:</strong> <?= e(date('d/m/Y H:i')) ?>
    </div>
    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Nama</th>
                <th>Email</th>
                <th>Telepon</th>
                <th>Kabupaten</th>
                <th>Spesifikasi Karir</th>
                <th>Lowongan</th>
                <th>Perusahaan</th>
                <th>Status</th>
                <th>Tanggal Daftar</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($rows as $index => $row): ?>
                <tr>
                    <td><?= $index + 1 ?></td>
                    <td><?= e($row['name'] ?? '-') ?></td>
                    <td><?= e($row['email'] ?? '-') ?></td>
                    <td><?= e($row['phone'] ?? '-') ?></td>
                    <td><?= e($row['district'] ?? '-') ?></td>
                    <td><?= e($row['skill'] ?? '-') ?></td>
                    <td><?= e($row['title'] ?? '-') ?></td>
                    <td><?= e($row['company'] ?? '-') ?></td>
                    <td><?= e(status_label($row['status'] ?? 'pending')) ?></td>
                    <td><?= e($row['created_at'] ?? '-') ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <script>window.addEventListener('load', function () { setTimeout(function () { window.print(); }, 500); });</script>
</body>
</html>
