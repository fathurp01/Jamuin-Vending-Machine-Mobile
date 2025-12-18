# Visual Diagrams - Transaction Flow

## 📱 UI Layout Diagrams

### Map Screen - Full Layout (Daftar Shown)
```
╔═══════════════════════════════════════╗
║  ← Pilih mesin                    ⋮  ║  ← AppBar
╠═══════════════════════════════════════╣
║                                       ║
║          🗺️  MAP AREA                ║
║                                       ║
║         📍 Your location              ║
║                                       ║
║      🏪 Machine A                     ║
║           🏪 Machine B                ║  ← 75% screen
║                                       ║     (3/4)
║                                       ║
║                                       ║
║      🏪 Machine C                     ║
║                                       ║
╠═══════════════════════════════════════╣
║ ═══════════════════════════════       ║  ← Drag handle
║ 📍 Mesin Terdekat                     ║
║ ┌───────────────────────────────────┐ ║
║ │ 🏪 Mesin Kampus A          →      │ ║
║ │    Gedung A, Lantai 1             │ ║
║ │    Status: Online • Temp: 25°C    │ ║
║ └───────────────────────────────────┘ ║
║ ┌───────────────────────────────────┐ ║  ← 25% screen
║ │ 🏪 Mesin Kampus B          →      │ ║     (1/4)
║ │    Gedung B, Lantai 2             │ ║
║ │    Status: Online • Temp: 24°C    │ ║
║ └───────────────────────────────────┘ ║
║ ┌───────────────────────────────────┐ ║
║ │ 🏪 Mesin Kantin            →      │ ║
║ │    Kantin Utama                   │ ║
║ └───────────────────────────────────┘ ║
╚═══════════════════════════════════════╝
```

### Map Screen - Fullscreen (Daftar Hidden)
```
╔═══════════════════════════════════════╗
║  ← Pilih mesin                    ⋮  ║  ← AppBar
╠═══════════════════════════════════════╣
║                                       ║
║                                       ║
║                                       ║
║                                       ║
║          🗺️  MAP AREA                ║
║                                       ║
║         📍 Your location              ║
║                                       ║
║      🏪 Machine A                     ║
║           🏪 Machine B                ║  ← 100% screen
║                                       ║
║                                       ║
║      🏪 Machine C                     ║
║                                       ║
║                                       ║
║                                       ║
║                                       ║
║       ┌───────────────────────┐       ║
║       │ ⬆ Lihat Daftar Mesin  │       ║  ← FAB
║       └───────────────────────┘       ║
╚═══════════════════════════════════════╝
```

### Cart Screen - Machine Selection Card
```
╔═══════════════════════════════════════╗
║  ← Keranjang                      ⋮  ║  ← AppBar
╠═══════════════════════════════════════╣
║ ┌───────────────────────────────────┐ ║
║ │ 📍 Mesin                          │ ║
║ │    [Nama Mesin Terpilih]      →  │ ║  ← Clickable card
║ │    atau                           │ ║     Tap → Navigate to map
║ │    Pilih mesin sebelum checkout   │ ║
║ └───────────────────────────────────┘ ║
║                                       ║
║ ┌───────────────────────────────────┐ ║
║ │ ☕ Jamu A                 [- 1 +] │ ║
║ │    Rp 15.000                      │ ║  ← Cart items
║ │    Stok: 10                   🗑️  │ ║
║ │    Subtotal: Rp 15.000            │ ║
║ └───────────────────────────────────┘ ║
║ ┌───────────────────────────────────┐ ║
║ │ Subtotal        Rp 15.000         │ ║
║ │ Biaya layanan   Rp  1.000         │ ║
║ │ Pajak (11%)     Rp  1.650         │ ║
║ │ ─────────────────────────────────  │ ║
║ │ Total          Rp 17.650          │ ║
║ └───────────────────────────────────┘ ║
╠═══════════════════════════════════════╣
║        [ Checkout ]                   ║  ← Bottom button
╚═══════════════════════════════════════╝
```

### Product List Screen - With Bottom Button
```
╔═══════════════════════════════════════╗
║  ← Produk                    🛍️3  ⋮  ║  ← AppBar with cart badge
╠═══════════════════════════════════════╣
║ ┌───────────────────────────────────┐ ║
║ │ ☕  Jamu Kunyit              →    │ ║
║ │     Baik untuk pencernaan         │ ║
║ │     Rp 15.000      Stok: 10       │ ║
║ └───────────────────────────────────┘ ║
║ ┌───────────────────────────────────┐ ║
║ │ ☕  Jamu Beras Kencur        →    │ ║  ← Product items
║ │     Meningkatkan stamina          │ ║
║ │     Rp 18.000      Stok: 8        │ ║
║ └───────────────────────────────────┘ ║
║ ┌───────────────────────────────────┐ ║
║ │ ☕  Jamu Temulawak           →    │ ║
║ │     Menjaga kesehatan hati        │ ║
║ │     Rp 20.000      Stok: 5        │ ║
║ └───────────────────────────────────┘ ║
║                                       ║
╠═══════════════════════════════════════╣
║    [ 🛍️ 3 ] Bayar Sekarang            ║  ← Bottom button
╚═══════════════════════════════════════╝     (only when cart has items)
```

## 🔄 Flow Diagrams

### Flow 1: Machine First (Cari Mesin Dulu)
```
    ┌─────────────┐
    │  Dashboard  │
    │             │
    │ [Cari Mesin]│ ← User clicks
    └──────┬──────┘
           │
           ▼
    ┌─────────────────────┐
    │    Map Screen       │
    │                     │
    │  📍 GPS Location    │
    │  🗺️  Peta (75%)     │
    │  📋 Daftar (25%)    │
    │                     │
    │  [Pilih Mesin A]    │ ← User selects
    └──────┬──────────────┘
           │
           │ Save to session
           ▼
    ┌─────────────────────┐
    │   SnackBar Shows    │
    │ "Terpilih: Mesin A" │
    └──────┬──────────────┘
           │
           │ User navigates manually
           ▼
    ┌─────────────────────┐
    │  Product List       │
    │                     │
    │  Browse products    │
    │  Add to cart        │
    └──────┬──────────────┘
           │
           ▼
    ┌─────────────────────┐
    │   Cart Screen       │
    │                     │
    │  ✅ Mesin: Mesin A  │
    │  ☕ Items...         │
    │                     │
    │  [Checkout] ✓       │ ← Enabled
    └─────────────────────┘
```

### Flow 2: Product First (Pilih Produk Dulu)
```
    ┌─────────────┐
    │  Dashboard  │
    │             │
    │[Lihat Produk]│ ← User clicks
    └──────┬───────┘
           │
           ▼
    ┌─────────────────────┐
    │  Product List       │
    │                     │
    │  Browse products    │
    │  Add to cart        │
    │                     │
    │  ════════════════   │
    │  [Bayar Sekarang]   │ ← Appears when cart not empty
    └──────┬──────────────┘
           │
           │ User clicks "Bayar Sekarang"
           ▼
    ┌─────────────────────┐
    │   Cart Screen       │
    │                     │
    │  ⚠️ Mesin: Belum    │ ← Click to select
    │    dipilih          │
    │  ☕ Items...         │
    │                     │
    │  [Checkout] ✗       │ ← Disabled
    └──────┬──────────────┘
           │
           │ User clicks machine card
           ▼
    ┌─────────────────────┐
    │    Map Screen       │
    │ ?returnToCart=true  │
    │                     │
    │  📍 GPS Location    │
    │  🗺️  Peta (75%)     │
    │  📋 Daftar (25%)    │
    │                     │
    │  [Pilih Mesin A]    │ ← User selects
    └──────┬──────────────┘
           │
           │ Auto-navigate back
           ▼
    ┌─────────────────────┐
    │   Cart Screen       │
    │                     │
    │  ✅ Mesin: Mesin A  │ ← Updated
    │  ☕ Items...         │
    │                     │
    │  [Checkout] ✓       │ ← Now enabled
    └──────┬──────────────┘
           │
           ▼
    ┌─────────────────────┐
    │  Checkout Process   │
    └─────────────────────┘
```

## 🔀 State Transitions

### Map Screen - Toggle State Machine
```
                ┌──────────────────┐
                │  Initial State   │
                │  List = Shown    │
                │  FAB = Hidden    │
                └────────┬─────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
          │ Tap/Drag Handle             │
          ▼                             │
   ┌─────────────────┐                 │
   │   List Hidden   │                 │
   │   FAB Shown     │                 │
   │   Map Fullscreen│                 │
   └────────┬────────┘                 │
            │                           │
            │ Tap FAB                   │
            │ "Lihat Daftar"            │
            ▼                           │
   ┌─────────────────┐                 │
   │   List Shown    │◄────────────────┘
   │   FAB Hidden    │
   │   Map 75%       │
   └─────────────────┘
```

### Machine Selection State
```
    ┌───────────────────┐
    │  No Machine       │
    │  Selected         │
    └─────────┬─────────┘
              │
              │ User selects from map
              ▼
    ┌───────────────────┐
    │  Machine ID       │ ────┐
    │  saved in session │     │ Persisted
    │                   │     │ to SharedPreferences
    │  Machine Name     │ ◄───┘
    │  displayed in UI  │
    └───────────────────┘
```

## 🎭 User Journey Maps

### Journey 1: Quick Buy (Mesin First)
```
Scenario: User tahu mau beli apa, langsung pilih mesin terdekat

Step 1          Step 2          Step 3          Step 4
Dashboard   →   Map Screen  →   Product     →   Cart
                                List
😊 Happy        😊 Found        😊 Found        😊 Quick
  "Need           nearby          product         checkout
   drink"         machine"       
   
Time: ~30 sec   Time: ~15 sec   Time: ~20 sec   Time: ~10 sec
Total: ~75 seconds
```

### Journey 2: Browse First (Produk First)
```
Scenario: User mau lihat-lihat dulu produk apa aja yang ada

Step 1          Step 2          Step 3          Step 4          Step 5
Dashboard   →   Product     →   Product     →   Map         →   Cart
                List            List            Screen
                (browsing)      (add items)     (pick machine)
                
😊 Happy        🤔 Browsing     😊 Found        😊 Found        😊 Ready
  "What's         "Hmm,           items,          nearest         to buy
   available?"     options?"       added"          machine"
   
Time: ~30 sec   Time: ~60 sec   Time: ~30 sec   Time: ~15 sec   Time: ~10 sec
Total: ~145 seconds
```

## 📊 Component Hierarchy

### Map Screen Component Tree
```
MapScreen (StatefulWidget)
  │
  ├─ Scaffold
  │   │
  │   ├─ AppBar
  │   │   └─ title: "Pilih mesin"
  │   │
  │   └─ body: Stack
  │       │
  │       ├─ MapLibreMap (fullscreen)
  │       │   ├─ Markers (machines)
  │       │   └─ GPS location dot
  │       │
  │       ├─ AnimatedPositioned (machine list)
  │       │   └─ Container (rounded top corners)
  │       │       ├─ GestureDetector (drag handle)
  │       │       ├─ Header ("Mesin Terdekat")
  │       │       └─ ListView
  │       │           └─ MachineListItems...
  │       │
  │       └─ Positioned (FAB)
  │           └─ FloatingActionButton.extended
  │               └─ "Lihat Daftar Mesin"
```

### Cart Screen - Machine Card
```
CartScreen (ConsumerWidget)
  │
  └─ Scaffold
      └─ body: ListView
          └─ RoundedCard (machine selection)
              └─ InkWell (clickable)
                  └─ Padding
                      └─ Row
                          ├─ Icon (location)
                          ├─ Expanded (Column)
                          │   ├─ Text ("Mesin")
                          │   └─ Text (machine name / "Pilih mesin...")
                          └─ Icon (chevron_right)
```

## 🎬 Animation Timelines

### Toggle Daftar Animation
```
Duration: 300ms
Curve: easeInOut

Time    0ms         150ms        300ms
        │            │            │
Show    │════════════│════════════│  List fully visible
        │            │            │
Hide    │════════════│════════════│  List fully hidden
        │            │            │
        Start      Middle        End
        
Position:
Show:   bottom: -300 ──────────► bottom: 0
Hide:   bottom: 0    ──────────► bottom: -300

FAB:
Show:   opacity: 1.0 ──────────► opacity: 0.0
Hide:   opacity: 0.0 ──────────► opacity: 1.0
```

## 🗺️ Navigation Graph

### App Navigation Structure
```
                  ┌──────────────┐
                  │    Splash    │
                  └──────┬───────┘
                         │
                  ┌──────▼───────┐
                  │     Login    │
                  └──────┬───────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
    ┌─────▼──────┐              ┌──────▼─────┐
    │  Dashboard │              │   Admin    │
    │  (User)    │              │ Dashboard  │
    └─────┬──────┘              └────────────┘
          │
    ┌─────┴─────────────────────────┐
    │                               │
┌───▼───┐                      ┌────▼────┐
│  Map  │◄─────────────────────│  Cart   │
│Screen │  returnToCart=true   │ Screen  │
└───┬───┘                      └────┬────┘
    │                               │
    │                          ┌────▼────────┐
    │                          │  Checkout   │
    │                          └─────────────┘
    │
┌───▼────────┐
│  Product   │
│   List     │
└────────────┘
```

---

**Catatan**: Semua diagram menggunakan ASCII art untuk kompatibilitas maksimal dengan berbagai editor dan platform.
