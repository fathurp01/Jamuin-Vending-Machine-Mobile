# backend_update_request.md

Dokumen ini berisi daftar perubahan yang *mungkin diperlukan* di `backend_jamuin` agar pengalaman mobile (jamuin) bisa 100% optimal. 

Catatan: sesuai instruksi, mobile sudah menyesuaikan backend dan **tidak mengubah backend**. File ini hanya sebagai request/opsional.

## 1) Koordinat mesin (lat/lng) untuk map marker

**Masalah**
- Endpoint `/machines` dan `/machines/online` tidak menyediakan `lat`/`lng`.
- Akibatnya, tampilan map di mobile otomatis fallback menjadi list selection (tanpa marker).

**Request**
- Tambahkan field `lat` dan `lng` pada entity Machine.
- Sertakan field tersebut pada respons API mesin.

**Acceptance**
- Mobile menerima `lat`/`lng` dan dapat menampilkan marker per mesin.

## 2) Proteksi endpoint sensitif (security)

**Masalah**
- `POST /payments/cancel/:orderId` tidak menggunakan `JwtAuthGuard`.
- `GET /payments/transactions` (admin list) dipakai di mobile admin, tetapi perlu dipastikan admin-only.
- `GET /machines/dashboard` dipakai di admin dashboard mobile, perlu dipastikan admin-only.
- `PATCH /products/:id` (ubah `stok`) dipakai dari mobile admin, perlu dipastikan admin-only.

**Request**
- Tambahkan `JwtAuthGuard` untuk endpoint cancel dan validasi bahwa order milik user yang sama (atau role admin).
- Tambahkan guard admin untuk endpoint berikut:
  - `GET /payments/transactions`
  - `GET /machines/dashboard`
  - `PATCH /products/:id` (minimal saat update field `stok`)
- Validasi server-side: user biasa tidak boleh update stok, dan tidak boleh melihat transaksi global.

**Acceptance**
- User biasa hanya bisa cancel order miliknya.
- Endpoint admin tidak bisa diakses user biasa.

## 3) Konsistensi role admin di JWT & response login

**Masalah**
- Mobile menentukan akses admin dari `user.role == 'admin'` pada response login/register.
- Backend guard admin umumnya mengambil `req.user.role` dari JWT payload.

**Request**
- Pastikan `POST /auth/login` dan `POST /auth/register` selalu mengembalikan `user.role`.
- Pastikan JWT payload memuat `role` (misal `{ sub, email, role }`) sehingga admin guard konsisten.

**Acceptance**
- Setelah login admin, mobile bisa akses endpoint admin (transactions/dashboard/stock patch).
- User biasa tetap ditolak oleh admin guard.

## 4) Stok per-mesin (opsional)

**Masalah**
- Backend saat ini menggunakan stok global product (`stok`).
- Jika kebutuhan bisnis mengharuskan stok berbeda per mesin, maka perlu model stok per-mesin.

**Request (opsional)**
- Tambahkan endpoint stok per mesin, misalnya:
  - `GET /machines/:id/inventory`
  - `PATCH /machines/:id/inventory` (admin)

**Acceptance**
- Mobile bisa melakukan validasi stok berdasarkan mesin terpilih.

## 5) WebSocket auth (opsional)

**Masalah**
- WebSocket gateway saat ini terbuka (CORS `origin: *`) dan tidak ada auth.

**Request (opsional)**
- Tambahkan auth token handshake pada socket.io bila ingin restrict akses.

**Catatan kompatibilitas mobile**
- Mobile saat ini listen event: `connected`, `temperature-update`, `status-update`, `heartbeat`.
- Mobile tidak membutuhkan MQTT langsung; realtime di mobile via socket.io.

**Acceptance**
- Mobile bisa connect dengan token, server menolak yang tidak valid.

## 6) Loyalty points / rewards / promo (opsional)

**Masalah**
- UI mobile menampilkan `points` (contoh default 120) dan card promo/reward, tetapi backend belum menyediakan API untuk:
  - mengambil points user yang real
  - menambah/mengurangi points dari transaksi
  - daftar promo/reward dan penukaran

**Request (opsional)**
- Tambahkan endpoint user profile yang konsisten untuk mobile, misalnya:
  - `GET /users/me` (JWT) → `{ id, name, email, phone, role, points }`
- Tambahkan aturan bisnis points (opsional):
  - points bertambah setelah transaksi `settlement/success`
  - points berkurang saat redeem reward
- Tambahkan endpoint promo/reward (opsional), misalnya:
  - `GET /promos` / `GET /rewards`
  - `POST /rewards/:id/redeem` (JWT)

**Acceptance**
- Mobile bisa menampilkan points yang real dari backend.
- Promo/reward tidak lagi statis (bila fitur ini memang ingin diaktifkan).
