import 'package:flutter_riverpod/flutter_riverpod.dart';
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
