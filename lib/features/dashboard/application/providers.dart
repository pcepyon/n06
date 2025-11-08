import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/infrastructure/repositories/isar_badge_repository.dart';
import 'package:n06/features/onboarding/application/providers.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';

part 'providers.g.dart';

@riverpod
BadgeRepository badgeRepository(BadgeRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarBadgeRepository(isar);
}
