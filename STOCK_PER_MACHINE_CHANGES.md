# Perubahan Backend ke Frontend: Stock Per Machine

## Ringkasan Perubahan Backend

### 1. **Product Entity**
- ❌ Field `stok` dihapus dari Product entity
- ✅ Field `name` digunakan (bukan `nama`)
- ✅ Relasi `machineProducts[]` ditambahkan

### 2. **MachineProduct Entity (Baru)**
```typescript
{
  id: number
  machineId: number
  productId: number
  stok: number  // Stock per machine
}
```

### 3. **API Endpoints**
- `GET /products` - Returns products dengan array `machineProducts[]`
- `GET /products/:id` - Returns product dengan array `machineProducts[]`
- `GET /products/machine/:machineId` - Returns products di mesin tertentu dengan stock
- `PUT /products/:id/machine/:machineId/stock` - Set stock per mesin
- `GET /products/:id/machine/:machineId/stock` - Get stock per mesin

### Response Structure
```json
{
  "id": 1,
  "name": "Jamu Kunyit Asam",
  "deskripsi": "...",
  "manfaat": "...",
  "harga": 25000,
  "gambar": "...",
  "machineProducts": [
    {
      "id": 1,
      "machineId": 1,
      "productId": 1,
      "stok": 10
    },
    {
      "id": 2,
      "machineId": 2,
      "productId": 1,
      "stok": 5
    }
  ]
}
```

## Perubahan Frontend yang Dilakukan

### 1. **Product Model** (`product.dart`)
- ✅ Field `stock` sekarang deprecated dan default 0
- ✅ Tambah field `machineProducts: List<MachineProductStock>`
- ✅ Tambah class `MachineProductStock` untuk parse machineProducts
- ✅ Tambah method `stockForMachine(machineId)` untuk get stock per machine
- ✅ `fromJson()` sekarang parse `machineProducts[]` dari response
- ✅ Prioritaskan field `name` (bukan `nama`)

### 2. **Product Repository** (`product_repository.dart`)
- ✅ Tambah method `listByMachine(machineId)` - fetch products di mesin tertentu
- ✅ Tambah method `getMachineStock(productId, machineId)` - get stock per mesin
- ✅ Tambah method `setMachineStock(productId, machineId, stock)` - set stock per mesin
- ✅ Tambah provider `productsByMachineProvider` untuk Riverpod

### 3. **Product List Screen** (`product_list_screen.dart`)
- ✅ Menggunakan `stockForSelectedMachineProvider` bukan `product.stock`
- ✅ Show "Pilih mesin untuk stok" jika belum pilih mesin
- ✅ Show stock per selected machine

### 4. **Product Detail Screen** (`product_detail_screen.dart`)
- ✅ Menggunakan `stockForSelectedMachineProvider`
- ✅ Disable button "Tambah ke keranjang" jika belum pilih mesin
- ✅ Show info "Pilih mesin terlebih dahulu"
- ✅ Validate stock dari selected machine

### 5. **Cart Screen** (`cart_screen.dart`)
- ✅ Import `inventory_controller`
- ✅ Check stock dari `stockForSelectedMachineProvider`
- ✅ Validate quantity vs stock per-machine
- ✅ Max quantity berdasarkan stock di selected machine

### 6. **Checkout Controller** (`checkout_controller.dart`)
- ✅ Import `inventory_controller`
- ✅ Validate stock dari `inventory.stockFor(machineId, productId)`
- ✅ Error message include product name jika stock tidak cukup

### 7. **Inventory Sync Helper** (`inventory_sync.dart`) - BARU
- ✅ Helper function `syncInventoryForMachine()` untuk sync dari backend
- ✅ Helper function `syncInventoryFromProducts()` untuk sync dari response

## Cara Penggunaan

### 1. Get Products untuk Mesin Tertentu
```dart
final products = ref.watch(productsByMachineProvider('123'));
```

### 2. Get Stock Produk di Mesin Tertentu
```dart
// Dari selected machine
final stock = ref.watch(stockForSelectedMachineProvider('456'));

// Atau manual
final stock = await repo.getMachineStock(
  productId: '456',
  machineId: '123',
);
```

### 3. Set Stock Produk di Mesin Tertentu
```dart
await repo.setMachineStock(
  productId: '456',
  machineId: '123',
  stock: 10,
);
```

### 4. Sync Stock dari Backend
```dart
// Sync untuk mesin tertentu
await syncInventoryForMachine(ref, machineId: '123');

// Atau dari products response
await syncInventoryFromProducts(ref, products: productsList);
```

## Flow Aplikasi Sekarang

### User Flow - Pilih Mesin Dulu
1. User login
2. User pilih "Cari Mesin" 
3. User pilih mesin dari map/list
4. Stock produk sekarang berdasarkan mesin yang dipilih
5. User bisa add to cart dengan stock validation per-machine

### User Flow - Produk Dulu
1. User login
2. User pilih "Lihat Produk"
3. Show "Pilih mesin untuk stok" (no stock info yet)
4. User add to cart (no validation yet)
5. User checkout → diminta pilih mesin
6. Setelah pilih mesin → stock validated per-machine
7. Checkout berhasil jika stock cukup di mesin tersebut

## Catatan Penting

⚠️ **BACKEND TIDAK DIUBAH** - Semua perubahan hanya di frontend

✅ **Stock sekarang per-machine** - Setiap mesin punya stock berbeda untuk produk yang sama

✅ **InventoryController** - Sudah ada dan digunakan untuk track stock per-machine

✅ **Backward Compatible** - Field `Product.stock` masih ada (deprecated) untuk compatibility

✅ **Validation** - Semua validation sekarang menggunakan stock per-machine

## Testing

1. **Test tanpa pilih mesin:**
   - Product list show "Pilih mesin untuk stok"
   - Product detail button disabled "Pilih mesin terlebih dahulu"
   - Cart show warning pilih mesin

2. **Test dengan mesin dipilih:**
   - Product list show stock dari mesin tersebut
   - Product detail validate stock dari mesin
   - Cart validate semua item dengan stock di mesin
   - Checkout validate stock sebelum create transaction

3. **Test beda mesin:**
   - Pilih mesin A → stock X
   - Ganti ke mesin B → stock Y (berbeda)
   - Validate cart update stock check sesuai mesin baru
