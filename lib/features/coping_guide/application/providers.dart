import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/coping_guide_repository.dart';
import '../domain/repositories/feedback_repository.dart';
import '../infrastructure/repositories/memory_feedback_repository.dart';
import '../infrastructure/repositories/static_coping_guide_repository.dart';

part 'providers.g.dart';

@riverpod
CopingGuideRepository copingGuideRepository(Ref ref) {
  return StaticCopingGuideRepository();
}

@riverpod
FeedbackRepository feedbackRepository(Ref ref) {
  return MemoryFeedbackRepository();
}
