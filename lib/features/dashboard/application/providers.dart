import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/infrastructure/repositories/supabase_badge_repository.dart';
// import 'package:n06/features/dashboard/infrastructure/repositories/isar_badge_repository.dart';  // Phase 1.8에서 제거
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/providers.dart';

part 'providers.g.dart';

@riverpod
BadgeRepository badgeRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseBadgeRepository(supabase);
}
