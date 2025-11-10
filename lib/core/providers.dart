import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Global Isar Database Instance Provider
///
/// Provides access to the globally initialized Isar database instance.
/// The instance must be initialized in main.dart before running the app.
///
/// This provider is watched by feature repositories to perform database operations.
/// keepAlive: true ensures the Isar instance is never disposed during the app lifecycle.
@Riverpod(keepAlive: true)
Isar isar(IsarRef ref) {
  throw UnimplementedError(
    'isarProvider must be initialized via ProviderScope override in main.dart',
  );
}
