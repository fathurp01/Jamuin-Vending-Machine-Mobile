# Jamuin (Mobile Vending Machine App) — Flutter Frontend

Modern, minimalist mobile vending machine ordering UI inspired by the *hierarchy* of apps like Fore Coffee (banner → points → actions → content), without copying branding/assets.

This repository is **frontend-only** (no backend). Data such as session, inventory, and transactions are stored locally using SharedPreferences.

Tech stack:
- Flutter (Material 3)
- Riverpod (state management)
- go_router (routing + role-based redirects)
- MapLibre GL + MapTiler Vector Style (public API usage)
- Dio (REST client scaffold; not wired to real backend)

## Folder Structure (Clean + Modular)

```
lib/
	main.dart
	src/
		app/
			app.dart
			router.dart
			theme/
				app_theme.dart
		core/
			config/
				public_apis.dart
			networking/
				dio_provider.dart
			persistence/
				local_storage.dart
		features/
			splash/presentation/
				splash_screen.dart
			auth/presentation/
				login_screen.dart
				register_screen.dart
			session/application/
				session_controller.dart
				session_persistence_providers.dart
			session/data/
				session_repository.dart
			home/presentation/
				home_screen.dart
			map/presentation/
				map_screen.dart
				machine_models.dart
				machine_providers.dart
			products/
				domain/product.dart
				data/product_repository.dart
				presentation/
					product_list_screen.dart
					product_detail_screen.dart
			inventory/
				domain/inventory_state.dart
				data/inventory_repository.dart
				application/inventory_controller.dart
			cart/
				domain/cart_item.dart
				application/cart_controller.dart
				presentation/cart_screen.dart
			checkout/
				application/checkout_controller.dart
				presentation/
					checkout_screen.dart
					transaction_status_screen.dart
			transactions/
				domain/transaction_record.dart
				data/transaction_repository.dart
				application/transaction_history_controller.dart
				presentation/transaction_history_screen.dart
			admin/presentation/
				admin_dashboard_screen.dart
				admin_stock_screen.dart
				admin_transactions_screen.dart
			about/presentation/
				about_screen.dart
		shared/widgets/
			money_text.dart
			quantity_stepper.dart
			rounded_card.dart
			section_header.dart
```

## Screen-by-Screen UI Design (Mobile-only, Simple + Modern)

### 1) Splash Screen
Goal: quick premium “brand moment” without custom assets.
- Centered rounded-square mark + `local_cafe_outlined` icon
- Soft scale + fade animation
- Tagline under the brand name
- Restores persisted session (if any) then navigates to Login / Home / Admin

### 2) Login + Register (UI-only auth)
- Login includes a **Customer/Admin role selector** (demo).
- Any credentials that pass validation are accepted (no backend).
- Session is persisted locally.

### 3) Home Screen (banner → points → actions → content)
Hierarchy:
- **Banner carousel**: 3 promos with icon + headline + subtitle + dots indicator
- **Points card**: points count + short helper text
- **Primary actions**: “Find Machine” and “Browse Menu” tiles
- **Content**: “Popular” horizontal list + a small CTA card

Also includes:
- Shortcut to **Transaction History**
- App bar links to **About**, **Cart**, and **Logout**
- Visible text indicator: “Customer mode” or “Admin mode”

Notes:
- All surfaces are rounded cards, spacious padding, no heavy elevation

### 4) Map Screen (vending machine markers)
- MapLibre map using MapTiler **vector style JSON**
- Tapping a marker selects a vending machine and persists it into session state

### 5) Product List Screen
- Vertical list of rounded cards
- Each row: icon placeholder, name, subtitle, price, chevron
- Tap → product detail

Shows per-machine stock when a machine is selected.

### 6) Product Detail Screen
- Large hero placeholder (no images required)
- Name, subtitle, price
- “About” section
- Quantity stepper
- Sticky bottom “Add to cart”

Guards:
- If no machine is selected, “Add to cart” is disabled
- If stock is 0 for selected machine, “Add to cart” is disabled

### 7) Cart Screen (real-time price calculations)
- Cart items with:
	- Quantity stepper
	- Line total
- Summary card:
	- Subtotal
	- Service fee
	- Tax (11%)
	- Total
- “Checkout” button (bottom)

Guards:
- Checkout is disabled until a machine is selected and quantities fit available stock

### 8) Checkout Screen
- Selected machine summary (change button → map)
- Order summary list
- Payment placeholder card
- Customer info form (name/phone/notes)
- Place order → creates a persisted transaction record + simulated payment result

### 9) Transaction Status Screen
- Shows transaction status (Pending/Paid/Failed)
- Shows **Details** (transaction id, machine, customer info)
- Shows **Totals** (subtotal + service fee + tax + total)
- Shows **Items** list

### 10) Transaction History Screen
- List of persisted transactions, most recent first
- Tap an item to open Transaction Status

### 11) Admin Dashboard (role-based)
- Route gated (non-admin redirects to Home)

Includes admin tools:
- Manage stock (per machine)
- View transactions
- About

### 12) Admin Stock (per-machine inventory)
- Select machine
- Increase/decrease stock per product
- Reset stock to defaults

### 13) Admin Transactions
- Read-only list of transactions with status badges
- Tap to open Transaction Status

### 14) About (Public API disclosure)
- Displays MapTiler public API information, including the vector style JSON URL used by the Map screen

## Navigation Flow Diagram (Text)

```
Splash
	-> Login (if no saved session)
	-> Home / Admin (if session exists)

Login (Customer) -> /app/home
Login (Admin) -> /app/admin

Home -> Map (select machine)
Home -> Product List -> Product Detail -> Add to Cart
Home -> Cart -> Checkout -> Transaction Status
Home -> Transaction History -> Transaction Status

Admin -> Stock / Transactions
```

## UI Component Breakdown

Core UI primitives:
- RoundedCard (soft container for almost all blocks)
- SectionHeader (title + optional trailing action)
- MoneyText (IDR formatting)
- QuantityStepper (cart/detail quantity)

Navigation:
- Material 3 `NavigationBar` (bottom navigation)
- `go_router` for routes and role-based redirect

## UX Considerations (Smooth Ordering)

- **Low-friction entry**: Home prioritizes “Find Machine” + “Browse Menu” actions.
- **State continuity**: cart totals and quantities update instantly via Riverpod.
- **Guard rails**: Checkout blocks ordering if machine is not selected.
- **Transparent pricing**: subtotal + fees + tax shown explicitly.
- **Confidence after payment**: status screen shows clear status + details + totals.

## Setup Notes (MapLibre + MapTiler)

The Map screen uses MapLibre with a MapTiler vector style URL.

- Public API URL used by the app is stored in [lib/src/core/config/public_apis.dart](lib/src/core/config/public_apis.dart)
- The same URL is displayed in-app on the About screen

If you want to use your own MapTiler key, replace the `key=...` value in `PublicApis.maptilerStreetsV4StyleUrl`.

## Run (Mobile)

This project targets **Android/iOS** (mobile UI). Other platform folders exist because of Flutter scaffolding.

Commands:
- `flutter pub get`
- `flutter run`

## Demo Notes (Role-based Admin)

On the Login screen, choose **Customer** or **Admin**. In production, role would come from real authentication/claims.
