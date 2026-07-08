4.4. Rancangan Prototype/Tampilan
Rancangan prototype atau tampilan sistem dibuat untuk menggambarkan bentuk antarmuka aplikasi yang akan digunakan oleh user dan admin. Prototype ini dirancang agar pengguna dapat memahami alur penggunaan aplikasi dengan mudah, mulai dari registrasi, login, pencarian lowongan, pendaftaran lowongan, melihat status lamaran, hingga pengelolaan data oleh admin.
Tampilan aplikasi Karir Muda Papua dibuat menggunakan Flutter dengan desain sederhana, responsif, dan mudah digunakan. Warna utama yang digunakan adalah hijau kebiruan sebagai identitas utama aplikasi, dipadukan dengan warna putih dan abu-abu muda agar tampilan tetap bersih dan nyaman dibaca. Setiap halaman dilengkapi dengan ikon dan navigasi bawah agar user dapat berpindah menu dengan mudah.
4.4.1. Rancangan Halaman Login
Halaman login digunakan oleh user dan admin untuk masuk ke aplikasi. Pengguna harus memasukkan email dan kata sandi. Sistem akan memeriksa akun melalui Firebase Authentication. Jika email belum diverifikasi, user tidak dapat masuk ke halaman utama.
Komponen utama halaman login:
Input email.
Input kata sandi.
Tombol masuk.
Tombol menuju halaman registrasi.
Tujuan rancangan halaman login adalah memastikan hanya pengguna yang memiliki akun valid dan email terverifikasi yang dapat masuk ke aplikasi.
4.4.2. Rancangan Halaman Registrasi
Halaman registrasi digunakan oleh user untuk membuat akun baru. User harus mengisi nama lengkap, asal kabupaten, spesifikasi karir, email, dan kata sandi. Setelah registrasi berhasil, sistem mengirim email verifikasi ke alamat email user.
Komponen utama halaman registrasi:
Input nama lengkap.
Dropdown asal kabupaten.
Dropdown spesifikasi karir atau keahlian.
Input email.
Input kata sandi.
Tombol daftar.
Pada rancangan ini, data asal kabupaten dan spesifikasi karir menggunakan dropdown yang bersumber dari data master pada database. Hal ini bertujuan agar data yang masuk lebih konsisten dan mudah dikelola oleh admin.
4.4.3. Rancangan Halaman Beranda User
Halaman beranda user menampilkan ringkasan profil pengguna, seperti nama, kabupaten, dan bidang karir. Halaman ini menjadi tampilan awal setelah user berhasil login.
Komponen utama halaman beranda user:
Informasi nama user.
Informasi asal kabupaten.
Informasi bidang karir.
Navigasi ke lowongan, lamaran, dan profil.
Beranda user juga berfungsi sebagai halaman ringkasan yang menunjukkan bahwa akun user telah berhasil masuk dan profil telah tersinkron dengan database.
4.4.4. Rancangan Halaman Lowongan
Halaman lowongan digunakan untuk menampilkan daftar lowongan pekerjaan. User dapat melakukan pencarian lowongan berdasarkan kata kunci tertentu dan membuka detail lowongan.
Komponen utama halaman lowongan:
Kolom pencarian lowongan.
Daftar lowongan.
Detail judul, perusahaan, lokasi, dan kategori.
Tombol untuk membuka detail lowongan.
Rancangan halaman lowongan dibuat agar user dapat mencari informasi pekerjaan sesuai minat dan spesifikasi karir yang dimiliki.
4.4.5. Rancangan Halaman Detail Lowongan
Halaman detail lowongan menampilkan informasi lengkap mengenai lowongan pekerjaan. User dapat melakukan pendaftaran lowongan melalui tombol daftar lowongan.
Komponen utama halaman detail lowongan:
Judul lowongan.
Nama perusahaan.
Lokasi lowongan.
Kategori lowongan.
Deadline pendaftaran.
Deskripsi lowongan.
Persyaratan lowongan.
Tombol daftar lowongan.
Pada halaman ini user dapat membaca informasi lowongan secara lengkap sebelum melakukan pendaftaran. Jika user menekan tombol daftar lowongan, maka data lamaran akan dikirim ke database dengan status awal pending.
4.4.6. Rancangan Halaman Lamaran User
Halaman lamaran user digunakan untuk menampilkan daftar lowongan yang telah didaftari oleh user. User dapat melihat status lamaran, yaitu pending, accepted, atau rejected.
Komponen utama halaman lamaran user:
Daftar lamaran user.
Judul lowongan.
Nama perusahaan.
Status lamaran.
Rancangan halaman lamaran membantu user memantau hasil pendaftaran lowongan. Status lamaran akan berubah sesuai keputusan admin.
4.4.7. Rancangan Halaman Profil User
Halaman profil digunakan oleh user untuk mengubah data pribadi. User hanya dapat mengubah profil miliknya sendiri.
Komponen utama halaman profil user:
Input nama lengkap.
Dropdown asal kabupaten.
Input nomor telepon.
Dropdown spesifikasi karir.
Tombol simpan profil.
Nomor telepon pada halaman profil penting untuk diisi karena dapat digunakan admin untuk menghubungi user apabila lamaran diterima.
4.4.8. Rancangan Halaman Admin
Halaman admin hanya dapat diakses oleh pengguna dengan role admin. Halaman ini digunakan untuk mengelola data sistem dan melihat laporan pendaftaran lowongan.
Komponen utama halaman admin:
Statistik jumlah user, lowongan, lamaran, dan lamaran diterima.
Data master kabupaten.
Data master spesifikasi karir.
Data lowongan.
Data user.
Laporan lamaran.
Tombol ubah status lamaran.
Pada rancangan halaman admin, admin dapat melihat data user beserta nomor telepon, sehingga apabila ada lamaran yang diterima admin dapat menghubungi user secara langsung. Admin juga dapat mengubah status lamaran menjadi pending, accepted, atau rejected.
4.4.9. Rancangan Navigasi Aplikasi
Navigasi aplikasi menggunakan menu bawah atau bottom navigation. Pada user biasa, menu yang tersedia adalah Beranda, Lowongan, Lamaran, dan Profil. Pada admin, sistem menampilkan tambahan menu Admin. Dengan rancangan ini, menu admin hanya dapat diakses oleh pengguna yang memiliki role admin.
Struktur navigasi user:
Beranda.
Lowongan.
Lamaran.
Profil.
Struktur navigasi admin:
Beranda.
Lowongan.
Lamaran.
Admin.
Profil.