# 1. CHECKLIST KESESUAIAN SOAL & PETUNJUK PENGERJAAN (PALING ATAS)

## Checklist SOAL (Poin 1–3)

- ✅ **SOAL 1** — Aplikasi berbasis **client–admin** dan memiliki **operasi perhitungan**.
  - Bukti: terdapat mode **Customer** dan **Admin** (role-based) serta perhitungan keranjang (subtotal, biaya layanan, pajak 11%, total).
- ✅ **SOAL 2** — Menggunakan **sumber data publik (Public API)** pada salah satu sisi.
  - Bukti: integrasi **MapTiler** (Public API) untuk tampilan peta (MapLibre) dan konfigurasi URL public API.
- ✅ **SOAL 3** — **Alamat API** dicantumkan pada halaman **About/Tentang** aplikasi.
  - Bukti: halaman **About** menampilkan URL Public API MapTiler (universal format + vector style JSON).

## Checklist PETUNJUK PENGERJAAN (Poin a–f)

- ❌ **a. Video Hasil Pengembangan Aplikasi** ditampilkan/diuraikan.
  - Catatan: belum ada link video pada README (isi di Bagian 9).
- ❌ **b. Video disampaikan lewat YouTube**.
  - Catatan: link YouTube belum dicantumkan.
- ❌ **c. Konten video sesuai ketentuan (judul aplikasi & tim pengembang)**.
  - Catatan: belum dapat diverifikasi sebelum link video tersedia.
- ❌ **d. Link YouTube dikirim melalui e-learning (perwakilan kelompok)**.
  - Catatan: proses pengiriman e-learning berada di luar repository, belum dapat diverifikasi dari dokumen ini.
- ✅ **e. Kesiapan pengembangan lanjutan (SubCPMK 5 & 6)**.
  - Bukti: struktur modular (fitur terpisah) dan roadmap/rencana pengembangan lanjutan dicantumkan pada Bagian 10.
- ❌ **f. Nilai tiap anggota adalah nilai tunggal kelompok; pastikan anggota benar-benar berkontribusi**.
  - Catatan: kontribusi individu tidak dapat dibuktikan hanya dari README; perlu verifikasi internal tim.

---

# 2. Judul Aplikasi dan Branding

**Jamuin** — Aplikasi Mobile Vending Machine untuk pemesanan jamu.

Tagline (opsional): _“Order jamu dari vending machine terdekat.”_

> Catatan bahasa: Dokumentasi ini berbahasa Indonesia. Bahasa UI mengikuti implementasi aplikasi saat ini (terdapat teks English dan Indonesia).

# 3. Identitas Mahasiswa / Tim Pengembang

Isi sesuai anggota kelompok:

- Ketua/Perwakilan: **[Nama]** — **[NRP/NPM]**
- Anggota 1: **[Nama]** — **[NRP/NPM]**
- Anggota 2: **[Nama]** — **[NRP/NPM]**
- Kelas: **[Kelas]**
- Mata Kuliah/Dosen: **[Nama MK / Dosen]**
- Tahun/Semester: **2025 / [Ganjil|Genap]**

# 4. Deskripsi Singkat Aplikasi

Jamuin adalah aplikasi pemesanan jamu berbasis mobile dengan dua peran:

- **Client/Customer**: memilih mesin, memilih produk, mengelola keranjang, dan melakukan checkout.
- **Admin**: melihat ringkasan operasional/penjualan, mengelola stok, dan memantau transaksi.

# 5. Tujuan Pengembangan dan Pembelajaran

- Menerapkan konsep aplikasi **client–admin** pada kasus nyata (pemesanan dari vending machine).
- Menerapkan **operasi perhitungan** dalam alur transaksi (subtotal, pajak, total).
- Menerapkan integrasi **sumber data publik** (Public API) dan mendokumentasikan alamat API pada halaman About.
- Melatih praktik dokumentasi teknis akademik (README terstruktur + bukti pemenuhan soal).

# 6. Deskripsi Arsitektur Aplikasi Client–Admin

Arsitektur tingkat tinggi:

- **Mobile App (Flutter)** sebagai client dengan routing dan state management.
- **Role-based flow**:
  - **Customer** diarahkan ke fitur pemesanan.
  - **Admin** diarahkan ke dashboard admin.
- **Backend (opsional/pendukung)**: pada kode terdapat konfigurasi base URL dan pemanggilan endpoint REST.

Catatan penting (konsistensi dokumentasi internal aplikasi):

- Pada halaman About, terdapat teks “Frontend-only (no backend)”. Namun pada kode juga terdapat konfigurasi dan pemanggilan API (Dio) yang menunjukkan aplikasi disiapkan/diintegrasikan dengan backend.

# 7. Fitur Aplikasi

## Fitur Client

- Registrasi & login.
- Menelusuri produk jamu.
- Memilih **mesin** (melalui daftar/peta) sebelum checkout.
- Mengelola keranjang: tambah/hapus item, ubah kuantitas.
- Checkout dan melihat status transaksi.

## Fitur Admin

- Dashboard ringkas: ringkasan penjualan dan status mesin.
- Manajemen stok produk (update stok).
- Melihat daftar transaksi.

## Operasi Perhitungan yang Digunakan

Contoh operasi perhitungan yang diimplementasikan pada fitur keranjang:

- **Line total per item**: `harga × jumlah`
- **Subtotal**: jumlah seluruh line total
- **Biaya layanan**: `2000` (jika subtotal > 0)
- **Pajak**: `11% × subtotal` (dibulatkan)
- **Total**: `subtotal + biaya layanan + pajak`

# 8. Integrasi Sumber Data Publik

## Nama API

- **MapTiler** (Public API) — digunakan sebagai sumber style/tiles peta untuk tampilan MapLibre.

## Alamat URL API (WAJIB ADA)

- Universal format (sesuai yang ditampilkan di halaman About):
  - `https://api.maptiler.com/{METHOD}/{QUERY}.json?{PARAMS}&key=YOUR_MAPTILER_API_KEY_HERE`
- Vector style JSON (digunakan pada layar peta dan ditampilkan di About):
  - `https://api.maptiler.com/maps/streets-v4/style.json?key=pcH5SSPJjdDvJ5kGeeYL`

## Digunakan di sisi Client atau Admin

- **Client (Customer)**: layar peta untuk membantu memilih mesin (fitur pemilihan mesin).

# 9. Video Hasil Pengembangan Aplikasi

## Link YouTube

- **[ISI LINK YOUTUBE DI SINI]**: `https://youtu.be/[ID_VIDEO]`

## Checklist ketentuan video

- [ ] Video diawali dengan menampilkan **judul aplikasi**.
- [ ] Video menyampaikan **tim pengembang** (NRP/NPM + nama mahasiswa).

> Setelah link video diisi, checklist pada Bagian 1 poin a–c dan b dapat diperbarui menjadi ✅ (jika memang sudah sesuai).

# 10. Kesiapan Pengembangan Lanjutan (SubCPMK 5 dan 6)

Rencana pengembangan lanjutan (template):

- SubCPMK 5: **[fitur lanjutan 1]** (contoh: riwayat transaksi lebih detail, notifikasi status pesanan, dsb.).
- SubCPMK 6: **[fitur lanjutan 2]** (contoh: loyalty/points yang konsisten, manajemen mesin lebih lengkap, dsb.).

Alasan kesiapan:

- Struktur kode modular per fitur (auth, products, cart, checkout, admin, about, map) memudahkan penambahan fitur tanpa mengganggu modul lain.

# 11. Cara Menjalankan Aplikasi

Prasyarat:

- Flutter SDK terpasang.
- Emulator Android / device fisik.

Langkah menjalankan (minimum):

1. Masuk ke folder `jamuin`.
2. Jalankan:
   - `flutter pub get`
   - `flutter run`

Konfigurasi (opsional):

- Base URL backend dapat dikonfigurasi melalui environment variable `BACKEND_BASE_URL` (default ada di konfigurasi internal aplikasi).

# 12. Catatan Penilaian Kelompok

- Nilai per anggota bersifat **nilai tunggal kelompok**.
- Pastikan daftar nama pada Bagian 3 adalah anggota yang benar-benar berkontribusi.
- Bukti pembagian tugas (opsional, direkomendasikan): **[isi ringkas peran tiap anggota]**.

# 13. Lisensi

Proyek ini dibuat untuk kebutuhan akademik. Lisensi belum ditetapkan pada repository ini.

# 14. Tentang Developer / Tim

Tuliskan ringkasan singkat tim:

- Bidang kontribusi (contoh): UI/UX, integrasi API, state management, dokumentasi, pengujian.
- Kontak (opsional): email/username.
