# CATRA – Calorie & Stock Tracker

CATRA helps you scan groceries, manage fridge inventory, and stay on top of daily calorie and sugar goals. The project targets Android, iOS, and Web (Chrome) on Flutter 3.38 (stable).

## Running the app

- **Install dependencies**
  ```bash
  flutter pub get
  ```
- **Android/iOS**
  ```bash
  flutter run -d <device_id>
  ```
  For iOS, open `ios/Runner.xcworkspace` to configure signing before running on physical devices.
- **Web (Chrome)**
  ```bash
  flutter run -d chrome
  ```
  On the web, barcode scanning falls back to manual entry when camera access is unavailable.

## Architecture & tech stack

- **State management:** `flutter_riverpod` with feature-scoped controllers and shared providers
- **Navigation:** `go_router` using a `StatefulShellRoute` to power the bottom navigation (Home, Scan, Fridge, History, Settings)
- **Local storage:** `hive`/`hive_flutter` for `Product`, `ConsumedEntry`, and `UserSettings` boxes (adapters generated via `build_runner`)
- **Notifications:** `flutter_local_notifications` for expiry reminders on mobile (graceful no-op on web)
- **Scanning & media:** `image_picker` for product photos that are analyzed through the CATRA Food AI endpoint
- **Styling:** Custom light/dark themes built on Material 3 + Google Fonts, shared widgets (`ProgressCard`, `EmptyState`, etc.)

## Feature highlights

- **Splash & onboarding:** Hive/notification initialization followed by a multi-step onboarding (profile, lifestyle, daily targets) or direct navigation into the main shell.
- **Home dashboard:** Riverpod-driven aggregation of today’s calories and sugar, quick actions, recent consumption, and “expiring soon” products with color-coded urgency.
- **Scan flow:** Live camera scanning on mobile, manual barcode entry everywhere, auto-lookup via a mocked nutrition service, and a full product form (photos, macros, expiry, stock/eaten actions).
- **Fridge management:** Live Hive streams with sort/filter options, consume/edit/remove actions, automatic quantity adjustments, and notification scheduling when items enter stock.
- **History:** Dual tabs (Eaten/Scanned) with search, daily grouping, and quick navigation into product details.
- **Settings:** Edit nutrition targets, notification preferences, theme mode (system/light/dark), profile details, and a “Clear all data” action that wipes every Hive box.

## Development notes

- Run the Hive code generator whenever you modify annotated models:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- Notifications schedule reminders two days before and on the expiry date (9 AM). Web builds skip native notifications automatically.
- The scan flow captures/uploads product photos, forwards them to the CATRA Food AI endpoint, and reuses the resulting macros throughout the app.

Happy tracking!
