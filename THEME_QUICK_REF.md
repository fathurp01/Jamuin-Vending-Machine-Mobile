# Theme Quick Reference

Cheat sheet untuk penggunaan tema baru yang matching dengan web UI.

## 🎨 Colors

### Menggunakan dari Theme (Recommended)
```dart
// Get from theme
final primary = Theme.of(context).colorScheme.primary;
final secondary = Theme.of(context).colorScheme.secondary;
final surface = Theme.of(context).colorScheme.surface;
```

### Menggunakan AppColors (Specific Shades)
```dart
// Primary (Orange/Golden)
AppColors.primary600  // Main primary - #A66906
AppColors.primary400  // Lighter - #F79F17
AppColors.primary700  // Darker - #764C04

// Secondary (Green)
AppColors.secondary600  // Main secondary - #43A047
AppColors.secondary400  // Lighter - #66BB6A
AppColors.secondary700  // Darker - #388E3C

// Semantic
AppColors.success   // Green
AppColors.warning   // Amber
AppColors.error     // Red
AppColors.info      // Blue
```

## 📝 Typography

### Text Styles
```dart
// Headings (Poppins) - Use theme
Text('Title', style: Theme.of(context).textTheme.titleLarge)
Text('Subtitle', style: Theme.of(context).textTheme.titleMedium)

// Body (Inter) - Use theme
Text('Body', style: Theme.of(context).textTheme.bodyMedium)

// Or use AppTextStyles directly
Text('Custom', style: AppTextStyles.headlineLarge)
```

## 🔘 Buttons

### Primary Button (Orange)
```dart
FilledButton(
  onPressed: () {},
  child: Text('Primary'),
)
```

### Secondary Button (Green)
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Secondary'),
)
```

### Outline Button
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('Outline'),
)
```

## 🃏 Cards

### Standard Card
```dart
Card(
  child: Padding(
    padding: AppSpacing.cardPadding,
    child: Text('Content'),
  ),
)
```

### Custom Elevated Card
```dart
Container(
  decoration: AppDecorations.cardElevated,
  padding: AppSpacing.cardPadding,
  child: Text('Custom'),
)
```

## 📥 Input Fields

### TextField
```dart
TextField(
  decoration: AppDecorations.inputField(
    labelText: 'Label',
    hintText: 'Hint',
    prefixIcon: Icon(Icons.email),
  ),
)
```

## 📏 Spacing

### Common Spacing
```dart
SizedBox(height: AppSpacing.sm)   // 8px
SizedBox(height: AppSpacing.md)   // 16px
SizedBox(height: AppSpacing.lg)   // 24px
SizedBox(height: AppSpacing.xl)   // 32px

// Padding
Padding(
  padding: AppSpacing.paddingMd,  // 16px all sides
  child: Widget(),
)

// Button padding
Padding(
  padding: AppSpacing.buttonPadding,  // 32px horizontal, 12px vertical
  child: Widget(),
)
```

## 🎨 Gradients

### Primary Gradient
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorderRadius.radiusMd,
  ),
)
```

### Secondary Gradient
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.secondaryGradient,
    borderRadius: AppBorderRadius.radiusMd,
  ),
)
```

## 🔄 Border Radius

```dart
BorderRadius.circular(8)   // Use AppBorderRadius.radiusMd
BorderRadius.circular(16)  // Use AppBorderRadius.radiusLg
BorderRadius.circular(999) // Use AppBorderRadius.radiusFull

// Or directly
AppBorderRadius.radiusSm   // 4px
AppBorderRadius.radiusMd   // 8px
AppBorderRadius.radiusLg   // 16px
AppBorderRadius.radiusFull // 9999px
```

## 🌓 Shadows

### Card with Shadow
```dart
Container(
  decoration: AppDecorations.cardElevated,
  child: Widget(),
)

// Large shadow
Container(
  decoration: AppDecorations.cardElevatedLarge,
  child: Widget(),
)
```

## ✅ Quick Migration

### Before
```dart
Container(
  color: Color(0xFF2F6F4E),
  padding: EdgeInsets.all(16),
  child: Text(
    'Title',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
)
```

### After
```dart
Container(
  color: Theme.of(context).colorScheme.primary,
  padding: AppSpacing.paddingMd,
  child: Text(
    'Title',
    style: Theme.of(context).textTheme.titleMedium,
  ),
)
```

## 📦 Import

```dart
// Single import for all theme
import 'package:your_app/src/app/theme/theme.dart';

// Or individual
import 'package:your_app/src/app/theme/app_colors.dart';
import 'package:your_app/src/app/theme/app_styles.dart';
import 'package:your_app/src/app/theme/app_theme.dart';
```

## 🚀 Common Patterns

### Product Card
```dart
Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.network(product.image),
      Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.success,
    borderRadius: AppBorderRadius.radiusFull,
  ),
  child: Text(
    'Active',
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Form Section
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Section Title',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    SizedBox(height: AppSpacing.md),
    TextField(
      decoration: AppDecorations.inputField(
        labelText: 'Field 1',
      ),
    ),
    SizedBox(height: AppSpacing.md),
    TextField(
      decoration: AppDecorations.inputField(
        labelText: 'Field 2',
      ),
    ),
    SizedBox(height: AppSpacing.lg),
    FilledButton(
      onPressed: () {},
      child: Text('Submit'),
    ),
  ],
)
```

---

**Pro Tips:**
- Always use `Theme.of(context)` when possible for theme consistency
- Use `AppColors` only for specific shades not in theme
- Use `AppSpacing` constants instead of hardcoded values
- Use `AppBorderRadius` for consistent rounded corners
- Refer to `THEME_MIGRATION_GUIDE.md` for detailed examples
