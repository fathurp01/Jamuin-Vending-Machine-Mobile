# Theme Migration Guide

Panduan ini menjelaskan perubahan tema UI mobile untuk mencocokkan UI web.

## Perubahan Utama

### 1. Color Palette
Tema telah diperbarui dari soft green/cream menjadi orange-golden (primary) dan green (secondary) untuk mencocokkan web:

#### Primary Colors (Orange/Golden)
- `AppColors.primary600` - Warna primary utama (#A66906)
- `AppColors.primary400` - Lighter variant (#F79F17)
- `AppColors.primary700` - Darker variant (#764C04)

#### Secondary Colors (Green)
- `AppColors.secondary600` - Warna secondary utama (#43A047)
- `AppColors.secondary400` - Lighter variant (#66BB6A)
- `AppColors.secondary700` - Darker variant (#388E3C)

### 2. Typography
Menggunakan Google Fonts yang sama dengan web:
- **Poppins** - Untuk display/heading text
- **Inter** - Untuk body text

### 3. Spacing & Sizing
Mengikuti 8px grid system dan golden ratio dari web:
- Base spacing: 8px, 16px, 24px, 32px, 48px
- Golden ratio: 52px, 84px, 136px, 220px, 356px

### 4. Border Radius
- Cards: 16px (rounded-2xl di web adalah 20px)
- Buttons & Inputs: 8px (rounded-lg)
- Pills/Tags: 999px (rounded-full)

### 5. Shadows
Enhanced elevation dengan multi-layer shadows:
- `cardElevated` - Standard card elevation
- `cardElevatedLarge` - Large card elevation untuk highlight

## Cara Menggunakan Tema Baru

### Import Dependencies
```dart
import 'package:your_app/src/app/theme/app_colors.dart';
import 'package:your_app/src/app/theme/app_styles.dart';
```

### Menggunakan Warna
```dart
// Gunakan dari colorScheme (recommended)
final primary = Theme.of(context).colorScheme.primary;
final secondary = Theme.of(context).colorScheme.secondary;

// Atau dari AppColors untuk warna spesifik
Container(
  color: AppColors.primary600,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

### Menggunakan Text Styles
```dart
// Display/Heading text (Poppins)
Text(
  'Heading',
  style: Theme.of(context).textTheme.titleLarge, // Sudah Poppins
)

// Body text (Inter)
Text(
  'Body text',
  style: Theme.of(context).textTheme.bodyMedium, // Sudah Inter
)

// Custom text dengan AppTextStyles
Text(
  'Custom',
  style: AppTextStyles.headlineLarge,
)
```

### Menggunakan Card dengan Elevation
```dart
// Card standard (sudah included di theme)
Card(
  child: Padding(
    padding: AppSpacing.cardPadding,
    child: Text('Content'),
  ),
)

// Card dengan custom decoration
Container(
  decoration: AppDecorations.cardElevated,
  padding: AppSpacing.cardPadding,
  child: Text('Custom card'),
)
```

### Menggunakan Buttons
```dart
// Primary button (orange)
FilledButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Secondary button (green)
ElevatedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)

// Outline button
OutlinedButton(
  onPressed: () {},
  child: Text('Outline Action'),
)
```

### Menggunakan Input Fields
```dart
TextField(
  decoration: AppDecorations.inputField(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email),
  ),
)
```

### Menggunakan Gradients
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorderRadius.radiusMd,
  ),
  child: Text('Gradient'),
)
```

### Menggunakan Spacing
```dart
Column(
  children: [
    Text('Item 1'),
    SizedBox(height: AppSpacing.md), // 16px
    Text('Item 2'),
    SizedBox(height: AppSpacing.lg), // 24px
    Text('Item 3'),
  ],
)

// Atau menggunakan padding
Padding(
  padding: AppSpacing.paddingLg, // 24px all sides
  child: Text('Content'),
)
```

## Semantic Colors
Gunakan semantic colors untuk status/states:
```dart
// Success (green)
Container(color: AppColors.success)

// Warning (amber)
Container(color: AppColors.warning)

// Error (red)
Container(color: AppColors.error)

// Info (blue)
Container(color: AppColors.info)
```

## Migration Checklist

Saat mengupdate komponen existing:

- [ ] Replace hardcoded colors dengan `Theme.of(context).colorScheme` atau `AppColors`
- [ ] Update text styles menggunakan `Theme.of(context).textTheme` atau `AppTextStyles`
- [ ] Update spacing menggunakan `AppSpacing` constants
- [ ] Update border radius menggunakan `AppBorderRadius`
- [ ] Tambahkan shadows untuk cards/elevated components
- [ ] Ganti button rounded yang fully rounded (999px) dengan rounded-lg (8px) untuk consistency dengan web

## Contoh Sebelum & Sesudah

### Sebelum
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF2F6F4E), // Hardcoded color
    borderRadius: BorderRadius.circular(20),
  ),
  padding: EdgeInsets.all(16),
  child: Text(
    'Title',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Sesudah
```dart
Container(
  decoration: AppDecorations.cardElevated.copyWith(
    color: Theme.of(context).colorScheme.primary,
  ),
  padding: AppSpacing.paddingMd,
  child: Text(
    'Title',
    style: Theme.of(context).textTheme.titleMedium,
  ),
)
```

## Resources

### Files Referensi
- `lib/src/app/theme/app_theme.dart` - Main theme configuration
- `lib/src/app/theme/app_colors.dart` - Color constants
- `lib/src/app/theme/app_styles.dart` - Text styles, decorations, spacing

### Web Theme Referensi
- `frontend/vending-machine-web/tailwind.config.js` - Web color palette
- `frontend/vending-machine-web/src/index.css` - Web styling

## FAQ

**Q: Apakah saya harus menggunakan AppColors untuk semua warna?**
A: Sebaiknya gunakan `Theme.of(context).colorScheme` dulu. Gunakan `AppColors` hanya jika butuh warna spesifik yang tidak ada di colorScheme.

**Q: Bagaimana dengan warna untuk status (green, red, orange)?**
A: Gunakan semantic colors: `AppColors.success`, `AppColors.error`, `AppColors.warning`, `AppColors.info`.

**Q: Apakah semua font harus diganti?**
A: Ya, untuk consistency. Gunakan `textTheme` dari Theme yang sudah dikonfigurasi dengan Poppins (heading) dan Inter (body).

**Q: Border radius card masih 16px bukan 20px seperti web?**
A: Flutter biasanya menggunakan kelipatan 4px. 16px adalah closest approximation yang masih rapi.
