# Troubleshooting Guide - Transaction Flow

## 🔍 Common Issues & Solutions

### 1. Map Tidak Muncul / Layar Hitam

#### Symptom:
- Map screen shows black screen
- No error message
- Loading indicator stuck

#### Possible Causes & Solutions:

**A. MapTiler API Key Tidak Valid**
```dart
// Check: lib/src/core/config/public_apis.dart
static const maptilerStreetsV4StyleUrl = 'https://api.maptiler.com/...';
```
- **Solution**: Verify API key is valid and has not expired
- **Test**: Try the URL in browser, should return JSON

**B. Network Issue**
- **Solution**: Check internet connection
- **Solution**: Add exception for MapTiler domain in network security config (Android)

**C. Missing Permission**
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### Quick Fix:
```bash
# Clear cache and rebuild
flutter clean
flutter pub get
flutter run
```

---

### 2. GPS Location Tidak Muncul

#### Symptom:
- Map loads correctly
- Blue dot (user location) tidak muncul
- Machine markers visible

#### Possible Causes & Solutions:

**A. Location Permission Belum Di-Grant**

Android:
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

iOS:
```xml
<!-- Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby machines</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to show nearby machines</string>
```

**B. Location Service Disabled**
- **Solution**: Enable location in device settings
- **Test**: Check with Maps app if location works

**C. Permission Not Requested at Runtime**
- **Solution**: Add permission_handler package
```yaml
dependencies:
  permission_handler: ^latest
```

```dart
// Request permission
await Permission.location.request();
```

#### Quick Fix:
```bash
# Uninstall and reinstall app
flutter clean
flutter run

# Grant permission manually in device settings
Settings → Apps → Jamuin → Permissions → Location → Allow
```

---

### 3. Daftar Mesin Tidak Muncul

#### Symptom:
- Map loads
- No machine list at bottom
- Or list shows but empty

#### Possible Causes & Solutions:

**A. Backend Tidak Return Data**
```dart
// Debug: Check machinesProvider
final machines = ref.watch(machinesProvider);
machines.when(
  data: (list) => print('Machines: ${list.length}'),
  error: (e, st) => print('Error: $e'),
  loading: () => print('Loading...'),
);
```
- **Solution**: Verify backend API is running
- **Solution**: Check network inspector for API calls

**B. Machines Tidak Punya Koordinat**
```dart
// Backend harus return lat & lng
{
  "id": 1,
  "name": "Mesin A",
  "lat": -6.123456,  // Required
  "lng": 106.123456  // Required
}
```
- **Solution**: Update backend to include coordinates
- **Fallback**: App akan show list-only view (no map)

**C. State Management Issue**
- **Solution**: Invalidate provider
```dart
ref.invalidate(machinesProvider);
```

#### Quick Fix:
```dart
// Add debug print in map_screen.dart
data: (machines) {
  print('DEBUG: Total machines: ${machines.length}');
  print('DEBUG: Machines with coords: ${machines.where((m) => m.hasCoordinates).length}');
  // ... rest of code
}
```

---

### 4. Toggle Daftar Tidak Bekerja

#### Symptom:
- Tap drag handle tidak respond
- List tidak hide/show
- No animation

#### Possible Causes & Solutions:

**A. State Tidak Update**
```dart
// Check setState is called
void _toggleList() {
  setState(() {
    _showMachineList = !_showMachineList;
  });
}
```

**B. GestureDetector Tertutup Widget Lain**
```dart
// Pastikan GestureDetector tidak di-overlap
Container(
  width: double.infinity,  // Important!
  child: GestureDetector(
    onTap: () { ... },
    child: Container(...),
  ),
)
```

**C. Build Method Tidak Rebuild**
- **Solution**: Verify StatefulWidget, bukan StatelessWidget
- **Solution**: Check setState() dipanggil

#### Quick Fix:
```dart
// Add debug print
onTap: () {
  print('DEBUG: Toggle tapped, current: $_showMachineList');
  setState(() {
    _showMachineList = !_showMachineList;
  });
  print('DEBUG: After toggle: $_showMachineList');
},
```

---

### 5. Navigation Tidak Kembali ke Cart

#### Symptom:
- Pilih mesin di map
- Tidak auto-navigate ke cart
- Stuck di map screen

#### Possible Causes & Solutions:

**A. Parameter `returnToCart` Tidak Passed**
```dart
// Check di CartScreen
context.push('/app/map?returnToCart=true')  // ✅ Correct

// NOT this:
context.push('/app/map')  // ❌ Wrong
```

**B. Router Tidak Parse Parameter**
```dart
// Check di router.dart
GoRoute(
  path: '/app/map',
  builder: (context, state) {
    final returnToCart = state.uri.queryParameters['returnToCart'] == 'true';
    return MapScreen(returnToCart: returnToCart);  // Must pass parameter
  },
),
```

**C. MapScreen Tidak Handle Parameter**
```dart
// Check di map_screen.dart constructor
class MapScreen extends ConsumerStatefulWidget {
  final bool returnToCart;  // Must have this
  
  const MapScreen({super.key, this.returnToCart = false});
  // ...
}

// In _persistSelectedMachine:
if (widget.returnToCart) {
  context.pop();  // Must call this
  return;
}
```

#### Quick Fix:
```dart
// Add debug print
Future<void> _persistSelectedMachine(VendingMachine machine) async {
  print('DEBUG: returnToCart = ${widget.returnToCart}');
  
  // ... save machine ...
  
  if (widget.returnToCart) {
    print('DEBUG: Navigating back to cart');
    context.pop();
    return;
  }
  
  print('DEBUG: Showing snackbar');
  // ... show snackbar ...
}
```

---

### 6. Bottom Button "Bayar Sekarang" Tidak Muncul

#### Symptom:
- Add product to cart
- No bottom button appears in ProductListScreen
- Badge di AppBar update, tapi button tidak muncul

#### Possible Causes & Solutions:

**A. Cart State Tidak Update**
```dart
// Check cartControllerProvider
final cart = ref.watch(cartControllerProvider);
print('DEBUG: Cart items: ${cart.items.length}');
print('DEBUG: Cart item count: ${cart.itemCount}');
```

**B. Condition Check Salah**
```dart
// Check di product_list_screen.dart
bottomNavigationBar: cart.items.isEmpty  // Correct
    ? null
    : SafeArea(
        child: FilledButton(...),
      ),
```

**C. Widget Tidak Rebuild**
- **Solution**: Pastikan menggunakan `ConsumerWidget` atau `Consumer`
- **Solution**: Verify `ref.watch(cartControllerProvider)` dipanggil

#### Quick Fix:
```dart
// Add debug di build method
@override
Widget build(BuildContext context, WidgetRef ref) {
  final cart = ref.watch(cartControllerProvider);
  print('DEBUG: Building ProductListScreen, cart count: ${cart.itemCount}');
  
  return Scaffold(
    // ...
    bottomNavigationBar: cart.items.isEmpty
        ? (print('DEBUG: No bottom button'), null)
        : (print('DEBUG: Showing bottom button'), SafeArea(...)),
  );
}
```

---

### 7. Checkout Button Disabled di Cart

#### Symptom:
- Machine sudah dipilih
- Items ada di cart
- Button "Checkout" tetap disabled (grey)

#### Possible Causes & Solutions:

**A. hasStockIssues True**
```dart
// Check logic
final hasStockIssues = hasSelectedMachine
    ? cart.items.values.any((it) => it.quantity > it.product.stock)
    : true;  // This will be true if no machine selected!

print('DEBUG: hasSelectedMachine: $hasSelectedMachine');
print('DEBUG: hasStockIssues: $hasStockIssues');
```

**B. Machine ID Null**
```dart
// Check session
final session = ref.watch(sessionControllerProvider);
print('DEBUG: Selected machine ID: ${session.selectedMachineId}');
print('DEBUG: Selected machine name: ${session.selectedMachineName}');
```

**C. Stock Check Failing**
```dart
// Debug each item
for (var item in cart.items.values) {
  print('DEBUG: ${item.product.name}');
  print('  Quantity: ${item.quantity}');
  print('  Stock: ${item.product.stock}');
  print('  Over stock: ${item.quantity > item.product.stock}');
}
```

#### Quick Fix:
```dart
// Temporary: Force enable button untuk testing
FilledButton(
  // onPressed: hasStockIssues ? null : () => context.push('/app/checkout'),
  onPressed: () {  // Remove null check temporarily
    print('DEBUG: Forcing checkout');
    context.push('/app/checkout');
  },
  child: const Text('Checkout'),
),
```

---

### 8. Animation Jank / Laggy

#### Symptom:
- Toggle animation stutters
- Frame drops
- Not smooth 60fps

#### Possible Causes & Solutions:

**A. Build Method Terlalu Berat**
- **Solution**: Move heavy computation to separate method
- **Solution**: Use `const` widgets where possible

**B. List Terlalu Panjang**
- **Solution**: Add pagination
```dart
ListView.builder(
  itemCount: min(machines.length, 10),  // Limit items
  // ...
)
```

**C. Debug Mode**
- **Solution**: Test in release mode
```bash
flutter run --release
```

**D. Device Performance**
- **Solution**: Test on different devices
- **Solution**: Reduce animation complexity

#### Quick Fix:
```dart
// Simplify animation
AnimatedPositioned(
  duration: const Duration(milliseconds: 200),  // Reduce from 300
  curve: Curves.linear,  // Simpler curve
  // ...
)
```

---

### 9. Markers Tidak Muncul di Peta

#### Symptom:
- Map loads correctly
- GPS works
- No machine markers visible

#### Possible Causes & Solutions:

**A. addSymbol Belum Dipanggil**
```dart
// Check onStyleLoadedCallback
onStyleLoadedCallback: () {
  print('DEBUG: Style loaded, adding symbols');
  _addMachineSymbols(machinesWithCoordinates);
},
```

**B. Symbol Add Gagal**
```dart
Future<void> _addMachineSymbols(List<VendingMachine> machines) async {
  print('DEBUG: Adding ${machines.length} symbols');
  
  for (final m in machines.where((m) => m.hasCoordinates)) {
    print('DEBUG: Adding symbol for ${m.name} at ${m.lat}, ${m.lng}');
    final symbol = await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(m.lat!, m.lng!),
        iconImage: 'marker-15',  // Must be available in style
        // ...
      ),
    );
    print('DEBUG: Symbol added: ${symbol.id}');
  }
}
```

**C. Icon Tidak Tersedia di Style**
- **Solution**: Use default icons from MapTiler style
- **Available icons**: 'marker-15', 'circle-15', 'square-15'

**D. Koordinat Di Luar Viewport**
- **Solution**: Adjust initial camera position
```dart
initialCameraPosition: CameraPosition(
  target: LatLng(machines.first.lat!, machines.first.lng!),
  zoom: 12.0,  // Adjust zoom
),
```

#### Quick Fix:
```dart
// Test with known coordinates
await controller.addSymbol(
  SymbolOptions(
    geometry: LatLng(-6.200000, 106.816666),  // Jakarta
    iconImage: 'marker-15',
    textField: 'TEST MARKER',
  ),
);
```

---

## 🛠️ Debug Tools

### Enable Debug Logging
```dart
// Add at top of map_screen.dart
import 'package:flutter/foundation.dart';

void debugLog(String message) {
  if (kDebugMode) {
    print('[MapScreen] $message');
  }
}

// Use throughout code
debugLog('Map controller initialized');
debugLog('Adding ${machines.length} machines');
```

### Flutter DevTools
```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Or use VS Code extension
# View → Command Palette → "Flutter: Open DevTools"
```

**Check:**
- Widget Inspector → Verify widget tree
- Network → Check API calls
- Performance → Check frame rendering
- Logging → See all print statements

### Check State with Riverpod Devtools
```dart
// In main.dart
void main() {
  runApp(
    ProviderScope(
      observers: [MyObserver()],  // Add observer
      child: JamuinApp(),
    ),
  );
}

class MyObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[Provider Update] ${provider.name ?? provider.runtimeType}');
    print('  Previous: $previousValue');
    print('  New: $newValue');
  }
}
```

---

## 📋 Diagnostic Checklist

Before reporting a bug, check:

- [ ] Flutter doctor shows no issues
- [ ] Backend API is running and accessible
- [ ] Device has internet connection
- [ ] Location permission granted
- [ ] MapTiler API key is valid
- [ ] Tested on release build (not just debug)
- [ ] Checked console logs for errors
- [ ] Tried on different device/emulator
- [ ] Cleared cache and rebuilt
- [ ] Checked state with print statements

## 🆘 Getting Help

### Information to Include:

1. **Flutter Info**
```bash
flutter doctor -v
flutter --version
```

2. **Device Info**
- Device model
- OS version
- Screen size

3. **Steps to Reproduce**
- Exact steps
- What you expected
- What actually happened

4. **Console Logs**
```bash
# Capture full logs
flutter run > logs.txt 2>&1
```

5. **Screenshots/Video**
- Take screenshots of issue
- Screen recording if possible

### Where to Ask:
- GitHub Issues (for this project)
- Flutter Discord
- Stack Overflow (tag: flutter, dart)

---

**Last Updated**: December 18, 2025
**Version**: 1.0.0
