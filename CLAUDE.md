# Expense Tracker - Project Instructions

## Project Overview
Multi-account expense tracking app with Firebase backend, Cloudinary image uploads, real-time chat, role-based access, and push notifications.

## Tech Stack
- **Framework**: Flutter (SDK ^3.11.0)
- **State Management**: Provider (ChangeNotifier)
- **Navigation**: GoRouter with auth redirect + ShellRoute
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Image Uploads**: Cloudinary (unsigned preset)
- **Charts**: fl_chart
- **Icons**: iconsax
- **Local Storage**: SharedPreferences, Hive

## Architecture

### Folder Structure (Feature-based)
```
lib/
├── main.dart              # Entry point, MultiProvider setup
├── app.dart               # MaterialApp.router with theme
├── firebase_options.dart  # Firebase config (generated)
├── core/                  # Shared across all features
│   ├── config/            # Routes (GoRouter)
│   ├── constants/         # App constants, Firestore paths, Cloudinary, categories
│   ├── theme/             # AppColors, AppTextStyles, AppTheme (light + dark)
│   ├── utils/             # Responsive, Validators, Formatters, MonthKeyHelper
│   └── widgets/           # Reusable widgets (buttons, inputs, cards)
└── features/              # Each feature is self-contained
    └── {feature}/
        ├── data/
        │   ├── models/    # Data classes with fromMap/toMap/copyWith
        │   └── services/  # Firestore/API service classes
        └── presentation/
            ├── providers/ # ChangeNotifier state management
            ├── screens/   # Full page widgets
            └── widgets/   # Feature-specific widgets
```

### Naming Conventions
- **Files**: snake_case (e.g., `auth_provider.dart`, `user_model.dart`)
- **Classes**: PascalCase (e.g., `AuthProvider`, `UserModel`)
- **Constants class**: Private constructor `ClassName._()` (non-instantiable)
- **Models**: suffix `Model` (e.g., `ExpenseModel`, `AccountModel`)
- **Services**: suffix `Service` (e.g., `AuthService`, `ExpenseService`)
- **Providers**: suffix `Provider` (e.g., `KhataProvider`, `ChatProvider`)
- **Screens**: suffix `Screen` (e.g., `DashboardScreen`, `LoginScreen`)

### Provider Pattern
- Extend `ChangeNotifier`
- Private fields with public getters
- `_isLoading`, `_error` pattern for async operations
- `_setLoading(bool)` helper method
- `clearError()` method
- `notifyListeners()` after state changes
- Try/catch with `debugPrint('[TAG] method error: $e')`

### Model Pattern
- `fromMap(Map<String, dynamic> map, String id)` factory constructor
- `toMap()` returns `Map<String, dynamic>`
- `copyWith()` for immutable updates
- Firestore `Timestamp` ↔ `DateTime` conversion in fromMap/toMap
- Lists default to `const []` in constructor

### Service Pattern
- Direct Firestore access via `FirebaseFirestore.instance`
- Collection references as getters or methods
- Return model objects, not raw documents
- No state — pure data access layer

### Route Pattern
- `AppRoutes` class: static const String paths
- `AppRouter` class: `createRouter(AuthProvider)` factory
- Auth redirect: unauthenticated → welcome, authenticated → skip auth routes
- ShellRoute for bottom navigation tabs
- Path parameters: `/khata/:accountId/expense/:expenseId`
- `NoTransitionPage` for shell tab routes

## Design Theme
| Role | Color | Hex |
|------|-------|-----|
| Primary | Emerald Green | `#10B981` |
| Secondary | Soft Blue | `#3B82F6` |
| Accent | Orange | `#F97316` |
| Background | Slate 50 | `#F8FAFC` |
| Dark BG | Slate 900 | `#0F172A` |

## Firestore Structure
```
users/{userId}           → name, email, phone, photoUrl, accountIds[], fcmToken, createdAt
accounts/{accountId}     → name, trackingType, totalBudget, createdBy, createdAt
  /members/{userId}      → userId, name, email, role (owner|editor|viewer), joinedAt
  /expenses/{expenseId}  → amount, category, description, date, addedBy, monthKey?, receiptUrl?, createdAt
  /invites/{inviteId}    → email, role, invitedBy, accountName, accountId, status, createdAt
  /chats/{messageId}     → senderId, senderName, message, createdAt
notifications/{userId}/items/{id} → type, title, body, accountId?, isRead, createdAt
```

## Firebase Config
- **Project ID**: expense-tracker-farid
- **Account**: faridislam.me@gmail.com
- **Android package**: com.expensetracker.expense_tracker
- **iOS bundle**: com.expensetracker.expenseTracker

## Cloudinary Config
- **Cloud name**: defisxnj1
- **Upload preset**: expense_tracker (unsigned)
- **Folders**: expense_tracker/receipts, expense_tracker/profiles

## Key Design Decisions
1. **Phone auth** → `signInAnonymously()` + stores phone in user doc
2. **Monthly tracking** → `monthKey` field ("2026-03") on expenses; filter, not delete
3. **Account membership** → `accountIds[]` on user doc, batch-fetch by ID
4. **Invite lookup** → collectionGroup query where email == currentUser.email
5. **Category summaries** → Computed client-side from expense list
6. **Cloudinary** → Unsigned upload preset via `http` MultipartRequest
7. **Dark mode** → Persisted via SharedPreferences, driven by SettingsProvider

## Rules
- Don't run `flutter run` — user runs it in a separate terminal
- Always use Provider pattern (not Riverpod, Bloc, etc.)
- Always use GoRouter for navigation (not Navigator 1.0)
- Always use feature-based folder structure
- Use `Timestamp` for Firestore dates, convert to `DateTime` in models
- Use `withValues(alpha:)` instead of deprecated `withOpacity()`
- Avoid `context.read/watch` across async gaps — capture provider before await
- Commit all changes at end in a single commit for easy revert
