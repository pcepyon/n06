import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_context_tag_dto.dart';

class IsarTrackingRepository implements TrackingRepository {
  final Isar _isar;

  IsarTrackingRepository(this._isar);

  // ============ 체중 기록 ============

  @override
  Future<void> saveWeightLog(WeightLog log) async {
    final dto = WeightLogDto.fromEntity(log);
    await _isar.writeTxn(() async {
      // 같은 날짜의 기존 기록이 있으면 삭제
      final existing = await _isar.weightLogDtos
          .filter()
          .userIdEqualTo(log.userId)
          .logDateEqualTo(log.logDate)
          .findAll();

      if (existing.isNotEmpty) {
        await _isar.weightLogDtos.deleteAll(existing.map((e) => e.id).toList());
      }

      await _isar.weightLogDtos.put(dto);
    });
  }

  @override
  Future<WeightLog?> getWeightLog(String userId, DateTime logDate) async {
    final dto = await _isar.weightLogDtos
        .filter()
        .userIdEqualTo(userId)
        .logDateEqualTo(logDate)
        .findFirst();

    return dto?.toEntity();
  }

  @override
  Future<List<WeightLog>> getWeightLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dtos = await _isar.weightLogDtos
        .filter()
        .userIdEqualTo(userId)
        .sortByLogDateDesc()
        .findAll();

    // 메모리에서 날짜 필터링
    var filteredDtos = dtos;
    if (startDate != null) {
      final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      filteredDtos = filteredDtos.where((dto) => dto.logDate.isAfter(startOfDay) || dto.logDate.day == startOfDay.day && dto.logDate.month == startOfDay.month && dto.logDate.year == startOfDay.year).toList();
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      filteredDtos = filteredDtos.where((dto) => dto.logDate.isBefore(endOfDay.add(Duration(seconds: 1)))).toList();
    }

    return filteredDtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> deleteWeightLog(String id) async {
    final weightLogId = int.tryParse(id);
    if (weightLogId != null) {
      await _isar.writeTxn(() => _isar.weightLogDtos.delete(weightLogId));
    }
  }

  @override
  Future<void> updateWeightLog(String id, double newWeight) async {
    final weightLogId = int.tryParse(id);
    if (weightLogId != null) {
      final dto = await _isar.weightLogDtos.get(weightLogId);
      if (dto != null) {
        dto.weightKg = newWeight;
        await _isar.writeTxn(() => _isar.weightLogDtos.put(dto));
      }
    }
  }

  @override
  Future<WeightLog?> getWeightLogById(String id) async {
    final weightLogId = int.tryParse(id);
    if (weightLogId == null) return null;
    final dto = await _isar.weightLogDtos.get(weightLogId);
    return dto?.toEntity();
  }

  @override
  Future<void> updateWeightLogWithDate(String id, double newWeight, DateTime newDate) async {
    final weightLogId = int.tryParse(id);
    if (weightLogId != null) {
      final dto = await _isar.weightLogDtos.get(weightLogId);
      if (dto != null) {
        dto.weightKg = newWeight;
        dto.logDate = newDate;
        await _isar.writeTxn(() => _isar.weightLogDtos.put(dto));
      }
    }
  }

  @override
  Stream<List<WeightLog>> watchWeightLogs(String userId) {
    return _isar.weightLogDtos
        .filter()
        .userIdEqualTo(userId)
        .sortByLogDateDesc()
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
  }

  // ============ 증상 기록 ============

  @override
  Future<void> saveSymptomLog(SymptomLog log) async {
    final dto = SymptomLogDto.fromEntity(log);

    await _isar.writeTxn(() async {
      // SymptomLogDto 저장
      final symptomLogId = await _isar.symptomLogDtos.put(dto);

      // 태그 저장
      if (log.tags.isNotEmpty) {
        final tagDtos = log.tags.map((tagName) {
          return SymptomContextTagDto()
            ..symptomLogIsarId = symptomLogId
            ..tagName = tagName;
        }).toList();

        await _isar.symptomContextTagDtos.putAll(tagDtos);
      }
    });
  }

  @override
  Future<List<SymptomLog>> getSymptomLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dtos = await _isar.symptomLogDtos
        .filter()
        .userIdEqualTo(userId)
        .sortByLogDateDesc()
        .findAll();

    // 메모리에서 날짜 필터링
    var filteredDtos = dtos;
    if (startDate != null) {
      final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      filteredDtos = filteredDtos.where((dto) => dto.logDate.isAfter(startOfDay) || (dto.logDate.day == startOfDay.day && dto.logDate.month == startOfDay.month && dto.logDate.year == startOfDay.year)).toList();
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      filteredDtos = filteredDtos.where((dto) => dto.logDate.isBefore(endOfDay.add(Duration(seconds: 1)))).toList();
    }

    final logs = <SymptomLog>[];
    for (final dto in filteredDtos) {
      final tags = await _isar.symptomContextTagDtos
          .filter()
          .symptomLogIsarIdEqualTo(dto.id)
          .findAll();

      final tagNames = tags.map((t) => t.tagName).toList();
      logs.add(dto.toEntity(tags: tagNames));
    }

    return logs;
  }

  @override
  Future<void> deleteSymptomLog(String id) async {
    final symptomLogId = int.tryParse(id);
    if (symptomLogId != null) {
      await _isar.writeTxn(() async {
        // 태그 삭제
        final tags = await _isar.symptomContextTagDtos
            .filter()
            .symptomLogIsarIdEqualTo(symptomLogId)
            .findAll();
        await _isar.symptomContextTagDtos.deleteAll(tags.map((t) => t.id).toList());

        // 증상 로그 삭제
        await _isar.symptomLogDtos.delete(symptomLogId);
      });
    }
  }

  @override
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog) async {
    final symptomLogId = int.tryParse(id);
    if (symptomLogId != null) {
      await _isar.writeTxn(() async {
        // 기존 태그 삭제
        final oldTags = await _isar.symptomContextTagDtos
            .filter()
            .symptomLogIsarIdEqualTo(symptomLogId)
            .findAll();
        await _isar.symptomContextTagDtos.deleteAll(oldTags.map((t) => t.id).toList());

        // 증상 로그 업데이트
        final dto = SymptomLogDto.fromEntity(updatedLog);
        dto.id = symptomLogId;
        await _isar.symptomLogDtos.put(dto);

        // 새 태그 추가
        if (updatedLog.tags.isNotEmpty) {
          final newTagDtos = updatedLog.tags.map((tagName) {
            return SymptomContextTagDto()
              ..symptomLogIsarId = symptomLogId
              ..tagName = tagName;
          }).toList();
          await _isar.symptomContextTagDtos.putAll(newTagDtos);
        }
      });
    }
  }

  @override
  Stream<List<SymptomLog>> watchSymptomLogs(String userId) {
    return _isar.symptomLogDtos
        .filter()
        .userIdEqualTo(userId)
        .sortByLogDateDesc()
        .watch(fireImmediately: true)
        .asyncMap((dtos) async {
          final logs = <SymptomLog>[];
          for (final dto in dtos) {
            final tags = await _isar.symptomContextTagDtos
                .filter()
                .symptomLogIsarIdEqualTo(dto.id)
                .findAll();

            final tagNames = tags.map((t) => t.tagName).toList();
            logs.add(dto.toEntity(tags: tagNames));
          }
          return logs;
        });
  }

  // ============ 태그 기반 조회 ============

  @override
  Future<List<SymptomLog>> getSymptomLogsByTag(String tagName) async {
    final tagDtos = await _isar.symptomContextTagDtos
        .filter()
        .tagNameEqualTo(tagName)
        .findAll();

    final logs = <SymptomLog>[];
    for (final tagDto in tagDtos) {
      final symptomDto = await _isar.symptomLogDtos.get(tagDto.symptomLogIsarId);
      if (symptomDto != null) {
        final tags = await _isar.symptomContextTagDtos
            .filter()
            .symptomLogIsarIdEqualTo(symptomDto.id)
            .findAll();

        final tagNames = tags.map((t) => t.tagName).toList();
        logs.add(symptomDto.toEntity(tags: tagNames));
      }
    }

    return logs;
  }

  @override
  Future<List<String>> getAllTags(String userId) async {
    final symptomDtos = await _isar.symptomLogDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    final tagSet = <String>{};
    for (final symptomDto in symptomDtos) {
      final tags = await _isar.symptomContextTagDtos
          .filter()
          .symptomLogIsarIdEqualTo(symptomDto.id)
          .findAll();

      tagSet.addAll(tags.map((t) => t.tagName));
    }

    return tagSet.toList();
  }

  // ============ 경과일 계산 ============

  @override
  Future<DateTime?> getLatestDoseEscalationDate(String userId) async {
    // 투여 기록에서 가장 최근의 증량 시점을 찾음
    // 이는 MedicationRepository를 통해 구현됨
    // 현재는 구현 생략 (F001의 DosagePlan에서 증량 계획 추출)
    return null;
  }
}
