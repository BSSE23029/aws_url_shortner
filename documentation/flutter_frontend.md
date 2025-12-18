Here is the detailed architectural document for the Flutter Frontend. It covers the specific "Single Source of Truth" pattern we implemented using Riverpod, the Responsive Design system, and the Analytics integration.

Save this as `04_Flutter_Frontend_Architecture_Detailed.md`.

---

```markdown
# 📱 Flutter Frontend Architecture: Rad Link

**Version:** 1.0 (Semester Release)
**Framework:** Flutter (3.x)
**Target Platforms:** Web (Primary), iOS/Android (Supported)
**Design System:** "Cyber-Glass" (Dark/Light mode compatible)

---

## 1. Core Tech Stack & Dependencies

The application avoids "bloat" by using a curated list of essential packages:

| Package | Purpose |
| :--- | :--- |
| **`flutter_riverpod`** | State Management & Dependency Injection. Used for Auth and Data synchronization. |
| **`go_router`** | Declarative Routing with advanced Redirection Guards (Authentication protection). |
| **`amazon_cognito_identity_dart_2`** | Direct interaction with AWS Cognito User Pools (SRP Protocol). |
| **`syncfusion_flutter_charts`** | Rendering High-performance Pie and Bar charts for the "Stupidity Dashboard". |
| **`phosphor_flutter`** | Consistent, professional vector icon set. |
| **`responsive_framework`** | Handles "Breakpoints" to switch between Mobile (Bottom Nav) and Desktop (Side Rail). |
| **`http`** | Basic networking for the custom `ApiClient` middleware. |

---

## 2. Project Structure (Feature-Layered)

The project follows a clean separation of concerns:

```text
lib/
├── main.dart                  # App Entry, Global Providers, Router Config
├── config.dart                # Environment variables (API URLs, Cognito IDs)
├── middleware/
│   └── api_client.dart        # Central Networking Layer (Interceptors, Logging, Error Handling)
├── models/
│   └── models.dart            # Data Classes (UrlModel, GlobalStatsModel, User)
├── providers/
│   ├── providers.dart         # Logic Layer (AuthNotifier, UrlsNotifier)
│   └── theme_provider.dart    # UI State (Theme Mode, Haptics)
├── theme/
│   └── app_theme.dart         # FlexColorScheme configuration
└── ui/
    ├── screens/
    │   ├── auth/              # Sign In, Sign Up, MFA screens
    │   ├── dashboard/         # DashboardScreen (Local Stats) & StatsScreen (Global Stats)
    │   ├── url/               # CreateUrl, UrlDetails
    │   └── settings/          # Profile, Appearance
    └── widgets/
        ├── glass_card.dart    # Core UI component (Glassmorphism)
        ├── stealth_rail.dart  # Desktop Navigation Sidebar
        └── ...
```

---

## 3. State Management Strategy (The "Brain")

We utilize **Riverpod** to implement a "Single Source of Truth" architecture.

### A. The `UrlsNotifier` (Data Engine)

This is the central controller for the application. It manages a complex state object called `UrlsState`.

**State Composition:**

```dart
class UrlsState {
  final List<UrlModel> urls;            // User's personal links
  final GlobalStatsModel globalStats;   // System-wide "Stupidity" stats
  final bool isLoading;
  final String? errorMessage;
}
```

**The "Mega-Sync" Pattern:**
Instead of managing multiple API calls, the app calls `loadDashboard()` once on startup.

1. **Fetch:** Calls `ApiClient.getDashboardSync()`.
2. **Parse:** Deserializes the JSON into `List<UrlModel>` and `GlobalStatsModel`.
3. **Store:** Updates `urlsProvider` in memory.
4. **UI Update:** All widgets (Dashboard, Stats Screen, URL List) rebuild automatically.

### B. Client-Side Calculation

To reduce backend costs, "Local" metrics are calculated on the fly in Dart:

* **My Total Clicks:** `state.urls.fold(0, (sum, item) => sum + item.clickCount)`
* **Active Links:** `state.urls.length`

---

## 4. UI/UX Architecture

### A. Responsive Layout System

The app adapts to the screen size using `responsive_framework`:

* **Mobile (< 600px):** Uses standard `BottomNavigationBar`.
* **Desktop (> 600px):** Switches to `StealthRail` (Custom vertical sidebar with glassmorphism).

### B. Navigation & Guards (`go_router`)

Authentication security is handled at the Router level, not the UI level.

* **Redirect Logic:**
  * If `!isAuthenticated` -> Force to `/signin`.
  * If `isAuthenticated` AND trying to access Login -> Force to `/dashboard`.
  * If `confirmationRequired` (Email not verified) -> Force to `/mfa`.

### C. Visual Style (Cyber-Glass)

* **Components:** Almost all content is wrapped in `GlassCard`, which provides a semi-transparent background with a subtle border and blur effect.
* **Charts:** Syncfusion charts are styled to match the theme (removing grid lines, using theme colors).

---

## 5. Data Models

### Global Stats (The "Stupidity" Data)

This model powers the public analytics screen.

```dart
class GlobalStatsModel {
  final int totalSystemClicks;        // "Total Redirects"
  final int totalSystemLinks;         // "Total Links Created"
  final Map<String, int> osDistribution;  // Pie Chart Data (Android vs iOS)
  final Map<String, int> geoDistribution; // Bar Chart Data (Countries)
}
```

### URL Model

This represents a single link.

```dart
class UrlModel {
  final String shortCode;   // The Alias
  final String originalUrl; // The Destination
  final String shortUrl;    // Full HTTPS link (https://api.razasoft.tech/alias)
  final int clickCount;     // Analytics
  final String userId;      // Owner
}
```

---

## 6. Critical Data Flows

### A. Dashboard Initialization

1. `DashboardScreen` mounts.
2. `initState` triggers `ref.read(urlsProvider.notifier).loadDashboard()`.
3. **Loading State:** UI shows `CircularProgressIndicator`.
4. **Success:** `UrlsState` is populated. UI renders Local Stats (Row 1) and Global Stats (Row 2).

### B. URL Creation

1. User enters `reddit.com`.
2. `UrlsNotifier.createUrl()` calls API.
3. **Success:** API returns the *created object*.
4. **Optimistic-Like Update:** The new object is prepended to the local `state.urls` list immediately using `state.copyWith(urls: [newUrl, ...state.urls])`.
5. **Result:** The user sees the new link in the list instantly without reloading the dashboard.

### C. Error Handling

* **Network Errors:** Caught in `ApiClient`, passed to `UrlsState.errorMessage`.
* **UI Feedback:** `DashboardScreen` listens to state changes. If `errorMessage` is not null, it displays a `SnackBar`.

---

## 7. Security & Networking

* **Networking:** Uses `http` client.
* **Authorization:** Every request (except Login/Signup) injects the `Authorization: Bearer <token>` header automatically via `ApiClient`.
* **Base URL:** Configured in `lib/config.dart` pointing to the AWS HTTP API Gateway.

```

```
