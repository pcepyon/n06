import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/services/symptom_pattern_analyzer.dart';

void main() {
  group('SymptomPatternAnalyzer', () {
    late SymptomPatternAnalyzer analyzer;

    setUp(() {
      analyzer = SymptomPatternAnalyzer();
    });

    group('analyzePatterns', () {
      // TC-SPA-01: 데이터 없음 - 빈 리스트 반환
      test('should return empty list when no logs provided', () {
        // Arrange
        final recentLogs = <SymptomLog>[];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        expect(insights, isEmpty);
      });

      // TC-SPA-02: 현재 증상과 무관한 로그만 있을 때 - 빈 리스트 반환
      test('should return empty list when no relevant logs', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '구토', // 다른 증상
            severity: 5,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 2)),
            symptomName: '변비', // 다른 증상
            severity: 6,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        expect(insights, isEmpty);
      });

      // TC-SPA-03: 반복 패턴 감지 (최근 7일간 3회 이상)
      test('should detect recurring pattern when symptom appears 3+ times in 7 days', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 6,
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 4,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        expect(insights, isNotEmpty);
        final recurringInsight = insights.firstWhere(
          (i) => i.type == PatternType.recurring,
        );
        expect(recurringInsight.symptomName, '메스꺼움');
        expect(recurringInsight.message, contains('최근 7일간'));
        expect(recurringInsight.message, contains('3번'));
        expect(recurringInsight.confidence, 0.9);
      });

      // TC-SPA-04: 반복 패턴 미감지 (2회만 발생)
      test('should not detect recurring pattern when symptom appears less than 3 times', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 6,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final recurringInsights = insights.where((i) => i.type == PatternType.recurring);
        expect(recurringInsights, isEmpty);
      });

      // TC-SPA-05: 반복 패턴 - 심각도에 따른 제안 차별화 (경증)
      test('should provide appropriate suggestion for mild recurring pattern', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 4, // 경증
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 6,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final recurringInsight = insights.firstWhere(
          (i) => i.type == PatternType.recurring,
        );
        expect(recurringInsight.suggestion, contains('몸이 적응하는 과정'));
      });

      // TC-SPA-06: 반복 패턴 - 심각도에 따른 제안 차별화 (중증)
      test('should provide appropriate suggestion for severe recurring pattern', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 8, // 중증
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 9,
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final recurringInsight = insights.firstWhere(
          (i) => i.type == PatternType.recurring,
        );
        expect(recurringInsight.suggestion, contains('담당 의료진과 상담'));
      });

      // TC-SPA-07: 컨텍스트 연관성 감지 (특정 태그와 3회 이상)
      test('should detect context related pattern when tag appears 3+ times', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
            tags: const ['기름진음식'],
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 6,
            tags: const ['기름진음식', '과식'],
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 4,
            tags: const ['기름진음식'],
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final contextInsights = insights.where((i) => i.type == PatternType.contextRelated);
        expect(contextInsights, isNotEmpty);
        final foodInsight = contextInsights.firstWhere(
          (i) => i.message.contains('기름진음식'),
        );
        expect(foodInsight.message, contains('3번'));
        expect(foodInsight.confidence, greaterThan(0.0));
      });

      // TC-SPA-08: 컨텍스트 연관성 - 신뢰도 계산
      test('should calculate confidence based on tag frequency', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
            tags: const ['기름진음식'],
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 6,
            tags: const ['기름진음식'],
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 4,
            tags: const ['기름진음식'],
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final contextInsights = insights.where((i) => i.type == PatternType.contextRelated);
        expect(contextInsights, isNotEmpty);

        // 3/3 = 1.0 confidence
        final foodInsight = contextInsights.first;
        expect(foodInsight.confidence, 1.0);
      });

      // TC-SPA-09: 개선 추세 감지 (최근 7일 vs 이전 7일, 20% 이상 감소)
      test('should detect improving trend when severity decreases by 20%+', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          // 최근 7일 (평균 3.5)
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 3,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 4,
          ),
          // 이전 7-14일 (평균 7.0)
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 9)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
          SymptomLog(
            id: '4',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 12)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final trendInsights = insights.where((i) => i.type == PatternType.improving);
        expect(trendInsights, isNotEmpty);
        final improvingInsight = trendInsights.first;
        expect(improvingInsight.message, contains('나아졌어요'));
        expect(improvingInsight.suggestion, contains('잘하고 계세요'));
        expect(improvingInsight.confidence, 0.8);
      });

      // TC-SPA-10: 악화 추세 감지 (최근 7일 vs 이전 7일, 20% 이상 증가)
      test('should detect worsening trend when severity increases by 20%+', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          // 최근 7일 (평균 7.5)
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 8,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
          // 이전 7-14일 (평균 4.0)
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 9)),
            symptomName: '메스꺼움',
            severity: 4,
          ),
          SymptomLog(
            id: '4',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 12)),
            symptomName: '메스꺼움',
            severity: 4,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final trendInsights = insights.where((i) => i.type == PatternType.worsening);
        expect(trendInsights, isNotEmpty);
        final worseningInsight = trendInsights.first;
        expect(worseningInsight.message, contains('증가했어요'));
        expect(worseningInsight.suggestion, contains('담당 의료진과 상담'));
        expect(worseningInsight.confidence, 0.8);
      });

      // TC-SPA-11: 추세 미감지 (변화 20% 미만)
      test('should not detect trend when change is less than 20%', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          // 최근 7일 (평균 5.5)
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 6,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          // 이전 7-14일 (평균 5.0)
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 9)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '4',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 12)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final trendInsights = insights.where(
          (i) => i.type == PatternType.improving || i.type == PatternType.worsening,
        );
        expect(trendInsights, isEmpty);
      });

      // TC-SPA-12: 추세 미감지 (데이터 부족)
      test('should not detect trend when insufficient data', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 6,
          ),
          // 이전 7-14일 데이터 없음
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final trendInsights = insights.where(
          (i) => i.type == PatternType.improving || i.type == PatternType.worsening,
        );
        expect(trendInsights, isEmpty);
      });

      // TC-SPA-13: 복합 패턴 감지 및 신뢰도 정렬
      test('should detect multiple patterns and sort by confidence', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          // 반복 + 컨텍스트 + 개선 패턴 모두 감지 가능한 데이터
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 3,
            tags: const ['기름진음식'],
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 4,
            tags: const ['기름진음식'],
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 3,
            tags: const ['기름진음식'],
          ),
          // 이전 7-14일 (높은 심각도)
          SymptomLog(
            id: '4',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 9)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
          SymptomLog(
            id: '5',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 12)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        expect(insights.length, greaterThanOrEqualTo(2));

        // 신뢰도 내림차순 정렬 확인
        for (int i = 0; i < insights.length - 1; i++) {
          expect(insights[i].confidence, greaterThanOrEqualTo(insights[i + 1].confidence));
        }
      });

      // TC-SPA-14: 경계값 테스트 - 반복 패턴 정확히 3회
      test('should detect recurring pattern with exactly 3 occurrences', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert
        final recurringInsights = insights.where((i) => i.type == PatternType.recurring);
        expect(recurringInsights, isNotEmpty);
      });

      // TC-SPA-15: 경계값 테스트 - 추세 분석 최소 데이터 (4개)
      test('should detect trend with minimum 4 logs', () {
        // Arrange
        final now = DateTime.now();
        final recentLogs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 3,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '메스꺼움',
            severity: 3,
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 9)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
          SymptomLog(
            id: '4',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 11)),
            symptomName: '메스꺼움',
            severity: 7,
          ),
        ];

        // Act
        final insights = analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: '메스꺼움',
        );

        // Assert - 최소 4개로 추세 감지 가능
        expect(insights, isNotEmpty);
      });
    });
  });
}
