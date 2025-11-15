import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/infrastructure/repositories/supabase_badge_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';

part 'providers.g.dart';

@riverpod
BadgeRepository badgeRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseBadgeRepository(supabase);
}
