# Quick Reference - Transaction Flow Implementation

## 🎯 Ringkasan Singkat

Aplikasi Jamuin sekarang mendukung 2 flow transaksi:
1. **Pilih Mesin Dulu** → Dashboard → Map → Pilih Mesin → Produk → Cart → Checkout
2. **Pilih Produk Dulu** → Dashboard → Produk → Cart → Map → Pilih Mesin → Checkout

## 🗺️ Halaman Map - Fitur Utama

### Layout
```
┌──────────────────┐
│   Peta (75%)     │  ← Markers + GPS
├──────────────────┤
│   Daftar (25%)   │  ← Scrollable list
└──────────────────┘
```

### Toggle Daftar
- **Hide**: Drag/tap handle → Fullscreen map + FAB muncul
- **Show**: Tap FAB → Daftar muncul kembali

### Pilih Mesin
- **Dari Peta**: Tap marker mesin
- **Dari Daftar**: Tap item di list

## 🛒 Flow Lengkap

### Dari Dashboard → Mesin First
```
Dashboard
  ↓ Klik "Cari Mesin"
Map (pilih mesin)
  ↓ Mesin tersimpan
Produk (browse & add)
  ↓
Cart (mesin sudah ada)
  ↓ Checkout
```

### Dari Dashboard → Produk First
```
Dashboard
  ↓ Klik "Lihat Produk"
Produk (add to cart)
  ↓ Klik "Bayar Sekarang" (bottom button)
Cart (mesin belum ada)
  ↓ Klik card mesin
Map (pilih mesin) → Auto back to cart
  ↓
Cart (mesin sudah ada)
  ↓ Checkout
```

## 📝 File yang Diubah

1. **`map_screen.dart`**
   - Layout 3/4 + 1/4
   - Toggle daftar
   - Parameter `returnToCart`

2. **`cart_screen.dart`**
   - Clickable machine card
   - Navigate ke map dengan parameter

3. **`product_list_screen.dart`**
   - Bottom button "Bayar Sekarang"
   - Badge counter

4. **`router.dart`**
   - Query parameter handling

## 🔧 Key Components

### MapScreen Constructor
```dart
MapScreen({
  super.key, 
  this.returnToCart = false  // true jika dari cart
})
```

### Navigation Examples
```dart
// Dari dashboard/home (biasa)
context.go('/app/map')

// Dari cart (dengan return)
context.push('/app/map?returnToCart=true')
```

### State Toggle
```dart
bool _showMachineList = true;

// Toggle
setState(() {
  _showMachineList = !_showMachineList;
});
```

## 🎨 UI Elements

### Map Features
- ✅ 3/4 screen map
- ✅ Machine markers dengan icon
- ✅ GPS location (blue dot)
- ✅ Compass enabled
- ✅ Rotate gestures

### Machine List
- ✅ 1/4 screen scrollable
- ✅ Shows: Name, Location, Status, Temp, Humidity
- ✅ Sorted by distance (GPS)
- ✅ Clickable items

### Toggle Controls
- ✅ Drag handle untuk hide/show
- ✅ Smooth animation (300ms)
- ✅ FAB ketika hidden

## 🚀 Testing Checklist

### Flow Mesin First
- [ ] Dashboard → Map works
- [ ] Can select machine
- [ ] Machine saved in session
- [ ] Can continue to products

### Flow Produk First
- [ ] Dashboard → Products works
- [ ] Bottom button appears with items
- [ ] Cart → Map navigation works
- [ ] Auto-return to cart works
- [ ] Machine selection persists

### Toggle Daftar
- [ ] Hide animation smooth
- [ ] FAB appears when hidden
- [ ] Show animation smooth
- [ ] FAB disappears when shown

## 📊 Debug Tips

### Check Machine Selection
```dart
// Di console/debugger
final session = ref.read(sessionControllerProvider);
print('Selected: ${session.selectedMachineName}');
print('Machine ID: ${session.selectedMachineId}');
```

### Check Cart Items
```dart
final cart = ref.read(cartControllerProvider);
print('Items: ${cart.itemCount}');
print('Total: ${cart.total}');
```

### Check Route Parameters
```dart
// Di router
print('ReturnToCart: ${state.uri.queryParameters['returnToCart']}');
```

## ⚠️ Common Issues

### Issue: GPS tidak muncul
**Solution**: Check permission di AndroidManifest.xml / Info.plist

### Issue: Map tidak load
**Solution**: Verify MapTiler API key di `public_apis.dart`

### Issue: Daftar tidak toggle
**Solution**: Check `_showMachineList` state update

### Issue: Navigation tidak kembali ke cart
**Solution**: Verify `returnToCart` parameter passed correctly

## 📚 Related Files

**Documentation:**
- `TRANSACTION_FLOW.md` - Flow detail lengkap
- `IMPLEMENTATION_SUMMARY.md` - Summary implementasi
- `TESTING_GUIDE.md` - Panduan testing

**Code:**
- `lib/src/features/map/presentation/map_screen.dart`
- `lib/src/features/cart/presentation/cart_screen.dart`
- `lib/src/features/products/presentation/product_list_screen.dart`
- `lib/src/app/router.dart`

## 🎯 Next Actions

1. **Test di device/emulator**
   ```bash
   flutter run
   ```

2. **Build untuk production**
   ```bash
   flutter build apk --release
   # atau
   flutter build ios --release
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

## 💡 Pro Tips

1. **GPS Testing**: Use emulator location simulation untuk test berbagai lokasi
2. **Performance**: Monitor dengan Flutter DevTools untuk performance issues
3. **Network**: Test dengan berbagai kondisi network (slow 3G, offline, dll)
4. **State**: Use Riverpod Devtools untuk inspect state changes
5. **Navigation**: Use Flutter Inspector untuk check navigation stack

## 🔗 Quick Links

- Flutter Docs: https://docs.flutter.dev
- MapLibre: https://maplibre.org
- Riverpod: https://riverpod.dev
- Go Router: https://pub.dev/packages/go_router

---

**Last Updated**: December 18, 2025
**Version**: 1.0.0
**Author**: GitHub Copilot
