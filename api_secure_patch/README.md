Security patch untuk `C:\xampp\htdocs\papua_youth_career_api`.

Cara pakai:

1. Salin isi folder ini ke `C:\xampp\htdocs\papua_youth_career_api`.
2. Jika diminta replace file lama, pilih replace.
3. Pastikan PHP mengaktifkan ekstensi `openssl`.
4. Pastikan komputer bisa mengakses internet saat pertama kali API memverifikasi token Firebase, karena API mengambil public certificate Google.

Hak akses setelah patch:

- Endpoint publik: daftar lowongan, detail lowongan, daftar kabupaten, daftar spesifikasi karir.
- Endpoint user: profil sendiri dan lamaran sendiri harus memakai token Firebase user yang sama.
- Endpoint admin: statistik admin, daftar semua user, laporan lamaran, ubah status lamaran, tambah/edit/hapus lowongan, tambah kabupaten, tambah spesifikasi karir.
- Role admin tetap dibaca dari tabel `users.role`.
