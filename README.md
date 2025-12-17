# Jamuin (Mobile Vending Machine App) — Flutter

Modern mobile vending machine app.

JamUin is now **connected to `backend_jamuin`** via:
- HTTP REST API (Dio + Bearer JWT)
- Realtime updates (socket.io)

Tech stack:
- Flutter (Material 3)
- Riverpod (state management)
- go_router (routing + role-based redirects)
- MapLibre GL + MapTiler Vector Style (public API usage)
- Dio (REST client; wired to backend_jamuin)
- socket.io client (realtime machine updates)

## Backend Integration

Backend base URL is configured in [lib/src/core/config/backend_config.dart](lib/src/core/config/backend_config.dart).

Default values:
- Android emulator: `http://10.0.2.2:3000`
- Physical device: `http://<YOUR_PC_IP>:3000`

Realtime uses the same base URL (socket.io).

### Endpoints used by mobile

- Auth: `POST /auth/register`, `POST /auth/login`
- Machines (JWT): `GET /machines`, `GET /machines/online`
- Products: `GET /products`, `GET /products/:id`, (admin) `PATCH /products/:id` field `stok`
- Payments: `POST /payments/create`, `GET /payments/status/:orderId`, `GET /payments/my-history`, (admin) `GET /payments/transactions`, `POST /payments/cancel/:orderId`
- Expert System: `POST /expert-system/initialize`, `GET /expert-system/start`, `POST /expert-system/diagnose`

### Realtime events used by mobile

socket.io events consumed:
- `connected`
- `temperature-update`
- `status-update`
- `heartbeat`

## Notes / Known Backend Gaps

See [backend_update_request.md](backend_update_request.md) for backend changes that may be needed for full parity/hardening (admin guards, machine coordinates `lat/lng`, optional loyalty points, etc.).

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
				backend_config.dart
				public_apis.dart
			networking/
				dio_provider.dart
			realtime/
				realtime_providers.dart
				socket_io_service.dart
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
			map/application/
				machine_realtime_controller.dart
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

## High-level UX

### 1) Splash Screen
Goal: quick premium “brand moment” without custom assets.
- Centered rounded-square mark + `local_cafe_outlined` icon
- Soft scale + fade animation
- Tagline under the brand name
- Restores persisted session (if any) then navigates to Login / Home / Admin

### 2) Login + Register
- Uses real backend auth.
- Session (JWT + basic profile) is persisted locally.

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

### 4) Machine Selection
- Machine list is fetched from backend (`/machines/online`, JWT)
- If backend does not provide coordinates, the screen falls back to a list UI (no markers)

### 5) Product List Screen
- Vertical list of rounded cards
- Each row: icon placeholder, name, subtitle, price, chevron
- Tap → product detail

Stock uses backend product `stok` (global).

### 6) Product Detail Screen
- Large hero placeholder (no images required)
- Name, subtitle, price
- “About” section
- Quantity stepper
- Sticky bottom “Add to cart”

Guards:
- If no machine is selected, “Add to cart” is disabled
- If backend stock is 0, “Add to cart” is disabled

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

### 8) Checkout
- Creates payment via backend (`/payments/create`) and opens Midtrans Snap (WebView)

### 9) Transaction Status Screen
- Shows transaction status (Pending/Paid/Failed)
- Shows **Details** (transaction id, machine, customer info)
- Shows **Totals** (subtotal + service fee + tax + total)
- Shows **Items** list

### 10) Transaction History
- Fetches backend history (`/payments/my-history`, JWT)

### 11) Admin
- Admin role comes from backend `user.role == 'admin'`
- Admin dashboard reads backend metrics (`/machines/dashboard`, `/payments/transactions`)
- Admin stock updates backend product `stok` (global)

### 12) Admin Stock
- Updates product `stok` via backend `PATCH /products/:id`

### 13) Admin Transactions
- Uses backend list (`/payments/transactions`)

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
