import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';

void main() {
  group('PatternInsight Entity', () {
    // TC-PI-01: PatternType enum 값 검증
    test('should have all PatternType enum values', () {
      // Assert
      expect(PatternType.values.length, 4);
      expect(PatternType.values, contains(PatternType.recurring));
      expect(PatternType.values, contains(PatternType.contextRelated));
      expect(PatternType.values, contains(PatternType.improving));
      expect(PatternType.values, contains(PatternType.worsening));
    });

    // TC-PI-02: PatternInsight 정상 생성 (필수 필드만)
    test('should create PatternInsight with required fields only', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '메스꺼움이(가) 최근 7일간 5번 반복되었어요',
        confidence: 0.9,
      );

      // Assert
      expect(insight.type, PatternType.recurring);
      expect(insight.symptomName, '메스꺼움');
      expect(insight.message, '메스꺼움이(가) 최근 7일간 5번 반복되었어요');
      expect(insight.confidence, 0.9);
      expect(insight.suggestion, isNull);
    });

    // TC-PI-03: PatternInsight 정상 생성 (제안 포함)
    test('should create PatternInsight with suggestion', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.worsening,
        symptomName: '구토',
        message: '지난주보다 30% 증가했어요',
        suggestion: '증상이 지속되면 담당 의료진과 상담해보세요',
        confidence: 0.8,
      );

      // Assert
      expect(insight.type, PatternType.worsening);
      expect(insight.suggestion, '증상이 지속되면 담당 의료진과 상담해보세요');
    });

    // TC-PI-04: confidence 범위 검증 (0.0)
    test('should accept confidence 0.0', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.contextRelated,
        symptomName: '변비',
        message: '테스트 메시지',
        confidence: 0.0,
      );

      // Assert
      expect(insight.confidence, 0.0);
    });

    // TC-PI-05: confidence 범위 검증 (1.0)
    test('should accept confidence 1.0', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.improving,
        symptomName: '피로',
        message: '테스트 메시지',
        confidence: 1.0,
      );

      // Assert
      expect(insight.confidence, 1.0);
    });

    // TC-PI-06: confidence 범위 검증 (유효하지 않은 값)
    test('should throw assertion error for confidence < 0.0', () {
      // Act & Assert
      expect(
        () => PatternInsight(
          type: PatternType.recurring,
          symptomName: '메스꺼움',
          message: '테스트',
          confidence: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    // TC-PI-07: confidence 범위 검증 (유효하지 않은 값)
    test('should throw assertion error for confidence > 1.0', () {
      // Act & Assert
      expect(
        () => PatternInsight(
          type: PatternType.recurring,
          symptomName: '메스꺼움',
          message: '테스트',
          confidence: 1.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    // TC-PI-08: Equality 비교 (동일한 값)
    test('should compare two PatternInsight entities correctly when equal', () {
      // Arrange
      final insight1 = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트 메시지',
        suggestion: '테스트 제안',
        confidence: 0.9,
      );
      final insight2 = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트 메시지',
        suggestion: '테스트 제안',
        confidence: 0.9,
      );

      // Act & Assert
      expect(insight1 == insight2, isTrue);
      expect(insight1.hashCode, insight2.hashCode);
    });

    // TC-PI-09: Equality 비교 (다른 값)
    test('should compare two PatternInsight entities correctly when different', () {
      // Arrange
      final insight1 = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트 메시지',
        confidence: 0.9,
      );
      final insight2 = PatternInsight(
        type: PatternType.improving,
        symptomName: '메스꺼움',
        message: '테스트 메시지',
        confidence: 0.9,
      );

      // Act & Assert
      expect(insight1 == insight2, isFalse);
    });

    // TC-PI-10: toString 메서드 존재
    test('should have toString method', () {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트 메시지',
        confidence: 0.9,
      );

      // Act
      final str = insight.toString();

      // Assert
      expect(str, isNotEmpty);
      expect(str, contains('PatternInsight'));
      expect(str, contains('recurring'));
      expect(str, contains('메스꺼움'));
    });

    // TC-PI-11: 패턴 유형별 생성 검증 (recurring)
    test('should create recurring pattern insight', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '최근 7일간 3번 반복',
        confidence: 0.9,
      );

      // Assert
      expect(insight.type, PatternType.recurring);
    });

    // TC-PI-12: 패턴 유형별 생성 검증 (contextRelated)
    test('should create context related pattern insight', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.contextRelated,
        symptomName: '메스꺼움',
        message: '#기름진음식과(과) 함께 5번 기록',
        confidence: 0.7,
      );

      // Assert
      expect(insight.type, PatternType.contextRelated);
    });

    // TC-PI-13: 패턴 유형별 생성 검증 (improving)
    test('should create improving pattern insight', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.improving,
        symptomName: '피로',
        message: '지난주보다 25% 나아졌어요',
        confidence: 0.8,
      );

      // Assert
      expect(insight.type, PatternType.improving);
    });

    // TC-PI-14: 패턴 유형별 생성 검증 (worsening)
    test('should create worsening pattern insight', () {
      // Arrange & Act
      final insight = PatternInsight(
        type: PatternType.worsening,
        symptomName: '구토',
        message: '지난주보다 30% 증가',
        confidence: 0.8,
      );

      // Assert
      expect(insight.type, PatternType.worsening);
    });
  });
}
