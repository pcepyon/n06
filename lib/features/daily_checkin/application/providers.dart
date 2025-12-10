import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/daily_checkin/infrastructure/repositories/supabase_daily_checkin_repository.dart';
import 'package:n06/features/daily_checkin/application/services/greeting_service.dart';
import 'package:n06/features/daily_checkin/application/services/consecutive_days_service.dart';
import 'package:n06/features/daily_checkin/application/services/weekly_comparison_service.dart';
import 'package:n06/features/daily_checkin/application/services/weekly_report_generator.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/core/encryption/application/providers.dart';

part 'providers.g.dart';

/// DailyCheckinRepository Provider
@riverpod
DailyCheckinRepository dailyCheckinRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return SupabaseDailyCheckinRepository(supabase, encryptionService);
}

/// GreetingService Provider
@riverpod
GreetingService greetingService(Ref ref) {
  final checkinRepository = ref.watch(dailyCheckinRepositoryProvider);
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  return GreetingService(
    checkinRepository: checkinRepository,
    medicationRepository: medicationRepository,
  );
}

/// ConsecutiveDaysService Provider
@riverpod
ConsecutiveDaysService consecutiveDaysService(Ref ref) {
  final repository = ref.watch(dailyCheckinRepositoryProvider);
  return ConsecutiveDaysService(repository: repository);
}

/// WeeklyComparisonService Provider
@riverpod
WeeklyComparisonService weeklyComparisonService(Ref ref) {
  final checkinRepository = ref.watch(dailyCheckinRepositoryProvider);
  final trackingRepository = ref.watch(trackingRepositoryProvider);
  return WeeklyComparisonService(
    checkinRepository: checkinRepository,
    trackingRepository: trackingRepository,
  );
}

/// WeeklyReportGenerator Provider
@riverpod
WeeklyReportGenerator weeklyReportGenerator(Ref ref) {
  final checkinRepository = ref.watch(dailyCheckinRepositoryProvider);
  final trackingRepository = ref.watch(trackingRepositoryProvider);
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  return WeeklyReportGenerator(
    checkinRepository: checkinRepository,
    trackingRepository: trackingRepository,
    medicationRepository: medicationRepository,
  );
}

/// 오늘 체크인 여부 확인
@riverpod
Future<DailyCheckin?> todayCheckin(Ref ref) async {
  // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
  final user = await ref.watch(authNotifierProvider.future);
  final userId = user?.id;
  if (userId == null) return null;

  final repository = ref.watch(dailyCheckinRepositoryProvider);
  final today = DateTime.now();

  return await repository.getByDate(userId, today);
}

/// 연속 체크인 일수 조회
@riverpod
Future<int> consecutiveDays(Ref ref) async {
  // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
  final user = await ref.watch(authNotifierProvider.future);
  final userId = user?.id;
  if (userId == null) return 0;

  final repository = ref.watch(dailyCheckinRepositoryProvider);
  return await repository.getConsecutiveDays(userId);
}

/// 컨텍스트 인사 정보 조회
@riverpod
Future<GreetingContext?> greetingContext(Ref ref) async {
  // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
  final user = await ref.watch(authNotifierProvider.future);
  final userId = user?.id;
  if (userId == null) return null;

  final greetingService = ref.watch(greetingServiceProvider);
  return await greetingService.getGreeting(userId);
}

/// 마일스톤 정보 조회
@riverpod
Future<MilestoneInfo?> milestoneInfo(Ref ref) async {
  // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
  final user = await ref.watch(authNotifierProvider.future);
  final userId = user?.id;
  if (userId == null) return null;

  final service = ref.watch(consecutiveDaysServiceProvider);
  return await service.checkMilestone(userId);
}

/// 주간 비교 결과 조회
@riverpod
Future<WeeklyComparison?> weeklyComparison(Ref ref) async {
  // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
  final user = await ref.watch(authNotifierProvider.future);
  final userId = user?.id;
  if (userId == null) return null;

  final service = ref.watch(weeklyComparisonServiceProvider);
  return await service.compare(userId);
}

/// 전체 체크인 기록 조회 (기록 관리용)
@riverpod
Future<List<DailyCheckin>> allCheckins(Ref ref) async {
  // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
  final user = await ref.watch(authNotifierProvider.future);
  final userId = user?.id;
  if (userId == null) return [];

  final repository = ref.watch(dailyCheckinRepositoryProvider);
  // 충분히 넓은 범위로 조회 (서비스 시작일 ~ 오늘)
  final start = DateTime(2024, 1, 1);
  final end = DateTime.now();

  return await repository.getByDateRange(userId, start, end);
}
