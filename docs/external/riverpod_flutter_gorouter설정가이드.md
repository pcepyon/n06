# Flutter + Riverpod + GoRouter Implementation Guide

> **Target Stack**: Flutter 3.38.1, Dart 3.10.0, Riverpod 3.0.3, go_router 17.0.0  
> **Architecture**: 4-Layer Clean Architecture with Repository Pattern  
> **Last Updated**: November 2025

---

## Table of Contents

1. [Version Compatibility & Known Issues](#version-compatibility--known-issues)
2. [Installation & Setup](#installation--setup)
3. [Riverpod Code Generation](#riverpod-code-generation)
4. [4-Layer Architecture Integration](#4-layer-architecture-integration)
5. [GoRouter Setup with Riverpod](#gorouter-setup-with-riverpod)
6. [Repository Pattern Implementation](#repository-pattern-implementation)
7. [Testing Setup](#testing-setup)
8. [Common Patterns](#common-patterns)
9. [Troubleshooting](#troubleshooting)

---

## Version Compatibility & Known Issues

### Verified Compatible Versions

```yaml
environment:
  sdk: '>=3.10.0 <4.0.0'  # Dart 3.10.0
  flutter: '>=3.38.1'     # Flutter 3.38.1

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.3        # State management
  riverpod_annotation: ^3.0.3     # Code generation annotations
  go_router: ^17.0.0              # Navigation

dev_dependencies:
  build_runner: ^2.4.0            # Code generation runner
  riverpod_generator: ^3.0.3      # Provider code generator
  riverpod_lint: ^3.0.3           # Linting rules
  custom_lint: ^0.7.0             # Custom linting framework
```

### Known Issues & Workarounds

**Issue 1: Dart 3.10.0 Dot-Shorthands with Riverpod**

Dart 3.10 introduced dot-shorthands syntax (e.g., `MainAxisAlignment.start` → `.start`). Riverpod 3.0.3 may have compatibility issues with this feature.

**Workaround**:
```yaml
# analysis_options.yaml
analyzer:
  language:
    # Disable dot-shorthands if you encounter errors
    # strict-casts: true
    # strict-inference: true
    # strict-raw-types: true
```

**Issue 2: go_router Auto-Dispose Warning**

GoRouter instances should not be auto-disposed in Riverpod. Use the legacy Provider syntax for GoRouter.

**Workaround**:
```dart
// ✅ Correct - non-generated provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(/* config */);
});

// ❌ Avoid - code generation for GoRouter
// @riverpod
// GoRouter router(RouterRef ref) { ... }  // Will cause disposal issues
```

---

## Installation & Setup

### Step 1: Install Dependencies

```bash
flutter pub add flutter_riverpod riverpod_annotation go_router
flutter pub add dev:build_runner dev:riverpod_generator dev:riverpod_lint dev:custom_lint
```

### Step 2: Configure Analysis Options

Create or update `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
```

### Step 3: Project Structure Setup

```
lib/
├── core/
│   ├── routing/
│   │   └── app_router.dart           # GoRouter configuration
│   └── utils/
├── features/
│   ├── authentication/
│   ├── tracking/
│   │   ├── presentation/
│   │   ├── application/
│   │   │   ├── notifiers/            # Riverpod Notifiers
│   │   │   └── providers.dart        # Provider exports
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── usecases/
│   │   │   └── repositories/         # Repository interfaces
│   │   └── infrastructure/
│   │       ├── repositories/         # Repository implementations
│   │       └── datasources/
│   └── dashboard/
└── main.dart
```

---

## Riverpod Code Generation

### Basic Setup

Every file using code generation needs this boilerplate:

```dart
// my_feature.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'my_feature.g.dart';  // Generated file

// Your providers go here
```

### Running Code Generation

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
dart run build_runner watch --delete-conflicting-outputs
```

### Provider Types in Riverpod 3.0

#### 1. Simple Provider (Synchronous)

```dart
// application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
String appTitle(Ref ref) {
  return 'GLP-1 Tracker';
}

// Usage in widgets:
// final title = ref.watch(appTitleProvider);
```

#### 2. FutureProvider (Async Single Value)

```dart
@riverpod
Future<UserProfile> userProfile(Ref ref, String userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile(userId);
}

// Usage:
// final profileAsync = ref.watch(userProfileProvider(userId));
// profileAsync.when(
//   data: (profile) => Text(profile.name),
//   loading: () => CircularProgressIndicator(),
//   error: (err, stack) => Text('Error: $err'),
// )
```

#### 3. StreamProvider (Reactive Data)

```dart
@riverpod
Stream<List<Dose>> doses(Ref ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.watchDoses();
}
```

#### 4. Notifier (Mutable State)

For complex, mutable state:

```dart
// application/notifiers/dose_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dose_notifier.g.dart';

@riverpod
class DoseNotifier extends _$DoseNotifier {
  @override
  List<Dose> build() {
    // Initial state
    return [];
  }

  Future<void> addDose(Dose dose) async {
    final repository = ref.read(medicationRepositoryProvider);
    await repository.saveDose(dose);
    
    // Update state
    state = [...state, dose];
  }

  void removeDose(String doseId) {
    state = state.where((d) => d.id != doseId).toList();
  }
}

// Usage:
// final doses = ref.watch(doseNotifierProvider);
// ref.read(doseNotifierProvider.notifier).addDose(newDose);
```

#### 5. AsyncNotifier (Async Mutable State)

For async state with loading/error handling:

```dart
@riverpod
class WeightHistory extends _$WeightHistory {
  @override
  Future<List<WeightLog>> build(String userId) async {
    // Async initialization
    final repository = ref.watch(trackingRepositoryProvider);
    return repository.getWeightLogs(userId);
  }

  Future<void> addWeight(WeightLog log) async {
    // Show loading state
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      await repository.saveWeightLog(log);
      
      // Return updated list
      final current = await state.value ?? [];
      return [...current, log];
    });
  }
}
```

### Auto-Dispose Behavior

**Riverpod 3.0**: All code-generated providers are **auto-dispose by default**.

```dart
// Auto-dispose (default)
@riverpod
int counter(Ref ref) => 0;

// Keep alive
@Riverpod(keepAlive: true)
int persistentCounter(Ref ref) => 0;
```

### Provider Parameters (formerly .family)

No more `.family` modifier needed!

```dart
// Multiple parameters supported
@riverpod
Future<User> fetchUser(
  Ref ref, {
  required String userId,
  bool includeMetadata = false,
}) async {
  // Implementation
}

// Usage:
// ref.watch(fetchUserProvider(userId: '123', includeMetadata: true))
```

---

## 4-Layer Architecture Integration

### Layer Overview

```
Presentation → Application → Domain ← Infrastructure
```

| Layer | Uses Riverpod For | Example |
|-------|-------------------|---------|
| **Presentation** | Watching state, triggering actions | `ref.watch(doseNotifierProvider)` |
| **Application** | State management, UseCase orchestration | Notifiers, Providers |
| **Domain** | Pure business logic (NO Riverpod) | Entities, UseCases, Repository interfaces |
| **Infrastructure** | Data access (Riverpod for DI only) | Repository implementations |

### Domain Layer (No Riverpod)

```dart
// domain/entities/dose.dart
class Dose {
  final String id;
  final double doseMg;
  final DateTime administeredAt;

  Dose({required this.id, required this.doseMg, required this.administeredAt});
  
  // JSON serialization for Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'dose_mg': doseMg,
    'administered_at': administeredAt.toIso8601String(),
  };

  factory Dose.fromJson(Map<String, dynamic> json) => Dose(
    id: json['id'],
    doseMg: (json['dose_mg'] as num).toDouble(),
    administeredAt: DateTime.parse(json['administered_at']),
  );
}

// domain/repositories/medication_repository.dart
abstract class MedicationRepository {
  Stream<List<Dose>> watchDoses();
  Future<void> saveDose(Dose dose);
  Future<void> deleteDose(String doseId);
}
```

### Infrastructure Layer (Implementation)

```dart
// infrastructure/repositories/supabase_medication_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dose.dart';
import '../../domain/repositories/medication_repository.dart';

class SupabaseMedicationRepository implements MedicationRepository {
  final SupabaseClient supabase;

  SupabaseMedicationRepository(this.supabase);

  @override
  Stream<List<Dose>> watchDoses() {
    return supabase
        .from('dose_records')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => Dose.fromJson(json)).toList());
  }

  @override
  Future<void> saveDose(Dose dose) async {
    await supabase.from('dose_records').insert(dose.toJson());
  }

  @override
  Future<void> deleteDose(String doseId) async {
    await supabase.from('dose_records').delete().eq('id', doseId);
  }
}
```

### Application Layer (Providers & DI)

```dart
// application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../infrastructure/repositories/supabase_medication_repository.dart';

part 'providers.g.dart';

// Supabase client provider
@riverpod
SupabaseClient supabase(Ref ref) {
  return Supabase.instance.client;
}

// Repository provider (DI)
@riverpod
MedicationRepository medicationRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationRepository(supabase);
}

// Stream provider for doses
@riverpod
Stream<List<Dose>> doses(Ref ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.watchDoses();
}
```

### Presentation Layer (Widgets)

```dart
// presentation/widgets/dose_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';

class DoseList extends ConsumerWidget {
  const DoseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(dosesProvider);

    return dosesAsync.when(
      data: (doses) => ListView.builder(
        itemCount: doses.length,
        itemBuilder: (context, index) {
          final dose = doses[index];
          return ListTile(
            title: Text('${dose.doseMg} mg'),
            subtitle: Text(dose.administeredAt.toString()),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
```

---

## GoRouter Setup with Riverpod

### Basic Router Configuration

```dart
// core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Use legacy Provider (non-generated) for GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/tracking',
        name: 'tracking',
        builder: (context, state) => const TrackingPage(),
      ),
      GoRoute(
        path: '/profile/:userId',
        name: 'profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfilePage(userId: userId);
        },
      ),
    ],
  );
});
```

### Main App Setup

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'GLP-1 Tracker',
      routerConfig: router,
      theme: ThemeData.light(),
    );
  }
}
```

### Authentication-Based Redirects

```dart
// features/authentication/application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    // Check authentication status
    final supabase = ref.watch(supabaseProvider);
    return supabase.auth.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    });
  }

  Future<void> signOut() async {
    await ref.read(supabaseProvider).auth.signOut();
    state = const AsyncValue.data(null);
  }
}

// core/routing/app_router.dart
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // Read auth state
      final authAsync = ref.read(authStateProvider);
      
      // Handle loading state
      if (authAsync.isLoading) return null;
      
      final isAuthenticated = authAsync.value != null;
      final isLoginPage = state.matchedLocation == '/login';
      
      // Redirect logic
      if (!isAuthenticated && !isLoginPage) {
        return '/login';  // Not authenticated → go to login
      }
      if (isAuthenticated && isLoginPage) {
        return '/home';   // Already authenticated → go to home
      }
      
      return null;  // No redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      // Protected routes...
    ],
  );
});
```

### Reactive Router (Advanced)

For more complex scenarios where the router needs to rebuild on auth changes:

```dart
// features/authentication/application/auth_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier implements Listenable {
  VoidCallback? _listener;

  @override
  Future<User?> build() async {
    // Listen to auth state changes
    final supabase = ref.watch(supabaseProvider);
    ref.listen(
      supabaseAuthStreamProvider,
      (previous, next) {
        // Notify GoRouter when auth changes
        _listener?.call();
      },
    );
    
    return supabase.auth.currentUser;
  }

  @override
  void addListener(VoidCallback listener) {
    _listener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _listener = null;
  }
}

// Update GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  
  return GoRouter(
    refreshListenable: authNotifier,  // Rebuild on auth changes
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      // ... redirect logic
    },
    routes: [/* ... */],
  );
});
```

### Navigation Without Context

```dart
// application/notifiers/form_notifier.dart
@riverpod
class FormNotifier extends _$FormNotifier {
  @override
  FormState build() => FormState.initial();

  Future<void> submitForm() async {
    state = state.copyWith(isSubmitting: true);
    
    try {
      // Save data
      await ref.read(repositoryProvider).saveData();
      
      // Navigate without BuildContext
      final router = ref.read(goRouterProvider);
      router.go('/success');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
```

---

## Repository Pattern Implementation

### Step 1: Define Interface (Domain)

```dart
// features/tracking/domain/repositories/tracking_repository.dart
abstract class TrackingRepository {
  // Weight logs
  Future<List<WeightLog>> getWeightLogs(String userId);
  Future<void> saveWeightLog(WeightLog log);
  Stream<List<WeightLog>> watchWeightLogs(String userId);
  
  // Symptom logs
  Future<List<SymptomLog>> getSymptomLogs(String userId);
  Future<void> saveSymptomLog(SymptomLog log);
}
```

### Step 2: Implement with Supabase (Infrastructure)

```dart
// features/tracking/infrastructure/repositories/supabase_tracking_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/weight_log.dart';
import '../../domain/repositories/tracking_repository.dart';

class SupabaseTrackingRepository implements TrackingRepository {
  final SupabaseClient supabase;

  SupabaseTrackingRepository(this.supabase);

  @override
  Future<List<WeightLog>> getWeightLogs(String userId) async {
    final response = await supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false);
    
    return response.map((json) => WeightLog.fromJson(json)).toList();
  }

  @override
  Future<void> saveWeightLog(WeightLog log) async {
    await supabase.from('weight_logs').insert(log.toJson());
  }

  @override
  Stream<List<WeightLog>> watchWeightLogs(String userId) {
    return supabase
        .from('weight_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .map((data) => data.map((json) => WeightLog.fromJson(json)).toList());
  }

  @override
  Future<List<SymptomLog>> getSymptomLogs(String userId) async {
    final response = await supabase
        .from('symptom_logs')
        .select()
        .eq('user_id', userId);
    
    return response.map((json) => SymptomLog.fromJson(json)).toList();
  }

  @override
  Future<void> saveSymptomLog(SymptomLog log) async {
    await supabase.from('symptom_logs').insert(log.toJson());
  }
}
```

### Step 3: Provide with Riverpod (Application)

```dart
// features/tracking/application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/tracking_repository.dart';
import '../infrastructure/repositories/supabase_tracking_repository.dart';

part 'providers.g.dart';

@riverpod
TrackingRepository trackingRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTrackingRepository(supabase);
}

// Weight logs stream
@riverpod
Stream<List<WeightLog>> weightLogs(Ref ref, String userId) {
  final repository = ref.watch(trackingRepositoryProvider);
  return repository.watchWeightLogs(userId);
}

// Symptom logs future
@riverpod
Future<List<SymptomLog>> symptomLogs(Ref ref, String userId) async {
  final repository = ref.watch(trackingRepositoryProvider);
  return repository.getSymptomLogs(userId);
}
```

### Step 4: Use in Presentation

```dart
// presentation/screens/tracking_screen.dart
class TrackingScreen extends ConsumerWidget {
  final String userId;
  
  const TrackingScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightLogsAsync = ref.watch(weightLogsProvider(userId));

    return weightLogsAsync.when(
      data: (logs) => WeightLogsList(logs: logs),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

## Testing Setup

### Unit Testing Repositories

```dart
// test/features/tracking/infrastructure/repositories/supabase_tracking_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockSupabase;
  late SupabaseTrackingRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = SupabaseTrackingRepository(mockSupabase);
  });

  group('SupabaseTrackingRepository', () {
    test('getWeightLogs returns list of weight logs', () async {
      // Arrange
      when(() => mockSupabase.from('weight_logs').select().eq(any(), any()))
          .thenAnswer((_) async => [
                {'id': '1', 'user_id': 'user1', 'weight_kg': 70.0, 'recorded_at': '2025-01-01'},
              ]);

      // Act
      final result = await repository.getWeightLogs('user1');

      // Assert
      expect(result, isA<List<WeightLog>>());
      expect(result.length, 1);
      expect(result.first.weightKg, 70.0);
    });
  });
}
```

### Widget Testing with Riverpod

```dart
// test/features/tracking/presentation/tracking_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('TrackingScreen displays weight logs', (tester) async {
    // Mock provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightLogsProvider('user1').overrideWith((ref) {
            return Stream.value([
              WeightLog(id: '1', userId: 'user1', weightKg: 70.0, recordedAt: DateTime.now()),
            ]);
          }),
        ],
        child: const MaterialApp(
          home: TrackingScreen(userId: 'user1'),
        ),
      ),
    );

    // Wait for async data
    await tester.pumpAndSettle();

    // Verify
    expect(find.text('70.0 kg'), findsOneWidget);
  });
}
```

---

## Common Patterns

### Pattern 1: Shared Data Across Features

```dart
// ✅ Correct: Import from owning feature
// features/dashboard/application/dashboard_notifier.dart
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;

@riverpod
class DashboardData extends _$DashboardData {
  @override
  Future<DashboardState> build(String userId) async {
    // Access tracking repository
    final trackingRepo = ref.watch(tracking_providers.trackingRepositoryProvider);
    final weights = await trackingRepo.getWeightLogs(userId);
    
    return DashboardState(weightTrend: weights);
  }
}
```

### Pattern 2: Multiple Repository Coordination

```dart
@riverpod
class ReportGenerator extends _$ReportGenerator {
  @override
  Future<Report> build(String userId) async {
    // Fetch from multiple repositories
    final trackingRepo = ref.watch(trackingRepositoryProvider);
    final profileRepo = ref.watch(profileRepositoryProvider);
    
    final [weights, symptoms, profile] = await Future.wait([
      trackingRepo.getWeightLogs(userId),
      trackingRepo.getSymptomLogs(userId),
      profileRepo.getUserProfile(userId),
    ]);
    
    return Report.generate(weights, symptoms, profile);
  }
}
```

### Pattern 3: Error Handling

```dart
@riverpod
class DataSync extends _$DataSync {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> syncData() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(repositoryProvider).syncToServer();
      } on NetworkException {
        throw 'Network error. Please check your connection.';
      } on TimeoutException {
        throw 'Request timed out. Please try again.';
      }
    });
  }
}

// In widget
final syncState = ref.watch(dataSyncProvider);
syncState.maybeWhen(
  error: (err, _) => SnackBar(content: Text(err.toString())),
  orElse: () => const SizedBox.shrink(),
);
```

### Pattern 4: Debounced Search

```dart
@riverpod
class SearchQuery extends _$SearchQuery {
  Timer? _debounce;

  @override
  String build() => '';

  void updateQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = query;
    });
  }
}

@riverpod
Future<List<Result>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(searchRepositoryProvider);
  return repository.search(query);
}
```

---

## Troubleshooting

### Error: "Bad state: Cannot modify providers..."

**Cause**: Trying to call `ref.read()` during widget build.

**Solution**:
```dart
// ❌ Wrong
Widget build(BuildContext context, WidgetRef ref) {
  ref.read(counterProvider.notifier).increment();  // Error!
  return Text('Count: ${ref.watch(counterProvider)}');
}

// ✅ Correct
Widget build(BuildContext context, WidgetRef ref) {
  return ElevatedButton(
    onPressed: () {
      ref.read(counterProvider.notifier).increment();  // OK in callback
    },
    child: Text('Count: ${ref.watch(counterProvider)}'),
  );
}
```

### Error: "Provider was disposed before being read"

**Cause**: Auto-dispose provider accessed after disposal.

**Solution**:
```dart
// Option 1: Keep provider alive
@Riverpod(keepAlive: true)
int persistentCounter(Ref ref) => 0;

// Option 2: Prevent disposal
ref.keepAlive();  // Inside provider build method
```

### Error: "GoRouterState location is null"

**Cause**: Accessing state too early in redirect.

**Solution**:
```dart
redirect: (context, state) {
  // ✅ Use matchedLocation instead of location
  final currentPath = state.matchedLocation;
  
  if (currentPath == '/protected' && !isAuthenticated) {
    return '/login';
  }
  return null;
}
```

### Code Generation Not Working

```bash
# Step 1: Clean
flutter clean
dart run build_runner clean

# Step 2: Delete generated files
find . -name "*.g.dart" -delete

# Step 3: Regenerate
dart run build_runner build --delete-conflicting-outputs

# Step 4: If still failing, check for syntax errors
dart analyze
```

### Circular Dependency Errors

**Problem**:
```dart
// Feature A depends on Feature B
// Feature B depends on Feature A
```

**Solution**: Refactor shared code into Application Layer
```dart
// ✅ Create coordinator in Application Layer
@riverpod
class DataCoordinator extends _$DataCoordinator {
  @override
  Future<CombinedData> build() async {
    final repoA = ref.watch(repositoryAProvider);
    final repoB = ref.watch(repositoryBProvider);
    
    return CombinedData(
      dataA: await repoA.fetch(),
      dataB: await repoB.fetch(),
    );
  }
}
```

---

## Quick Reference

### Riverpod Provider Syntax

| Old (Riverpod 2.x) | New (Riverpod 3.0 with codegen) |
|--------------------|----------------------------------|
| `Provider<String>` | `@riverpod String myProvider(Ref ref)` |
| `FutureProvider<User>` | `@riverpod Future<User> user(Ref ref)` |
| `StreamProvider<List<Dose>>` | `@riverpod Stream<List<Dose>> doses(Ref ref)` |
| `StateNotifierProvider` | `@riverpod class MyNotifier extends _$MyNotifier` |
| `Provider.family<String, int>` | `@riverpod String myProvider(Ref ref, int id)` |
| `Provider.autoDispose` | (Auto-dispose by default in codegen) |

### GoRouter Navigation

```dart
// Navigate to route
context.go('/home');                    // Replace current route
context.push('/details');               // Push new route
context.pop();                          // Pop current route

// With parameters
context.go('/user/123');                // Path parameter
context.go('/search?q=flutter');        // Query parameter

// Named routes
context.goNamed('home');
context.pushNamed('details', pathParameters: {'id': '123'});

// Without context (using Riverpod)
ref.read(goRouterProvider).go('/home');
```

---

## Additional Resources

- [Official Riverpod Docs](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Clean Architecture Example](https://github.com/lucavenir/go_router_riverpod)
- [Andrea Bizzotto's Flutter Courses](https://codewithandrea.com/)

---

**Last Updated**: November 2025  
**Tested With**: Flutter 3.38.1, Dart 3.10.0, Riverpod 3.0.3, go_router 17.0.0