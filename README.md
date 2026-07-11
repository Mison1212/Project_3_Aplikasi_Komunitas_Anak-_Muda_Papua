# Buku Panduan Implementasi Aplikasi Karir Muda Papua

## 1. Pendahuluan

**Karir Muda Papua** adalah aplikasi mobile berbasis Flutter yang dibuat sebagai Platform Digital Komunitas dan Pusat Karir Anak Muda Papua. Aplikasi ini membantu pemuda Papua untuk membuat akun, mengelola profil, mencari lowongan pekerjaan, melakukan pendaftaran lowongan, dan memantau status lamaran. Di sisi lain, admin dapat mengelola data user, lowongan pekerjaan, data master kabupaten, spesifikasi karir, status lamaran, serta mencetak laporan pendaftaran dan laporan status lamaran.

Aplikasi ini menggunakan beberapa teknologi utama:

- **Flutter dan Dart** sebagai frontend aplikasi mobile.
- **Firebase Authentication** sebagai sistem registrasi, login, dan verifikasi email.
- **PHP REST API** sebagai penghubung aplikasi dengan database.
- **MySQL** sebagai penyimpanan data profil, lowongan, lamaran, kabupaten, dan spesifikasi karir.
- **XAMPP/Apache** sebagai server lokal untuk menjalankan API PHP.

## 2. Tujuan Aplikasi

Tujuan implementasi aplikasi ini adalah:

1. Menyediakan media digital untuk pendataan anak muda Papua berdasarkan profil, asal kabupaten, dan spesifikasi karir.
2. Menyediakan pusat informasi lowongan pekerjaan yang dapat diakses melalui aplikasi mobile.
3. Memudahkan user melakukan pendaftaran lowongan pekerjaan secara digital.
4. Memudahkan admin mengelola user, lowongan, lamaran, kabupaten, dan spesifikasi karir.
5. Menyediakan laporan pendaftaran dan laporan status lamaran yang dapat dicetak.

## 3. Struktur Project

Struktur folder utama pada project:

```text
papua_youth_career_app/
+-- android/                     # Konfigurasi Android
+-- api_secure_patch/            # File API PHP yang dipasang ke XAMPP
+-- assets/                      # Asset aplikasi, termasuk icon
+-- docs/                        # Dokumen tambahan dan diagram
+-- lib/                         # Source code utama Flutter
|   +-- models/                  # Model data AppUser dan Job
|   +-- screens/                 # Halaman aplikasi
|   +-- services/                # AuthService dan ApiService
|   +-- widgets/                 # Komponen UI reusable
|   +-- app_config.dart          # Konfigurasi alamat API
|   +-- firebase_options.dart    # Konfigurasi Firebase
|   +-- main.dart                # Entry point aplikasi
+-- pubspec.yaml                 # Dependency Flutter
+-- README.md                    # Buku panduan implementasi aplikasi
```

## 4. Fitur Aplikasi

### 4.1 Fitur User

User adalah pengguna umum atau pemuda Papua yang memakai aplikasi untuk mencari informasi lowongan dan mendaftar pekerjaan.

Fitur user:

- Registrasi akun menggunakan email dan password.
- Verifikasi email melalui Firebase Authentication.
- Login setelah email terverifikasi.
- Mengelola profil pribadi.
- Memilih asal kabupaten.
- Memilih spesifikasi karir.
- Melihat daftar lowongan pekerjaan.
- Mencari lowongan berdasarkan kata kunci.
- Melihat detail lowongan.
- Mendaftar lowongan pekerjaan.
- Melihat riwayat dan status lamaran.
- Logout dari aplikasi.

### 4.2 Fitur Admin

Admin adalah pengguna yang memiliki role `admin` pada database.

Fitur admin:

- Melihat dashboard statistik.
- Melihat jumlah user, lowongan, lamaran, dan lamaran diterima.
- Mengelola data lowongan pekerjaan.
- Menambah, mengedit, dan menghapus lowongan.
- Mengelola status lamaran: `pending`, `accepted`, dan `rejected`.
- Menghubungi pelamar melalui WhatsApp.
- Mengelola data user.
- Mengelola data master kabupaten.
- Mengelola data master spesifikasi karir.
- Mencetak laporan pendaftaran lowongan.
- Mencetak laporan status lamaran.
- Logout dari aplikasi.

## 5. Alur Kerja Aplikasi dari Awal hingga Akhir

### 5.1 Alur Awal Aplikasi

1. User membuka aplikasi.
2. Aplikasi menjalankan inisialisasi Firebase pada `main.dart`.
3. Sistem memeriksa apakah Firebase berhasil dikonfigurasi.
4. Jika Firebase belum siap, aplikasi menampilkan halaman informasi konfigurasi Firebase.
5. Jika Firebase siap, sistem memeriksa status login user melalui `AuthService`.
6. Jika user belum login, sistem menampilkan halaman Login.
7. Jika user sudah login tetapi email belum terverifikasi, sistem tetap mengarahkan user ke halaman Login.
8. Jika user sudah login dan email sudah terverifikasi, sistem membuka `HomeScreen`.
9. `HomeScreen` mengambil profil user dari API.
10. Jika role user adalah `admin`, sistem membuka halaman Admin.
11. Jika role user bukan admin, sistem membuka halaman utama user.

### 5.2 Alur Registrasi User

1. User membuka halaman Registrasi.
2. Sistem memuat data kabupaten dan spesifikasi karir dari API.
3. User mengisi:
   - nama lengkap,
   - email,
   - asal kabupaten,
   - spesifikasi karir,
   - password.
4. User menekan tombol `Sign Up`.
5. Sistem melakukan validasi input.
6. Jika data belum valid, sistem menampilkan pesan validasi.
7. Jika data valid, sistem membuat akun di Firebase Authentication.
8. Sistem mengirim email verifikasi.
9. Sistem menyimpan data profil user ke MySQL melalui API.
10. Sistem logout otomatis.
11. User diarahkan kembali ke halaman Login.
12. User harus membuka email dan melakukan verifikasi sebelum dapat login.

### 5.3 Alur Login User

1. User membuka halaman Login.
2. User memasukkan email dan password.
3. User menekan tombol `Login`.
4. Sistem memvalidasi akun melalui Firebase Authentication.
5. Jika email atau password salah, sistem menampilkan pesan gagal.
6. Jika email belum diverifikasi, sistem mengirim ulang email verifikasi dan logout.
7. Jika login berhasil dan email sudah terverifikasi, sistem mengambil data profil dari API.
8. Jika role adalah admin, sistem membuka halaman Admin.
9. Jika role adalah user, sistem membuka halaman Beranda.

### 5.4 Alur User Mencari dan Mendaftar Lowongan

1. User memilih menu `Lowongan`.
2. Sistem mengambil daftar lowongan dari API.
3. Sistem menampilkan daftar lowongan.
4. User dapat mencari lowongan berdasarkan kata kunci.
5. Sistem menampilkan hasil pencarian.
6. User memilih salah satu lowongan.
7. Sistem menampilkan detail lowongan, seperti:
   - nama pekerjaan,
   - perusahaan,
   - lokasi,
   - kategori,
   - gaji,
   - deadline,
   - deskripsi,
   - persyaratan.
8. User menekan tombol `Daftar Lowongan`.
9. Sistem mengambil UID user yang sedang login.
10. Sistem mengirim data pendaftaran ke endpoint API.
11. Jika berhasil, sistem menampilkan pesan pendaftaran berhasil.
12. Jika user sudah pernah mendaftar atau terjadi kesalahan, sistem menampilkan pesan gagal.

### 5.5 Alur User Melihat Status Lamaran

1. User memilih menu `Lamaran`.
2. Sistem mengambil data lamaran milik user dari API berdasarkan UID Firebase.
3. Sistem menampilkan daftar lamaran user.
4. User dapat melihat status lamaran:
   - `pending` atau menunggu,
   - `accepted` atau diterima,
   - `rejected` atau ditolak.
5. Jika admin mengubah status lamaran, user dapat melihat status terbaru pada halaman ini.

### 5.6 Alur User Mengelola Profil

1. User memilih menu `Profil`.
2. Sistem menampilkan data profil user.
3. Sistem memuat data kabupaten dan spesifikasi karir.
4. User dapat mengubah:
   - nama lengkap,
   - nomor telepon,
   - asal kabupaten,
   - spesifikasi karir.
5. User menekan tombol `Simpan Profil`.
6. Sistem memvalidasi data.
7. Jika valid, sistem menyimpan profil melalui API.
8. Sistem menampilkan pesan profil berhasil disimpan.
9. User dapat logout melalui halaman profil.

### 5.7 Alur Admin Mengelola Dashboard

1. Admin login menggunakan akun yang memiliki role `admin`.
2. Sistem membuka halaman Admin.
3. Sistem mengambil data statistik dari API.
4. Admin melihat ringkasan:
   - total user,
   - total lowongan,
   - total lamaran,
   - total lamaran diterima,
   - lamaran menunggu persetujuan.
5. Admin dapat berpindah ke menu Lowongan, Lamaran, User, dan Master.

### 5.8 Alur Admin Mengelola Lowongan

1. Admin membuka menu `Lowongan`.
2. Sistem menampilkan daftar lowongan.
3. Admin dapat mencari lowongan.
4. Admin dapat menambah lowongan baru.
5. Admin mengisi:
   - judul lowongan,
   - nama perusahaan,
   - gaji,
   - lokasi,
   - kategori,
   - deadline,
   - deskripsi,
   - persyaratan.
6. Sistem memvalidasi data.
7. Sistem menyimpan lowongan ke database melalui API.
8. Admin dapat mengedit lowongan yang sudah ada.
9. Admin dapat menghapus lowongan setelah konfirmasi.

### 5.9 Alur Admin Mengelola Lamaran

1. Admin membuka menu `Lamaran`.
2. Sistem mengambil laporan lamaran dari API.
3. Sistem menampilkan daftar lamaran.
4. Admin dapat memfilter lamaran:
   - semua,
   - menunggu,
   - diterima,
   - ditolak.
5. Admin dapat mengubah status lamaran:
   - `Terima` untuk mengubah status menjadi `accepted`,
   - `Tolak` untuk mengubah status menjadi `rejected`,
   - `Reset` untuk mengubah status menjadi `pending`.
6. Sistem menyimpan perubahan status ke database melalui API.
7. Admin dapat menghubungi pelamar melalui tombol WhatsApp.

### 5.10 Alur Admin Mencetak Laporan

Admin dapat mencetak dua jenis laporan:

1. **Laporan Pendaftaran Lowongan**
   - Admin membuka menu `Kelola Lamaran`.
   - Admin menekan tombol `Cetak Pendaftaran`.
   - Sistem mengambil token admin dari Firebase.
   - Sistem membuka endpoint `applications/print_registration.php`.
   - API memverifikasi token dan hak akses admin.
   - API mengambil data pendaftaran dari database.
   - Sistem menampilkan halaman laporan siap cetak.
   - Admin mencetak laporan.

2. **Laporan Status Lamaran**
   - Admin membuka menu `Kelola Lamaran`.
   - Admin menekan tombol `Cetak Status`.
   - Sistem mengambil token admin dari Firebase.
   - Sistem membuka endpoint `applications/print_status.php`.
   - API memverifikasi token dan hak akses admin.
   - API mengambil data status lamaran dari database.
   - API menghitung total lamaran menunggu, diterima, dan ditolak.
   - Sistem menampilkan halaman laporan siap cetak.
   - Admin mencetak laporan.

### 5.11 Alur Admin Mengelola Data User

1. Admin membuka menu `User`.
2. Sistem mengambil daftar user dari API.
3. Sistem menampilkan data user.
4. Admin dapat mencari user berdasarkan nama, kabupaten, spesifikasi karir, atau email.
5. Admin dapat menghubungi user melalui WhatsApp jika nomor telepon tersedia.

### 5.12 Alur Admin Mengelola Data Master

Data master terdiri dari kabupaten dan spesifikasi karir.

Alur kelola kabupaten:

1. Admin membuka menu `Master`.
2. Sistem menampilkan daftar kabupaten.
3. Admin dapat menambah kabupaten baru.
4. Admin dapat mengedit nama kabupaten.
5. Admin dapat menghapus kabupaten setelah konfirmasi.
6. Sistem menyimpan perubahan ke database melalui API.

Alur kelola spesifikasi karir:

1. Admin membuka menu `Master`.
2. Sistem menampilkan daftar spesifikasi karir.
3. Admin dapat menambah spesifikasi karir baru.
4. Admin dapat mengedit nama dan deskripsi spesifikasi karir.
5. Admin dapat menghapus spesifikasi karir setelah konfirmasi.
6. Sistem menyimpan perubahan ke database melalui API.

## 6. Kebutuhan Implementasi

### 6.1 Software

Software yang dibutuhkan:

- Flutter SDK.
- Dart SDK.
- Android Studio atau Visual Studio Code.
- Firebase project.
- XAMPP.
- PHP 8 atau versi yang kompatibel.
- MySQL atau MariaDB.
- Browser.
- phpMyAdmin.

### 6.2 Dependency Flutter

Dependency utama pada `pubspec.yaml`:

- `firebase_core`
- `firebase_auth`
- `http`
- `intl`
- `url_launcher`

Install dependency dengan perintah:

```bash
flutter pub get
```

## 7. Konfigurasi Firebase

Langkah konfigurasi Firebase:

1. Buat project Firebase.
2. Aktifkan Authentication.
3. Aktifkan metode login **Email/Password**.
4. Daftarkan aplikasi Android ke Firebase.
5. Unduh file `google-services.json`.
6. Letakkan file tersebut di:

```text
android/app/google-services.json
```

7. Jalankan FlutterFire CLI untuk membuat `firebase_options.dart`, atau pastikan file berikut sudah sesuai:

```text
lib/firebase_options.dart
```

Jika Firebase belum dikonfigurasi dengan benar, aplikasi akan menampilkan halaman informasi bahwa konfigurasi Firebase belum dipasang.

## 8. Konfigurasi API PHP dan MySQL

### 8.1 Menyiapkan Folder API

Folder API yang digunakan aplikasi berada pada:

```text
api_secure_patch/
```

Untuk memasang API ke XAMPP, salin isi folder `api_secure_patch` ke:

```text
C:\xampp\htdocs\papua_youth_career_api
```

Atau jalankan script:

```powershell
powershell -ExecutionPolicy Bypass -File install_api_security_patch.ps1
```

### 8.2 Konfigurasi Database

Pastikan database MySQL sudah memiliki tabel utama berikut:

- `users`
- `jobs`
- `applications`
- `career_specs`
- tabel/penyimpanan data kabupaten sesuai API yang digunakan.

Jika ada perubahan struktur, jalankan file SQL tambahan yang tersedia di:

```text
api_secure_patch/database/add_salary_to_jobs.sql
```

### 8.3 Konfigurasi Token Firebase pada API

API menggunakan token Firebase untuk membatasi hak akses.

Hak akses API:

- Endpoint publik:
  - daftar lowongan,
  - detail lowongan,
  - daftar kabupaten,
  - daftar spesifikasi karir.
- Endpoint user:
  - data profil sendiri,
  - lamaran sendiri.
- Endpoint admin:
  - statistik admin,
  - daftar semua user,
  - laporan lamaran,
  - ubah status lamaran,
  - tambah/edit/hapus lowongan,
  - tambah/edit/hapus kabupaten,
  - tambah/edit/hapus spesifikasi karir,
  - cetak laporan pendaftaran,
  - cetak laporan status lamaran.

Pastikan PHP mengaktifkan ekstensi:

```text
openssl
```

Komputer juga perlu akses internet saat pertama kali API memverifikasi token Firebase, karena API mengambil public certificate dari Google.

## 9. Konfigurasi Alamat API di Flutter

Alamat API diatur pada:

```text
lib/app_config.dart
```

Contoh alamat API:

```text
http://192.168.13.233/papua_youth_career_api
```

Jika memakai Android emulator dan server berada di laptop yang sama, alamat umum yang bisa digunakan:

```text
http://10.0.2.2/papua_youth_career_api
```

Jika memakai HP fisik, gunakan IP laptop yang terhubung pada jaringan yang sama:

```text
http://IP-LAPTOP/papua_youth_career_api
```

Contoh menjalankan aplikasi dengan API khusus:

```bash
flutter run --dart-define=API_BASE_URL=http://IP-LAPTOP/papua_youth_career_api
```

## 10. Menjalankan Aplikasi

Langkah menjalankan aplikasi:

1. Jalankan XAMPP.
2. Start Apache dan MySQL.
3. Pastikan API dapat diakses melalui browser.
4. Pastikan alamat API di `lib/app_config.dart` sesuai.
5. Jalankan perintah:

```bash
flutter pub get
flutter run
```

Jika ingin menjalankan pada device tertentu:

```bash
flutter devices
flutter run -d NAMA_DEVICE
```

## 11. Membuat Akun Admin

Secara default, user yang registrasi akan menjadi user biasa. Untuk menjadikan user sebagai admin, ubah role pada database MySQL.

Contoh SQL:

```sql
UPDATE users
SET role = 'admin'
WHERE email = 'email_admin_anda@gmail.com';
```

Setelah role diubah, logout dari aplikasi lalu login kembali. Sistem akan membaca role dari database dan mengarahkan akun tersebut ke halaman Admin.

## 12. Panduan Penggunaan User

### 12.1 Registrasi

1. Buka aplikasi.
2. Pilih `Sign Up`.
3. Isi data registrasi.
4. Tekan tombol `Sign Up`.
5. Buka email dan lakukan verifikasi.
6. Kembali ke aplikasi dan login.

### 12.2 Login

1. Masukkan email dan password.
2. Tekan tombol `Login`.
3. Jika berhasil, user masuk ke halaman Beranda.

### 12.3 Mengelola Profil

1. Buka menu `Profil`.
2. Ubah data yang diperlukan.
3. Tekan `Simpan Profil`.

### 12.4 Mendaftar Lowongan

1. Buka menu `Lowongan`.
2. Cari atau pilih lowongan.
3. Buka detail lowongan.
4. Tekan `Daftar Lowongan`.
5. Lihat status pendaftaran pada menu `Lamaran`.

## 13. Panduan Penggunaan Admin

### 13.1 Dashboard Admin

Admin dapat melihat ringkasan jumlah user, lowongan, lamaran, dan lamaran diterima.

### 13.2 Kelola Lowongan

Admin dapat:

- menambah lowongan,
- mengedit lowongan,
- menghapus lowongan,
- mencari lowongan.

### 13.3 Kelola Lamaran

Admin dapat:

- melihat seluruh lamaran,
- memfilter berdasarkan status,
- menerima lamaran,
- menolak lamaran,
- mengembalikan status ke pending,
- menghubungi pelamar via WhatsApp.

### 13.4 Cetak Laporan

Pada halaman `Kelola Lamaran`, tersedia:

- `Cetak Pendaftaran`
- `Cetak Status`

Saat tombol ditekan, aplikasi membuka halaman cetak dari API. Jika halaman cetak tampil sebagai kode HTML mentah, pastikan file endpoint API sudah terpasang ulang ke folder XAMPP dan browser tidak membuka cache lama.

Endpoint cetak:

```text
applications/print_registration.php
applications/print_status.php
```

### 13.5 Kelola User

Admin dapat melihat daftar user, mencari user, dan menghubungi user melalui WhatsApp jika nomor telepon tersedia.

### 13.6 Kelola Master

Admin dapat mengelola:

- data kabupaten,
- data spesifikasi karir.

## 14. Pengujian Fitur

Checklist pengujian user:

- Registrasi akun baru.
- Verifikasi email.
- Login user.
- Edit profil.
- Cari lowongan.
- Buka detail lowongan.
- Daftar lowongan.
- Cek riwayat lamaran.
- Logout.

Checklist pengujian admin:

- Login admin.
- Buka dashboard.
- Tambah lowongan.
- Edit lowongan.
- Hapus lowongan.
- Ubah status lamaran.
- Cetak laporan pendaftaran.
- Cetak laporan status lamaran.
- Kelola data user.
- Kelola kabupaten.
- Kelola spesifikasi karir.
- Logout.

## 15. Troubleshooting

### 15.1 Login Gagal

Kemungkinan penyebab:

- Email atau password salah.
- Email belum diverifikasi.
- Firebase belum dikonfigurasi.
- Koneksi internet bermasalah.

Solusi:

- Pastikan email dan password benar.
- Cek inbox email untuk verifikasi.
- Pastikan Firebase Authentication aktif.

### 15.2 API Tidak Terhubung

Kemungkinan penyebab:

- Apache belum berjalan.
- Alamat API salah.
- HP dan laptop tidak berada pada jaringan yang sama.
- Firewall memblokir koneksi.

Solusi:

- Jalankan Apache dan MySQL di XAMPP.
- Sesuaikan `API_BASE_URL`.
- Gunakan IP laptop yang benar.

### 15.3 Cetak Laporan Tampil Kode HTML

Kemungkinan penyebab:

- Endpoint cetak belum dipasang ulang ke XAMPP.
- Browser masih membuka cache lama.
- Header `Content-Type: text/html` belum terbaca.

Solusi:

1. Pasang ulang API:

```powershell
powershell -ExecutionPolicy Bypass -File install_api_security_patch.ps1
```

2. Tutup tab cetak lama.
3. Hot restart aplikasi.
4. Coba cetak ulang.

### 15.4 Akses Admin Ditolak

Kemungkinan penyebab:

- Role user belum diubah menjadi `admin`.
- Token Firebase tidak valid.
- Email admin belum diverifikasi.

Solusi:

- Ubah role di database.
- Logout dan login ulang.
- Pastikan email sudah diverifikasi.

## 16. Kesimpulan Implementasi

Aplikasi Karir Muda Papua sudah memiliki alur lengkap dari registrasi user, login, pengelolaan profil, pencarian lowongan, pendaftaran lowongan, pemantauan status lamaran, hingga pengelolaan data oleh admin. Dengan integrasi Firebase Authentication, API PHP, dan MySQL, aplikasi ini dapat digunakan sebagai platform digital untuk mendukung pendataan dan pusat karir anak muda Papua secara lebih terstruktur.
