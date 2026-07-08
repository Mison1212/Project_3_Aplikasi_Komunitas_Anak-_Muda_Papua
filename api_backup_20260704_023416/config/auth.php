<?php
const FIREBASE_PROJECT_ID = 'anak-mudah-papua';

function auth_header(): string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if ($header === '' && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }
    return trim((string)$header);
}

function base64url_decode_json(string $value): array
{
    $decoded = base64_decode(strtr($value, '-_', '+/'));
    $json = json_decode((string)$decoded, true);
    return is_array($json) ? $json : [];
}

function firebase_certs(): array
{
    $cache = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'firebase_securetoken_certs.json';
    if (is_file($cache) && filemtime($cache) > time() - 3600) {
        $cached = json_decode((string)file_get_contents($cache), true);
        if (is_array($cached)) return $cached;
    }

    $json = @file_get_contents('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com');
    if ($json === false) {
        response_json(false, 'Gagal mengambil sertifikat Firebase.', null, 503);
    }

    file_put_contents($cache, $json);
    $certs = json_decode($json, true);
    return is_array($certs) ? $certs : [];
}

function verify_firebase_token(string $token): array
{
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        response_json(false, 'Token tidak valid.', null, 401);
    }

    [$encodedHeader, $encodedPayload, $encodedSignature] = $parts;
    $header = base64url_decode_json($encodedHeader);
    $payload = base64url_decode_json($encodedPayload);
    $signature = base64_decode(strtr($encodedSignature, '-_', '+/'));

    if (($header['alg'] ?? '') !== 'RS256' || empty($header['kid'])) {
        response_json(false, 'Token tidak valid.', null, 401);
    }

    $certs = firebase_certs();
    $certificate = $certs[$header['kid']] ?? null;
    if (!$certificate) {
        response_json(false, 'Sertifikat token tidak ditemukan.', null, 401);
    }

    $verified = openssl_verify(
        $encodedHeader . '.' . $encodedPayload,
        $signature,
        $certificate,
        OPENSSL_ALGO_SHA256
    );

    if ($verified !== 1) {
        response_json(false, 'Token gagal diverifikasi.', null, 401);
    }

    $now = time();
    if (($payload['aud'] ?? '') !== FIREBASE_PROJECT_ID) {
        response_json(false, 'Audience token tidak sesuai.', null, 401);
    }
    if (($payload['iss'] ?? '') !== 'https://securetoken.google.com/' . FIREBASE_PROJECT_ID) {
        response_json(false, 'Issuer token tidak sesuai.', null, 401);
    }
    if (empty($payload['sub']) || strlen((string)$payload['sub']) > 128) {
        response_json(false, 'UID token tidak valid.', null, 401);
    }
    if (($payload['exp'] ?? 0) < $now) {
        response_json(false, 'Token sudah kedaluwarsa.', null, 401);
    }

    return $payload;
}

function auth_user(bool $requireVerified = true): array
{
    $header = auth_header();
    if (!preg_match('/^Bearer\s+(.+)$/i', $header, $matches)) {
        response_json(false, 'Token login wajib dikirim.', null, 401);
    }

    $payload = verify_firebase_token($matches[1]);
    if ($requireVerified && ($payload['email_verified'] ?? false) !== true) {
        response_json(false, 'Email belum diverifikasi.', null, 403);
    }

    return $payload;
}

function auth_profile(string $uid): ?array
{
    global $pdo;
    $statement = $pdo->prepare('SELECT * FROM users WHERE firebase_uid = ? LIMIT 1');
    $statement->execute([$uid]);
    $profile = $statement->fetch();
    return $profile ?: null;
}

function auth_require_admin(): array
{
    $token = auth_user(true);
    $profile = auth_profile((string)$token['sub']);
    if (!$profile || ($profile['role'] ?? 'user') !== 'admin') {
        response_json(false, 'Akses admin ditolak.', null, 403);
    }
    return $profile;
}

function auth_require_self_or_admin(string $uid, bool $requireVerified = true): array
{
    $token = auth_user($requireVerified);
    if ((string)$token['sub'] === $uid) {
        return $token;
    }

    $profile = auth_profile((string)$token['sub']);
    if ($profile && ($profile['role'] ?? 'user') === 'admin') {
        return $token;
    }

    response_json(false, 'Akses data pengguna ditolak.', null, 403);
}
