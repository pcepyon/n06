import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/dashboard/application/providers.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/dashboard/application/services/llm_context_builder.dart';
import 'package:n06/features/dashboard/domain/entities/ai_generated_message.dart';
import 'package:n06/features/dashboard/domain/repositories/ai_message_repository.dart';
import 'package:n06/features/onboarding/application/providers.dart'
    as onboarding_providers;
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_message_notifier.g.dart';

/// Notifier for AI-generated contextual messages.
///
/// Manages message generation timing:
/// - Daily first open: Checks if message exists for today, generates if not
/// - Post check-in: Regenerates message with updated data
///
/// Follows CLAUDE.md AsyncNotifier safety patterns:
/// - Dependencies captured in build()
/// - keepAlive + mounted checks in mutations
/// - No ref access after async gaps
@riverpod
class AIMessageNotifier extends _$AIMessageNotifier {
  // ✅ 1. 의존성을 late final 필드로 선언 (getter 사용 금지 - BUG-20251205)
  late final AIMessageRepository _repository;
  late final LLMContextBuilder _contextBuilder;

  @override
  Future<AIGeneratedMessage?> build() async {
    // ✅ 2. build() 시작부에서 모든 ref 의존성 캡처
    _repository = ref.read(aiMessageRepositoryProvider);
    _contextBuilder = ref.read(llmContextBuilderProvider);

    // 하루 첫 접속 체크 후 메시지 로드/생성
    return _loadOrGenerateMessage();
  }

  /// Loads existing message for today or generates a new one if needed.
  ///
  /// This is called on daily first open. If a message already exists for today,
  /// returns cached message. Otherwise, generates new message.
  Future<AIGeneratedMessage?> _loadOrGenerateMessage() async {
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) return null;

    // 1. 오늘 이미 생성된 메시지가 있는지 확인
    final todayMessage = await _repository.getTodayMessage(userId);
    if (todayMessage != null) {
      return todayMessage; // 캐시된 메시지 반환
    }

    // 2. 없으면 새 메시지 생성
    return _generateNewMessage(
      triggerType: MessageTriggerType.dailyFirstOpen,
    );
  }

  /// Regenerates message after check-in completion.
  ///
  /// This method is called by the check-in flow after saving a check-in.
  /// Parameters:
  /// - [checkinSummary]: Optional summary of today's check-in data
  Future<void> regenerateForCheckin({String? checkinSummary}) async {
    // ✅ 3. mutation에서 keepAlive (작업 완료 보장)
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      final newMessage = await _generateNewMessage(
        triggerType: MessageTriggerType.postCheckin,
        checkinSummary: checkinSummary,
      );

      // ✅ 4. async gap 후 mounted 체크
      if (!ref.mounted) return;
      state = AsyncData(newMessage);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    } finally {
      // ✅ 5. 메모리 누수 방지
      link.close();
    }
  }

  /// Generates a new AI message based on current context.
  ///
  /// Steps:
  /// 1. Gather dashboard data, dosage plan, trend insight
  /// 2. Build LLM context using LLMContextBuilder
  /// 3. Call repository.generateMessage() which triggers Edge Function
  /// 4. Return generated message
  Future<AIGeneratedMessage?> _generateNewMessage({
    required MessageTriggerType triggerType,
    String? checkinSummary,
  }) async {
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) return null;

    try {
      // 1. Gather dashboard data
      final dashboardState = ref.read(dashboardNotifierProvider);
      final dashboardData = dashboardState.value;
      if (dashboardData == null) {
        // Dashboard data not ready yet, return null
        return null;
      }

      // 2. Get dosage plan
      final dosagePlan = await ref
          .read(onboarding_providers.medicationRepositoryProvider)
          .getActiveDosagePlan(userId);
      if (dosagePlan == null) {
        return null;
      }

      // 3. Get trend insight (nullable) - we'll pass null if not available
      TrendInsight? trendInsight;
      // Trend insight is optional, don't fail if not available

      // 4. Get recent messages (for tone consistency)
      final recentMessages = await _repository.getRecentMessages(
        userId,
        limit: 7,
      );

      // 5. Build LLM context
      final context = await _contextBuilder.buildContext(
        dashboardData: dashboardData,
        dosagePlan: dosagePlan,
        trendInsight: trendInsight,
        recentMessages: recentMessages,
        triggerType: triggerType,
        recentCheckinSummary: checkinSummary,
      );

      // 6. Generate message via Edge Function
      final generatedMessage = await _repository.generateMessage(
        context: context,
      );

      return generatedMessage;
    } catch (e) {
      // On error, fallback to latest message
      return await _repository.getLatestMessage(userId);
    }
  }
}
