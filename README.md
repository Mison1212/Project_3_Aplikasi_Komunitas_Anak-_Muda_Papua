# Platform Digital Komunitas & Pusat Karir Anak Muda Papua

Project Flutter ini dibuat berdasarkan laporan Project 3 sampai Bab III.

## Fitur awal

- Registrasi akun menggunakan Firebase Authentication.
- Login akun pengguna.
- Sinkronisasi profil pengguna ke MySQL melalui REST API PHP.
- Kelola data pribadi: nama, kabupaten, telepon, dan spesifikasi karir.
- Dropdown kabupaten dan spesifikasi karir berbasis data master API.
- Daftar lowongan pekerjaan dengan pencarian dan pagination.
- Detail lowongan pekerjaan.
- Pendaftaran lowongan pekerjaan.
- Riwayat lamaran pengguna.
- Admin dashboard untuk ringkasan user, lowongan, lamaran, dan lamaran diterima.
- Kelola data user.
- Kelola data kabupaten.
- Kelola data spesifikasi karir.
- Tambah lowongan pekerjaan.
- Laporan pendaftaran lowongan.

## Konfigurasi penting

1. Buat project Firebase dan aktifkan Email/Password Authentication.
2. Pasang file `lib/firebase_options.dart` hasil FlutterFire CLI.
3. Salin folder `papua_youth_career_api` ke folder `htdocs` XAMPP.
4. Import file `papua_youth_career_api/database/papua_youth_career.sql` ke MySQL.
5. Sesuaikan alamat API:
   - Android emulator: `http://10.0.2.2/papua_youth_career_api`
   - HP fisik: `http://IP-LAPTOP/papua_youth_career_api`

Alamat default API ada di `lib/app_config.dart`. Untuk HP fisik, bisa juga menjalankan:

```bash
flutter run --dart-define=API_BASE_URL=http://IP-LAPTOP/papua_youth_career_api
```

## Akun admin

Setelah registrasi akun pertama, ubah role akun tersebut di phpMyAdmin:

```sql
UPDATE users SET role = 'admin' WHERE email = 'email_admin_anda@gmail.com';
```

## Perintah jalan

```bash
flutter pub get
flutter run
```
