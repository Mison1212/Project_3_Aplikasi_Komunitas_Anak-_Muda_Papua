<?php
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/auth.php';

$input = input_json();
$uid = required_value($input, 'firebase_uid');
$token = auth_user(false);
if ((string)$token['sub'] !== $uid) {
    response_json(false, 'UID tidak sesuai dengan token login.', null, 403);
}

$email = trim((string)($token['email'] ?? required_value($input, 'email')));
$name = required_value($input, 'name');
$district = required_value($input, 'district');
$phone = trim((string)($input['phone'] ?? ''));
$skill = trim((string)($input['skill'] ?? ''));

$statement = $pdo->prepare(
    'INSERT INTO users (firebase_uid, email, name, district, phone, skill, role)
     VALUES (:firebase_uid, :email, :name, :district, :phone, :skill, "user")
     ON DUPLICATE KEY UPDATE
        email = VALUES(email),
        name = VALUES(name),
        district = VALUES(district),
        phone = VALUES(phone),
        skill = VALUES(skill),
        role = IF(role = "admin", role, "user"),
        updated_at = CURRENT_TIMESTAMP'
);
$statement->execute([
    'firebase_uid' => $uid,
    'email' => $email,
    'name' => $name,
    'district' => $district,
    'phone' => $phone,
    'skill' => $skill,
]);

$detail = $pdo->prepare('SELECT * FROM users WHERE firebase_uid = ? LIMIT 1');
$detail->execute([$uid]);
response_json(true, 'Profil berhasil disinkronkan.', $detail->fetch());
