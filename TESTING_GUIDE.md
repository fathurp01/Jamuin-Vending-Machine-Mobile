# Testing Guide - Transaction Flow

## Prerequisites

Sebelum testing, pastikan:
1. ✅ Backend server running dan accessible
2. ✅ MapTiler API key sudah dikonfigurasi
3. ✅ Device/Emulator memiliki GPS enabled
4. ✅ Permission lokasi sudah di-grant
5. ✅ Login sebagai user (bukan admin)

## Test Case 1: Flow Mesin Dulu

### Steps:
1. **Login ke aplikasi**
   - Expected: Masuk ke home dashboard

2. **Klik tombol "Cari Mesin"** di dashboard
   - Expected: Navigasi ke halaman map
   - Verify: Peta muncul dengan markers mesin
   - Verify: Daftar mesin muncul di bagian bawah (1/4 layar)
   - Verify: GPS location user muncul di peta (blue dot)

3. **Test Toggle Daftar Mesin**
   - Action: Drag handle di bagian atas daftar ke bawah
   - Expected: Daftar mesin hidden dengan animasi smooth
   - Verify: FAB "Lihat Daftar Mesin" muncul di bottom center
   
   - Action: Klik FAB
   - Expected: Daftar mesin muncul kembali
   - Verify: FAB hilang

4. **Pilih Mesin dari Daftar**
   - Action: Tap salah satu mesin di daftar
   - Expected: SnackBar muncul "Terpilih: [Nama Mesin]"
   - Verify: Mesin tersimpan (cek di session)

5. **Pilih Mesin dari Peta**
   - Action: Tap marker mesin di peta
   - Expected: SnackBar muncul "Terpilih: [Nama Mesin]"
   - Verify: Mesin tersimpan

6. **Navigasi ke Produk**
   - Action: Back ke dashboard, klik "Lihat Produk"
   - Expected: Halaman product list muncul
   - Verify: Daftar produk ditampilkan

7. **Tambah Produk ke Cart**
   - Action: Klik salah satu produk → Klik "Tambah ke keranjang"
   - Expected: Produk masuk cart
   - Verify: Badge cart counter bertambah

8. **Checkout**
   - Action: Navigasi ke cart
   - Expected: Card mesin menampilkan nama mesin yang sudah dipilih
   - Verify: Tombol "Checkout" enabled (tidak disabled)

## Test Case 2: Flow Produk Dulu

### Steps:
1. **Login ke aplikasi**
   - Expected: Masuk ke home dashboard

2. **Klik tombol "Lihat Produk"** di dashboard
   - Expected: Navigasi ke halaman product list
   - Verify: Daftar produk muncul
   - Verify: Tidak ada tombol "Bayar Sekarang" di bottom

3. **Pilih dan Tambah Produk**
   - Action: Klik produk → Detail page → "Tambah ke keranjang"
   - Expected: Produk masuk cart
   - Verify: Kembali ke product list
   - Verify: Tombol "Bayar Sekarang" muncul di bottom
   - Verify: Badge menampilkan jumlah item (contoh: 🛍️ 1)

4. **Tambah Produk Lagi**
   - Action: Tambah produk lain ke cart
   - Expected: Badge counter bertambah
   - Verify: Tombol "Bayar Sekarang" tetap ada

5. **Klik "Bayar Sekarang"**
   - Expected: Navigasi ke halaman cart
   - Verify: Daftar item di cart muncul
   - Verify: Card mesin menampilkan "Pilih mesin sebelum checkout"
   - Verify: Tombol "Checkout" disabled

6. **Klik Card Mesin**
   - Action: Tap pada card mesin
   - Expected: Navigasi ke halaman map
   - Verify: Peta muncul dengan layout 3/4 + 1/4
   - Verify: URL contains `?returnToCart=true`

7. **Pilih Mesin di Map**
   - Action: Tap mesin dari daftar atau peta
   - Expected: Auto-navigate kembali ke halaman cart
   - Verify: Card mesin sekarang menampilkan nama mesin
   - Verify: Tombol "Checkout" enabled

8. **Checkout**
   - Action: Klik tombol "Checkout"
   - Expected: Navigasi ke checkout page
   - Verify: Detail transaksi muncul

## Test Case 3: Toggle Daftar Mesin

### Steps:
1. **Buka Map Screen**
   - Navigate ke `/app/map`

2. **Initial State**
   - Verify: Daftar mesin visible (1/4 layar)
   - Verify: Map visible (3/4 layar)
   - Verify: FAB tidak muncul

3. **Hide Daftar - Method 1 (Drag Handle)**
   - Action: Tap atau drag handle di atas daftar
   - Expected: Daftar slide down dengan animasi
   - Verify: Map expands to fullscreen
   - Verify: FAB muncul di bottom center

4. **Show Daftar via FAB**
   - Action: Tap FAB "Lihat Daftar Mesin"
   - Expected: Daftar slide up dengan animasi
   - Verify: Map shrinks to 3/4
   - Verify: FAB hilang

5. **Rapid Toggle Test**
   - Action: Quickly tap handle beberapa kali
   - Expected: Animasi smooth tanpa glitch
   - Verify: State consistent

## Test Case 4: Navigation Flow

### Steps:
1. **From Dashboard → Map → Dashboard**
   - Action: Dashboard → "Cari Mesin" → Back
   - Expected: Kembali ke dashboard
   - Verify: Tidak ada navigation stack issue

2. **From Product → Cart → Map → Cart**
   - Action: Product List → Add to cart → "Bayar Sekarang" → Cart → Pilih Mesin → Map → Select machine
   - Expected: Auto back to cart
   - Verify: Machine selected
   - Verify: Can proceed to checkout

3. **Back Button Test**
   - From Map: Back button should go to previous screen
   - From Cart: Back button should keep items
   - Verify: No data loss

## Test Case 5: Edge Cases

### Test Empty States:
1. **No Machines Available**
   - Scenario: Backend returns empty machine list
   - Expected: Fallback list view with message
   - Verify: No crash

2. **No GPS Permission**
   - Scenario: Location permission denied
   - Expected: Map still works, no GPS dot
   - Verify: Machine list still functional

3. **No Coordinates for Machines**
   - Scenario: Backend doesn't provide lat/lng
   - Expected: Fallback to list-only view
   - Verify: Can still select machine

### Test Concurrent Actions:
1. **Add Multiple Products**
   - Add 5+ products quickly
   - Verify: All added correctly
   - Verify: Bottom button updates counter

2. **Change Machine Multiple Times**
   - Select machine A → Select machine B → Select machine C
   - Verify: Latest selection persists
   - Verify: Cart updates correctly

## Test Case 6: Realtime Updates

### Steps:
1. **Machine Status Updates**
   - Scenario: Backend sends realtime status update
   - Expected: Map markers update
   - Verify: List updates temperature/humidity

2. **Stock Updates**
   - Scenario: Product stock changes
   - Expected: Cart shows updated stock
   - Verify: Validation works correctly

## Test Case 7: UI/UX Testing

### Visual Checks:
1. **Map Screen Layout**
   - [ ] Peta mengambil 75% layar (3/4)
   - [ ] Daftar mengambil 25% layar (1/4)
   - [ ] Drag handle terlihat jelas
   - [ ] Markers mesin terlihat dengan icon
   - [ ] GPS location terlihat (blue dot)

2. **Daftar Mesin Styling**
   - [ ] Item cards terlihat jelas
   - [ ] Icon mesin muncul
   - [ ] Text readable
   - [ ] Touch target cukup besar (min 48dp)

3. **Cart Machine Card**
   - [ ] Card clearly clickable
   - [ ] Chevron indicator visible
   - [ ] Text hierarchy clear

4. **Product List Bottom Button**
   - [ ] Button visible dan fixed
   - [ ] Badge counter visible
   - [ ] Not overlapping with list items

### Animation Checks:
1. **Toggle Animation**
   - [ ] Smooth 300ms transition
   - [ ] No jank or stutter
   - [ ] Easing looks natural

2. **Navigation Transitions**
   - [ ] Page transitions smooth
   - [ ] No flash or white screen

## Performance Testing

### Memory:
1. Load map with 50+ machines
   - Monitor memory usage
   - Check for leaks

2. Scroll daftar mesin rapidly
   - Should remain smooth
   - No frame drops

### Network:
1. Test with slow connection
   - Map tiles should load progressively
   - UI should remain responsive

2. Test offline
   - Appropriate error messages
   - No crashes

## Device Testing Matrix

Test pada:
- [ ] Android Phone (High-end)
- [ ] Android Phone (Low-end)
- [ ] Android Tablet
- [ ] iOS iPhone
- [ ] iOS iPad

Test orientations:
- [ ] Portrait
- [ ] Landscape

## Regression Testing

After implementation, verify these existing features still work:
- [ ] Login/Logout
- [ ] Product detail page
- [ ] Expert system
- [ ] Transaction history
- [ ] Profile page
- [ ] Admin panel (if admin)

## Bug Report Template

If menemukan bug, gunakan template ini:

```markdown
**Bug Title**: [Brief description]

**Priority**: High / Medium / Low

**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Behavior**:


**Actual Behavior**:


**Screenshots**:
[Attach if applicable]

**Device Info**:
- Device: 
- OS Version: 
- App Version: 

**Additional Context**:

```

## Success Criteria

✅ Semua test cases passed
✅ Tidak ada crash
✅ UI/UX sesuai spesifikasi
✅ Performance acceptable
✅ Navigation flow working correctly
✅ Data persistence working
✅ Realtime updates working

## Notes

- Run tests pada different screen sizes
- Test dengan berbagai kondisi network
- Verify data consistency across navigation
- Check memory usage untuk memory leaks
- Test dengan real backend data, bukan mock
