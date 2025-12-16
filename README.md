# Vendo (Mobile Vending Machine App) — Flutter Frontend

Modern, minimalist vending machine ordering UI inspired by the *hierarchy* of apps like Fore Coffee (banner → points → actions → content), without copying branding/assets.

Tech stack:
- Flutter 3.x (Material 3)
- Riverpod (state management)
- Dio (REST API client scaffolding)
- Google Maps (machine selection)

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
			networking/
				dio_provider.dart
		features/
			splash/presentation/
				splash_screen.dart
			session/application/
				session_controller.dart
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
			cart/
				domain/cart_item.dart
				application/cart_controller.dart
				presentation/cart_screen.dart
			checkout/
				application/checkout_controller.dart
				presentation/
					checkout_screen.dart
					transaction_status_screen.dart
			admin/presentation/
				admin_dashboard_screen.dart
		shared/widgets/
			money_text.dart
			quantity_stepper.dart
			rounded_card.dart
			section_header.dart
```

## Screen-by-Screen UI Design (Simple + Modern)

### 1) Splash Screen (Fore-style animation)
Goal: quick premium “brand moment” without custom assets.
- Centered rounded-square mark + `local_cafe_outlined` icon
- Soft scale + fade animation
- Tagline under the brand name
- Auto-navigates to Home

### 2) Home Screen (banner → points → actions → content)
Hierarchy:
- **Banner carousel**: 3 promos with icon + headline + subtitle + dots indicator
- **Points card**: points count + short helper text
- **Primary actions**: “Find Machine” and “Browse Menu” tiles
- **Content**: “Popular” horizontal list + a small CTA card

Notes:
- All surfaces are rounded cards, spacious padding, no heavy elevation

### 3) Map Screen (vending machine markers)
- Google Map with markers for machines
- Tapping a marker info window selects a machine (stored in session state)
- Web fallback: simple list selection (since maps support varies by platform)

### 4) Product List Screen
- Vertical list of rounded cards
- Each row: icon placeholder, name, subtitle, price, chevron
- Tap → product detail

### 5) Product Detail Screen
- Large hero placeholder (no images required)
- Name, subtitle, price
- “About” section
- Quantity stepper
- Sticky bottom “Add to cart”

### 6) Cart Screen (real-time price calculations)
- Cart items with:
	- Quantity stepper
	- Line total
- Summary card:
	- Subtotal
	- Service fee
	- Tax (11%)
	- Total
- “Checkout” button (bottom)

### 7) Checkout Screen
- Selected machine summary (change button → map)
- Order summary list
- Payment placeholder card
- Place order → simulated real-time status progression

### 8) Transaction Status Screen
- Status card with icon + headline + subtitle
- Transaction card (ID + total)
- Progress list (received → preparing → ready → completed)

### 9) Admin Dashboard (role-based)
- Route gated (non-admin redirects to Home)
- Simple KPI cards (Orders, Revenue, Machines Online, Alerts)
- “Switch to customer” action (demo-only)

## Navigation Flow Diagram (Text)

```
Splash
	-> Home (Bottom Nav Shell)
			 |-> Home
			 |-> Map (select machine)
			 |-> Cart
			 |-> Admin (only if role=admin)

Home -> Product List -> Product Detail -> Add to Cart
Cart -> Checkout -> Transaction Status
Checkout -> Map (change machine)
Transaction Status -> Home
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
- **Confidence after payment**: status screen shows progress and a clear next action.

## Setup Notes (Google Maps)

To use Google Maps on Android/iOS, add API keys in the platform-specific config.
This repo includes the UI, markers, and selection state wiring, but you must supply keys for runtime.

Android:
- Add this line to [android/gradle.properties](android/gradle.properties):
	- `MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY`

iOS:
- Provide the Google Maps key via the usual iOS setup for Google Maps SDK (not included in this repo).

## Demo Notes (Role-based Admin)

For demo purposes, **long-press the Home title (“Vendo”)** to toggle customer/admin.
In production, role would come from auth/claims.
