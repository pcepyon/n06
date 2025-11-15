# Phase 1.4: 데이터 마이그레이션 전략

**목표**: 기존 Isar 로컬 데이터를 Supabase로 안전하게 이전

**소요 기간**: 1주

**담당**: Backend 엔지니어

---

## 1. 마이그레이션 개요

### 1.1 마이그레이션 전략

**단계별 접근**:
1. **백업**: Isar 데이터를 JSON으로 추출
2. **업로드**: Supabase로 데이터 업로드
3. **검증**: 데이터 무결성 확인
4. **전환**: Supabase를 Primary DB로 설정
5. **모니터링**: 마이그레이션 완료율 추적

### 1.2 마이그레이션 대상 데이터

| 테이블 | 우선순위 | 예상 레코드 수 | 비고 |
|--------|---------|--------------|------|
| `user_profiles` | P0 | 1 | 필수 |
| `dosage_plans` | P0 | 1-2 | 필수 |
| `dose_schedules` | P1 | 10-50 | 자동 재생성 가능 |
| `dose_records` | P0 | 10-100 | 필수 (이력 보존) |
| `weight_logs` | P0 | 10-100 | 필수 |
| `symptom_logs` | P0 | 10-100 | 필수 |
| `symptom_context_tags` | P1 | 50-500 | symptom_logs 관련 |
| `emergency_symptom_checks` | P1 | 0-10 | 선택적 |
| `user_badges` | P1 | 0-20 | 자동 재계산 가능 |
| `notification_settings` | P1 | 1 | 기본값으로 재생성 가능 |
| `guide_feedback` | P2 | 0-10 | 선택적 |

**총 레코드 수**: ~200-800개/사용자

---

## 2. BackupService 구현

### 2.1 파일 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/core/migration/backup_service.dart`

**디렉토리 생성**:
```bash
mkdir -p /Users/pro16/Desktop/project/n06/lib/core/migration
```

**파일 내용**:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  final Isar _isar;

  BackupService(this._isar);

  /// 모든 데이터를 JSON으로 추출
  Future<Map<String, dynamic>> exportAllData(String userId) async {
    return {
      'version': '1.0',
      'user_id': userId,
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'user_profile': await _exportUserProfile(userId),
        'dosage_plans': await _exportDosagePlans(userId),
        'dose_schedules': await _exportDoseSchedules(userId),
        'dose_records': await _exportDoseRecords(userId),
        'weight_logs': await _exportWeightLogs(userId),
        'symptom_logs': await _exportSymptomLogs(userId),
        'emergency_checks': await _exportEmergencyChecks(userId),
        'user_badges': await _exportUserBadges(userId),
        'notification_settings': await _exportNotificationSettings(userId),
        'guide_feedback': await _exportGuideFeedback(userId),
      },
    };
  }

  /// 파일로 저장
  Future<String> saveBackupToFile(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final userId = data['user_id'] as String;
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'backup_${userId}_$timestamp.json';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonEncode(data));

    return filePath;
  }

  /// 파일에서 백업 로드
  Future<Map<String, dynamic>> loadBackupFromFile(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString();
    return jsonDecode(contents) as Map<String, dynamic>;
  }

  // ============================================
  // Export Methods
  // ============================================

  Future<Map<String, dynamic>?> _exportUserProfile(String userId) async {
    final profile = await _isar.userProfileDtos
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    if (profile == null) return null;

    return {
      'id': profile.id.toString(),
      'user_id': profile.userId,
      'target_weight_kg': profile.targetWeightKg,
      'target_period_weeks': profile.targetPeriodWeeks,
      'weekly_loss_goal_kg': profile.weeklyLossGoalKg,
      'weekly_weight_record_goal': profile.weeklyWeightRecordGoal,
      'weekly_symptom_record_goal': profile.weeklySymptomRecordGoal,
      'created_at': profile.createdAt.toIso8601String(),
      'updated_at': profile.updatedAt.toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> _exportDosagePlans(String userId) async {
    final plans = await _isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    return plans.map((plan) => {
      'id': plan.id.toString(),
      'user_id': plan.userId,
      'medication_name': plan.medicationName,
      'start_date': plan.startDate.toIso8601String().split('T')[0],
      'cycle_days': plan.cycleDays,
      'initial_dose_mg': plan.initialDoseMg,
      'escalation_plan': plan.escalationPlan?.map((step) => {
        'weeks': step.weeks,
        'dose_mg': step.doseMg,
      }).toList(),
      'is_active': plan.isActive,
      'created_at': plan.createdAt.toIso8601String(),
      'updated_at': plan.updatedAt.toIso8601String(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDoseSchedules(String userId) async {
    // dosage_plans를 통해 schedules 조회
    final plans = await _isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    final schedules = <Map<String, dynamic>>[];

    for (final plan in plans) {
      final planSchedules = await _isar.doseScheduleDtos
          .filter()
          .dosagePlanIdEqualTo(plan.id.toString())
          .findAll();

      schedules.addAll(planSchedules.map((schedule) => {
        'id': schedule.id.toString(),
        'dosage_plan_id': schedule.dosagePlanId,
        'scheduled_date': schedule.scheduledDate.toIso8601String().split('T')[0],
        'scheduled_dose_mg': schedule.scheduledDoseMg,
        'notification_time': schedule.notificationTime != null
            ? '${schedule.notificationTime!.hour.toString().padLeft(2, '0')}:${schedule.notificationTime!.minute.toString().padLeft(2, '0')}:00'
            : null,
        'created_at': schedule.createdAt.toIso8601String(),
      }));
    }

    return schedules;
  }

  Future<List<Map<String, dynamic>>> _exportDoseRecords(String userId) async {
    final plans = await _isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    final records = <Map<String, dynamic>>[];

    for (final plan in plans) {
      final planRecords = await _isar.doseRecordDtos
          .filter()
          .dosagePlanIdEqualTo(plan.id.toString())
          .findAll();

      records.addAll(planRecords.map((record) => {
        'id': record.id.toString(),
        'dose_schedule_id': record.doseScheduleId,
        'dosage_plan_id': record.dosagePlanId,
        'administered_at': record.administeredAt.toIso8601String(),
        'actual_dose_mg': record.actualDoseMg,
        'injection_site': record.injectionSite,
        'is_completed': record.isCompleted,
        'note': record.note,
        'created_at': record.createdAt.toIso8601String(),
      }));
    }

    return records;
  }

  Future<List<Map<String, dynamic>>> _exportWeightLogs(String userId) async {
    final logs = await _isar.weightLogDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    return logs.map((log) => {
      'id': log.id.toString(),
      'user_id': log.userId,
      'log_date': log.logDate.toIso8601String().split('T')[0],
      'weight_kg': log.weightKg,
      'created_at': log.createdAt.toIso8601String(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportSymptomLogs(String userId) async {
    final logs = await _isar.symptomLogDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    final result = <Map<String, dynamic>>[];

    for (final log in logs) {
      // context_tags 조회
      final tags = await _isar.symptomContextTagDtos
          .filter()
          .symptomLogIdEqualTo(log.id.toString())
          .findAll();

      result.add({
        'id': log.id.toString(),
        'user_id': log.userId,
        'log_date': log.logDate.toIso8601String().split('T')[0],
        'symptom_name': log.symptomName,
        'severity': log.severity,
        'days_since_escalation': log.daysSinceEscalation,
        'is_persistent_24h': log.isPersistent24h,
        'note': log.note,
        'created_at': log.createdAt.toIso8601String(),
        'context_tags': tags.map((tag) => tag.tagName).toList(),
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> _exportEmergencyChecks(String userId) async {
    final checks = await _isar.emergencySymptomCheckDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    return checks.map((check) => {
      'id': check.id.toString(),
      'user_id': check.userId,
      'checked_at': check.checkedAt.toIso8601String(),
      'checked_symptoms': check.checkedSymptoms,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportUserBadges(String userId) async {
    final badges = await _isar.userBadgeDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    return badges.map((badge) => {
      'id': badge.id.toString(),
      'user_id': badge.userId,
      'badge_id': badge.badgeId,
      'status': badge.status,
      'progress_percentage': badge.progressPercentage,
      'achieved_at': badge.achievedAt?.toIso8601String(),
      'created_at': badge.createdAt.toIso8601String(),
      'updated_at': badge.updatedAt.toIso8601String(),
    }).toList();
  }

  Future<Map<String, dynamic>?> _exportNotificationSettings(String userId) async {
    final settings = await _isar.notificationSettingsDtos
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    if (settings == null) return null;

    return {
      'id': settings.id.toString(),
      'user_id': settings.userId,
      'notification_hour': settings.notificationHour,
      'notification_minute': settings.notificationMinute,
      'notification_enabled': settings.notificationEnabled,
      'created_at': settings.createdAt.toIso8601String(),
      'updated_at': settings.updatedAt.toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> _exportGuideFeedback(String userId) async {
    final feedback = await _isar.guideFeedbackDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    return feedback.map((f) => {
      'id': f.id.toString(),
      'user_id': f.userId,
      'symptom_name': f.symptomName,
      'helpful': f.helpful,
      'created_at': f.createdAt.toIso8601String(),
    }).toList();
  }
}
```

---

## 3. MigrationService 구현

### 3.1 파일 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/core/migration/migration_service.dart`

**파일 내용**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'backup_service.dart';

class MigrationService {
  final SupabaseClient _supabase;
  final BackupService _backupService;

  MigrationService(this._supabase, this._backupService);

  /// 전체 마이그레이션 실행
  Future<MigrationResult> migrateUserData(String userId) async {
    final result = MigrationResult(userId: userId);

    try {
      // 1. 데이터 백업
      result.startStep('backup');
      final backup = await _backupService.exportAllData(userId);
      final backupPath = await _backupService.saveBackupToFile(backup);
      result.completeStep('backup', backupPath);

      // 2. Supabase로 업로드
      final data = backup['data'] as Map<String, dynamic>;

      result.startStep('user_profile');
      await _uploadUserProfile(data['user_profile']);
      result.completeStep('user_profile');

      result.startStep('dosage_plans');
      await _uploadDosagePlans(data['dosage_plans']);
      result.completeStep('dosage_plans');

      result.startStep('dose_schedules');
      await _uploadDoseSchedules(data['dose_schedules']);
      result.completeStep('dose_schedules');

      result.startStep('dose_records');
      await _uploadDoseRecords(data['dose_records']);
      result.completeStep('dose_records');

      result.startStep('weight_logs');
      await _uploadWeightLogs(data['weight_logs']);
      result.completeStep('weight_logs');

      result.startStep('symptom_logs');
      await _uploadSymptomLogs(data['symptom_logs']);
      result.completeStep('symptom_logs');

      result.startStep('emergency_checks');
      await _uploadEmergencyChecks(data['emergency_checks']);
      result.completeStep('emergency_checks');

      result.startStep('user_badges');
      await _uploadUserBadges(data['user_badges']);
      result.completeStep('user_badges');

      result.startStep('notification_settings');
      await _uploadNotificationSettings(data['notification_settings']);
      result.completeStep('notification_settings');

      result.startStep('guide_feedback');
      await _uploadGuideFeedback(data['guide_feedback']);
      result.completeStep('guide_feedback');

      // 3. 마이그레이션 완료 플래그
      await _supabase.from('users').update({
        'migration_completed_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      result.success = true;
    } catch (e) {
      result.error = e.toString();
      result.success = false;
    }

    return result;
  }

  // ============================================
  // Upload Methods
  // ============================================

  Future<void> _uploadUserProfile(Map<String, dynamic>? profile) async {
    if (profile == null) return;

    final uuid = const Uuid();
    await _supabase.from('user_profiles').upsert({
      'id': uuid.v4(),
      'user_id': profile['user_id'],
      'target_weight_kg': profile['target_weight_kg'],
      'target_period_weeks': profile['target_period_weeks'],
      'weekly_loss_goal_kg': profile['weekly_loss_goal_kg'],
      'weekly_weight_record_goal': profile['weekly_weight_record_goal'],
      'weekly_symptom_record_goal': profile['weekly_symptom_record_goal'],
      'created_at': profile['created_at'],
      'updated_at': profile['updated_at'],
    });
  }

  Future<void> _uploadDosagePlans(List<dynamic>? plans) async {
    if (plans == null || plans.isEmpty) return;

    final uuid = const Uuid();
    final batch = plans.map((plan) => {
      'id': uuid.v4(),
      'user_id': plan['user_id'],
      'medication_name': plan['medication_name'],
      'start_date': plan['start_date'],
      'cycle_days': plan['cycle_days'],
      'initial_dose_mg': plan['initial_dose_mg'],
      'escalation_plan': plan['escalation_plan'],
      'is_active': plan['is_active'],
      'created_at': plan['created_at'],
      'updated_at': plan['updated_at'],
    }).toList();

    // 배치 처리 (100개씩)
    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('dosage_plans').insert(batch.sublist(i, end));
    }
  }

  Future<void> _uploadDoseSchedules(List<dynamic>? schedules) async {
    if (schedules == null || schedules.isEmpty) return;

    final uuid = const Uuid();
    final batch = schedules.map((schedule) => {
      'id': uuid.v4(),
      'dosage_plan_id': schedule['dosage_plan_id'],
      'scheduled_date': schedule['scheduled_date'],
      'scheduled_dose_mg': schedule['scheduled_dose_mg'],
      'notification_time': schedule['notification_time'],
      'created_at': schedule['created_at'],
    }).toList();

    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('dose_schedules').insert(batch.sublist(i, end));
    }
  }

  Future<void> _uploadDoseRecords(List<dynamic>? records) async {
    if (records == null || records.isEmpty) return;

    final uuid = const Uuid();
    final batch = records.map((record) => {
      'id': uuid.v4(),
      'dose_schedule_id': record['dose_schedule_id'],
      'dosage_plan_id': record['dosage_plan_id'],
      'administered_at': record['administered_at'],
      'actual_dose_mg': record['actual_dose_mg'],
      'injection_site': record['injection_site'],
      'is_completed': record['is_completed'],
      'note': record['note'],
      'created_at': record['created_at'],
    }).toList();

    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('dose_records').insert(batch.sublist(i, end));
    }
  }

  Future<void> _uploadWeightLogs(List<dynamic>? logs) async {
    if (logs == null || logs.isEmpty) return;

    final uuid = const Uuid();
    final batch = logs.map((log) => {
      'id': uuid.v4(),
      'user_id': log['user_id'],
      'log_date': log['log_date'],
      'weight_kg': log['weight_kg'],
      'created_at': log['created_at'],
    }).toList();

    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('weight_logs').insert(batch.sublist(i, end));
    }
  }

  Future<void> _uploadSymptomLogs(List<dynamic>? logs) async {
    if (logs == null || logs.isEmpty) return;

    final uuid = const Uuid();

    for (final log in logs) {
      final symptomLogId = uuid.v4();

      // 1. symptom_log 추가
      await _supabase.from('symptom_logs').insert({
        'id': symptomLogId,
        'user_id': log['user_id'],
        'log_date': log['log_date'],
        'symptom_name': log['symptom_name'],
        'severity': log['severity'],
        'days_since_escalation': log['days_since_escalation'],
        'is_persistent_24h': log['is_persistent_24h'],
        'note': log['note'],
        'created_at': log['created_at'],
      });

      // 2. context_tags 추가
      final tags = log['context_tags'] as List<dynamic>?;
      if (tags != null && tags.isNotEmpty) {
        final tagBatch = tags.map((tag) => {
          'id': uuid.v4(),
          'symptom_log_id': symptomLogId,
          'tag_name': tag,
        }).toList();

        await _supabase.from('symptom_context_tags').insert(tagBatch);
      }
    }
  }

  Future<void> _uploadEmergencyChecks(List<dynamic>? checks) async {
    if (checks == null || checks.isEmpty) return;

    final uuid = const Uuid();
    final batch = checks.map((check) => {
      'id': uuid.v4(),
      'user_id': check['user_id'],
      'checked_at': check['checked_at'],
      'checked_symptoms': check['checked_symptoms'],
    }).toList();

    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('emergency_symptom_checks').insert(batch.sublist(i, end));
    }
  }

  Future<void> _uploadUserBadges(List<dynamic>? badges) async {
    if (badges == null || badges.isEmpty) return;

    final uuid = const Uuid();
    final batch = badges.map((badge) => {
      'id': uuid.v4(),
      'user_id': badge['user_id'],
      'badge_id': badge['badge_id'],
      'status': badge['status'],
      'progress_percentage': badge['progress_percentage'],
      'achieved_at': badge['achieved_at'],
      'created_at': badge['created_at'],
      'updated_at': badge['updated_at'],
    }).toList();

    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('user_badges').insert(batch.sublist(i, end));
    }
  }

  Future<void> _uploadNotificationSettings(Map<String, dynamic>? settings) async {
    if (settings == null) return;

    final uuid = const Uuid();
    await _supabase.from('notification_settings').upsert({
      'id': uuid.v4(),
      'user_id': settings['user_id'],
      'notification_hour': settings['notification_hour'],
      'notification_minute': settings['notification_minute'],
      'notification_enabled': settings['notification_enabled'],
      'created_at': settings['created_at'],
      'updated_at': settings['updated_at'],
    });
  }

  Future<void> _uploadGuideFeedback(List<dynamic>? feedback) async {
    if (feedback == null || feedback.isEmpty) return;

    final uuid = const Uuid();
    final batch = feedback.map((f) => {
      'id': uuid.v4(),
      'user_id': f['user_id'],
      'symptom_name': f['symptom_name'],
      'helpful': f['helpful'],
      'created_at': f['created_at'],
    }).toList();

    for (var i = 0; i < batch.length; i += 100) {
      final end = (i + 100 < batch.length) ? i + 100 : batch.length;
      await _supabase.from('guide_feedback').insert(batch.sublist(i, end));
    }
  }
}

// ============================================
// MigrationResult
// ============================================

class MigrationResult {
  final String userId;
  bool success = false;
  String? error;
  final Map<String, String> steps = {};
  DateTime? startedAt;
  DateTime? completedAt;

  MigrationResult({required this.userId});

  void startStep(String step) {
    startedAt ??= DateTime.now();
    steps[step] = 'in_progress';
  }

  void completeStep(String step, [String? detail]) {
    steps[step] = detail ?? 'completed';
  }

  void complete() {
    completedAt = DateTime.now();
  }

  Duration? get duration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }
}
```

---

## 4. 마이그레이션 UI

### 4.1 Provider 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/core/migration/providers.dart`

**파일 내용**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers.dart';
import 'backup_service.dart';
import 'migration_service.dart';

part 'providers.g.dart';

@riverpod
BackupService backupService(BackupServiceRef ref) {
  final isar = ref.watch(isarProvider);
  return BackupService(isar);
}

@riverpod
MigrationService migrationService(MigrationServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  final backupService = ref.watch(backupServiceProvider);
  return MigrationService(supabase, backupService);
}
```

### 4.2 마이그레이션 화면

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/settings/presentation/screens/migration_screen.dart`

**새 파일 생성**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/migration/providers.dart';
import '../../../../core/migration/migration_service.dart';
import '../../../authentication/application/notifiers/auth_notifier.dart';

class MigrationScreen extends ConsumerStatefulWidget {
  const MigrationScreen({super.key});

  @override
  ConsumerState<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends ConsumerState<MigrationScreen> {
  MigrationResult? _result;
  bool _isMigrating = false;

  Future<void> _startMigration() async {
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    setState(() {
      _isMigrating = true;
      _result = null;
    });

    try {
      final service = ref.read(migrationServiceProvider);
      final result = await service.migrateUserData(userId);

      setState(() {
        _result = result;
        _isMigrating = false;
      });

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('클라우드 백업 완료!')),
        );
      }
    } catch (e) {
      setState(() {
        _isMigrating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마이그레이션 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('클라우드 동기화')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '로컬 데이터를 클라우드로 백업합니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '백업이 완료되면 모든 기기에서 데이터에 접근할 수 있습니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 마이그레이션 상태
            if (_isMigrating)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('백업 중...'),
                  ],
                ),
              ),

            // 마이그레이션 결과
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result!.success ? Icons.check_circle : Icons.error,
                            color: _result!.success ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _result!.success ? '백업 완료' : '백업 실패',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._result!.steps.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              entry.value == 'completed' ? Icons.check : Icons.pending,
                              size: 16,
                              color: entry.value == 'completed' ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        ),
                      )),
                      if (_result!.duration != null) ...[
                        const Divider(),
                        Text('소요 시간: ${_result!.duration!.inSeconds}초'),
                      ],
                      if (_result!.error != null) ...[
                        const Divider(),
                        Text(
                          '에러: ${_result!.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // 마이그레이션 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isMigrating ? null : _startMigration,
                child: const Text('백업 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. 검증 및 롤백

### 5.1 데이터 검증

**검증 항목**:
1. 레코드 수 일치
2. 주요 필드 값 일치
3. 관계 무결성 (FK)
4. 날짜/시간 포맷 정확

**검증 코드**:
```dart
Future<bool> validateMigration(String userId) async {
  // 1. Isar에서 레코드 수 조회
  final isarWeightCount = await _isar.weightLogDtos
      .filter()
      .userIdEqualTo(userId)
      .count();

  // 2. Supabase에서 레코드 수 조회
  final supabaseWeightCount = await _supabase
      .from('weight_logs')
      .select('id', count: CountOption.exact)
      .eq('user_id', userId)
      .count();

  // 3. 비교
  return isarWeightCount == supabaseWeightCount;
}
```

### 5.2 롤백 계획

**롤백 시나리오**:
- 마이그레이션 실패
- 데이터 불일치
- 사용자 요청

**롤백 방법**:
1. Feature Flag로 Isar로 전환
2. Supabase 데이터 삭제
3. Isar 데이터 유지

---

## 6. 테스트

### 6.1 단위 테스트

**파일 위치**: `/Users/pro16/Desktop/project/n06/test/core/migration/backup_service_test.dart`

**테스트 케이스**:
```dart
test('exportAllData should export all user data', () async {
  final backup = await backupService.exportAllData('test-user-id');

  expect(backup['version'], '1.0');
  expect(backup['user_id'], 'test-user-id');
  expect(backup['data'], isNotNull);
});
```

### 6.2 통합 테스트

**시나리오**:
1. 테스트 사용자로 로그인
2. 마이그레이션 실행
3. Supabase에서 데이터 조회
4. Isar 데이터와 비교
5. 검증 성공 확인

---

## 7. 다음 단계

✅ Phase 1.4 완료 후:
- **[Phase 1.5: 테스트 및 검증](./05_testing.md)** 문서로 이동하세요.

---

## 트러블슈팅

### 문제 1: UUID 변환 에러
**증상**: Isar의 `Id` (int)를 Supabase UUID로 변환 시 에러
**해결**: `uuid` 패키지로 새 UUID 생성

### 문제 2: 배치 업로드 실패
**증상**: 대용량 데이터 업로드 시 타임아웃
**해결**: 100개씩 배치 처리

### 문제 3: 관계 무결성 위반
**증상**: FK 제약 위반
**해결**: 부모 테이블부터 순서대로 업로드
