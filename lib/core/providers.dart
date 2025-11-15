import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Client Provider
///
/// Provides access to the globally initialized Supabase client instance.
/// The instance is initialized in main.dart before running the app.
///
/// This provider is watched by feature repositories to perform database operations.
/// keepAlive: true ensures the Supabase client is never disposed during the app lifecycle.
///
/// Note: This uses Provider instead of @riverpod because SupabaseClient
/// is an external type that cannot be code-generated.
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Global Isar Database Instance Provider (기존 유지 - Phase 1.8에서 제거)
///
/// Provides access to the globally initialized Isar database instance.
/// The instance must be initialized in main.dart before running the app.
///
/// This provider is watched by feature repositories to perform database operations.
/// keepAlive: true ensures the Isar instance is never disposed during the app lifecycle.
///
/// Note: This uses Provider instead of @riverpod because Isar
/// is an external type that cannot be code-generated.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be initialized via ProviderScope override in main.dart',
  );
});
