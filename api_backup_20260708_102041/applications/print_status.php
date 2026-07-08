<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

if (!empty($_GET['token'])) {
    $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $_GET['token'];
}

auth_require_admin();

$statement = $pdo->query(
    'SELECT applications.id, applications.status, applications.created_at,
            users.name, users.email, users.district,
            jobs.title, jobs.company
     FROM applications
     INNER JOIN users ON users.id = applications.user_id
     INNER JOIN jobs ON jobs.id = applications.job_id
     ORDER BY applications.created_at DESC
     LIMIT 500'
);
$rows = $statement->fetchAll();

$counts = [
    'pending' => 0,
    'accepted' => 0,
    'rejected' => 0,
];
foreach ($rows as $row) {
    $status = strtolower((string)($row['status'] ?? 'pending'));
    if (!isset($counts[$status])) {
        $status = 'pending';
    }
    $counts[$status]++;
}

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
    <title>Laporan Status Lamaran</title>
    <style>
        body { font-family: Arial, sans-serif; color: #111; margin: 28px; }
        h1 { text-align: center; font-size: 22px; margin: 0 0 6px; }
        p { text-align: center; margin: 0 0 18px; color: #444; }
        .summary { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 18px; }
        .box { border: 1px solid #333; padding: 10px; background: #f3f3f3; }
        .box strong { display: block; font-size: 18px; margin-top: 4px; }
        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        th, td { border: 1px solid #333; padding: 7px 8px; vertical-align: top; }
        th { background: #e8e8e8; text-align: left; }
        .actions { margin-bottom: 16px; text-align: right; }
        button { padding: 8px 14px; border: 1px solid #333; background: #fff; cursor: pointer; }
        @media print {
            .actions { display: none; }
            body { margin: 12mm; }
            .summary { grid-template-columns: repeat(4, 1fr); }
        }
    </style>
</head>
<body>
    <div class="actions"><button onclick="window.print()">Cetak Laporan</button></div>
    <h1>Laporan Status Lamaran</h1>
    <p>Rekap status lamaran pengguna pada aplikasi Karir Muda Papua.</p>
    <div class="summary">
        <div class="box">Total Lamaran<strong><?= count($rows) ?></strong></div>
        <div class="box">Menunggu<strong><?= $counts['pending'] ?></strong></div>
        <div class="box">Diterima<strong><?= $counts['accepted'] ?></strong></div>
        <div class="box">Ditolak<strong><?= $counts['rejected'] ?></strong></div>
    </div>
    <p style="text-align:left"><strong>Tanggal cetak:</strong> <?= e(date('d/m/Y H:i')) ?></p>
    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Nama Pelamar</th>
                <th>Email</th>
                <th>Kabupaten</th>
                <th>Lowongan</th>
                <th>Perusahaan</th>
                <th>Status Lamaran</th>
                <th>Tanggal Daftar</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($rows as $index => $row): ?>
                <tr>
                    <td><?= $index + 1 ?></td>
                    <td><?= e($row['name'] ?? '-') ?></td>
                    <td><?= e($row['email'] ?? '-') ?></td>
                    <td><?= e($row['district'] ?? '-') ?></td>
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
