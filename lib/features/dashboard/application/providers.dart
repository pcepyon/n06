import 'package:n06/features/daily_checkin/application/providers.dart' as checkin_providers;
import 'package:n06/features/dashboard/application/services/llm_context_builder.dart';
import 'package:n06/features/dashboard/domain/repositories/ai_message_repository.dart';
import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/infrastructure/repositories/supabase_ai_message_repository.dart';
import 'package:n06/features/dashboard/infrastructure/repositories/supabase_badge_repository.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';

part 'providers.g.dart';

@riverpod
BadgeRepository badgeRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseBadgeRepository(supabase);
}

@riverpod
AIMessageRepository aiMessageRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAIMessageRepository(supabase);
}

@riverpod
LLMContextBuilder llmContextBuilder(Ref ref) {
  final medicationRepository = ref.watch(tracking_providers.medicationRepositoryProvider);
  final trackingRepository = ref.watch(tracking_providers.trackingRepositoryProvider);
  final dailyCheckinRepository = ref.watch(checkin_providers.dailyCheckinRepositoryProvider);
  return LLMContextBuilder(
    medicationRepository: medicationRepository,
    trackingRepository: trackingRepository,
    dailyCheckinRepository: dailyCheckinRepository,
  );
}
