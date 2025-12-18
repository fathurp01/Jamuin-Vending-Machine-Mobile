# Flow Transaksi Jamuin

## Overview
Aplikasi Jamuin sekarang mendukung dua alur transaksi utama yang berbeda, memungkinkan user untuk memilih mesin terlebih dahulu atau memilih produk terlebih dahulu.

## Alur 1: Pilih Mesin Dulu → Pilih Produk

### Langkah-langkah:
1. **Di Home Dashboard**: User menekan tombol "Cari Mesin"
2. **Halaman Map**:
   - Tampilan 3/4 layar bagian atas: Peta dengan marker mesin
   - Tampilan 1/4 layar bagian bawah: Daftar mesin terdekat (berdasarkan GPS)
   - Daftar mesin bisa di-hide dengan menekan/drag indikator di atasnya
   - Ketika daftar di-hide, muncul floating button "Lihat Daftar Mesin" untuk membuka kembali
   - User dapat memilih mesin dengan:
     - Menekan marker di peta, atau
     - Menekan item di daftar mesin
3. **Setelah Memilih Mesin**: 
   - Mesin tersimpan di session
   - SnackBar muncul menampilkan "Terpilih: [Nama Mesin]"
   - User tetap di halaman map atau kembali ke dashboard
4. **Pilih Produk**: User dapat langsung ke halaman produk dan memilih item
5. **Checkout**: Mesin sudah terpilih, user langsung bisa checkout

## Alur 2: Pilih Produk Dulu → Pilih Mesin

### Langkah-langkah:
1. **Di Home Dashboard**: User menekan tombol "Lihat Produk"
2. **Halaman Produk**: 
   - User melihat dan memilih produk yang diinginkan
   - Produk ditambahkan ke keranjang
   - Ketika ada item di keranjang, muncul tombol "Bayar Sekarang" di bottom navigation
3. **Tekan "Bayar Sekarang"**: User diarahkan ke halaman Keranjang (Cart)
4. **Di Halaman Keranjang**:
   - Bagian atas menampilkan card untuk memilih mesin (belum dipilih)
   - Card mesin bersifat clickable dengan indikator chevron
   - User menekan card mesin
5. **Halaman Map** (dengan parameter `returnToCart=true`):
   - Tampilan sama seperti Alur 1 (3/4 map + 1/4 list)
   - User memilih mesin dari peta atau daftar
6. **Setelah Memilih Mesin**: 
   - User otomatis dikembalikan ke halaman Keranjang
   - Mesin sudah terpilih, card mesin menampilkan nama mesin
7. **Checkout**: User dapat melanjutkan proses checkout

## Fitur Halaman Map

### Layout
- **3/4 Layar Bagian Atas**: Peta menggunakan MapLibre dengan style MapTiler
- **1/4 Layar Bagian Bawah**: Daftar mesin terdekat yang scrollable

### Fitur Map
- GPS/Location tracking: Enabled untuk menampilkan posisi user
- Compass: Enabled untuk orientasi peta
- Rotate gestures: Enabled
- Tilt gestures: Disabled
- Markers: Setiap mesin ditampilkan dengan icon marker dan label nama

### Daftar Mesin
- Menampilkan informasi:
  - Nama mesin
  - Lokasi mesin
  - Status realtime (jika tersedia)
  - Temperature dan Humidity (jika tersedia)
- Sorted berdasarkan jarak terdekat dari lokasi user
- Setiap item clickable untuk memilih mesin

### Toggle Daftar
- Drag handle di bagian atas daftar untuk show/hide
- Animasi smooth dengan duration 300ms
- Ketika di-hide: Floating Action Button muncul untuk membuka kembali
- Ketika di-show: FAB tersembunyi

## Perubahan pada Komponen

### 1. MapScreen (`lib/src/features/map/presentation/map_screen.dart`)
- Menambahkan parameter `returnToCart` untuk mengatur navigation setelah memilih mesin
- Menambahkan state `_showMachineList` untuk toggle daftar
- Mengubah layout menjadi 3/4 map + 1/4 list dengan AnimatedPositioned
- Menambahkan FAB untuk toggle daftar ketika hidden
- Mengaktifkan GPS (`myLocationEnabled: true`)

### 2. CartScreen (`lib/src/features/cart/presentation/cart_screen.dart`)
- Mengubah card mesin menjadi clickable
- Menambahkan navigasi ke `/app/map?returnToCart=true`
- Meningkatkan UX dengan styling yang lebih jelas untuk interaksi

### 3. ProductListScreen (`lib/src/features/products/presentation/product_list_screen.dart`)
- Menambahkan bottom navigation bar "Bayar Sekarang" ketika ada item di cart
- Menampilkan badge jumlah item di tombol
- Mengubah padding bottom ListView ketika tombol muncul

### 4. Router (`lib/src/app/router.dart`)
- Menambahkan query parameter handling untuk `/app/map`
- Meneruskan parameter `returnToCart` ke MapScreen

## Implementasi Teknis

### Query Parameters
```dart
// Di CartScreen untuk navigasi ke map
context.push('/app/map?returnToCart=true')

// Di Router untuk parsing parameter
final returnToCart = state.uri.queryParameters['returnToCart'] == 'true';
return MapScreen(returnToCart: returnToCart);
```

### State Management
- Menggunakan `setState()` untuk local state `_showMachineList`
- Session state untuk menyimpan mesin terpilih (menggunakan Riverpod)

### Navigation
- `context.push()`: Navigasi dengan history (bisa back)
- `context.pop()`: Kembali ke halaman sebelumnya
- `context.go()`: Navigasi replace (tidak bisa back ke halaman sebelumnya)

## User Experience

### Flow Mesin Dulu
**Pro:**
- User tahu pasti produk tersedia di mesin yang dipilih
- Stok produk akurat karena mesin sudah dipilih

**Cons:**
- Harus memilih mesin terlebih dahulu sebelum browsing produk

### Flow Produk Dulu
**Pro:**
- User bisa browsing produk tanpa harus memilih mesin dulu
- Lebih fleksibel untuk eksplorasi

**Cons:**
- Stok produk belum pasti sampai mesin dipilih
- Membutuhkan extra step untuk memilih mesin di cart

## Catatan Implementasi

1. **GPS Permission**: Pastikan aplikasi memiliki permission untuk mengakses lokasi user
2. **API Keys**: MapTiler API key harus dikonfigurasi di `PublicApis.maptilerStreetsV4StyleUrl`
3. **Realtime Updates**: Data mesin diupdate secara realtime melalui WebSocket
4. **Koordinat Mesin**: Backend harus menyediakan latitude dan longitude untuk setiap mesin

## Testing

### Skenario Test:
1. **Test Alur Mesin Dulu**:
   - Klik "Cari Mesin" di dashboard
   - Verifikasi peta muncul dengan markers
   - Pilih mesin dari peta atau list
   - Verifikasi mesin tersimpan
   - Lanjut ke produk dan checkout

2. **Test Alur Produk Dulu**:
   - Klik "Lihat Produk" di dashboard
   - Tambahkan produk ke cart
   - Klik "Bayar Sekarang"
   - Klik card mesin di cart
   - Pilih mesin dari map
   - Verifikasi kembali ke cart dengan mesin terpilih

3. **Test Toggle Daftar**:
   - Di halaman map, drag/tap untuk hide daftar
   - Verifikasi FAB muncul
   - Tap FAB untuk show daftar kembali

4. **Test GPS**:
   - Verifikasi lokasi user muncul di peta
   - Verifikasi daftar mesin sorted berdasarkan jarak
