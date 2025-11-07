import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repositories/coping_guide_repository.dart';
import '../domain/repositories/feedback_repository.dart';
import '../infrastructure/repositories/isar_feedback_repository.dart';
import '../infrastructure/repositories/static_coping_guide_repository.dart';

part 'providers.g.dart';

/// Isar 인스턴스 Provider (from core)
@riverpod
Isar isar(IsarRef ref) {
  throw UnimplementedError('isarProvider must be implemented in core');
}

@riverpod
CopingGuideRepository copingGuideRepository(CopingGuideRepositoryRef ref) {
  return StaticCopingGuideRepository();
}

@riverpod
FeedbackRepository feedbackRepository(FeedbackRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarFeedbackRepository(isarInstance);
}
