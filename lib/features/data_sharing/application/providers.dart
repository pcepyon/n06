import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/data_sharing/infrastructure/repositories/supabase_shared_data_repository.dart';
import 'package:n06/features/data_sharing/domain/repositories/shared_data_repository.dart';
import 'package:n06/core/providers.dart';

part 'providers.g.dart';

@riverpod
SharedDataRepository sharedDataRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseSharedDataRepository(supabase);
}
