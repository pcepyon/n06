import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/infrastructure/repositories/static_coping_guide_repository.dart';

void main() {
  group('StaticCopingGuideRepository', () {
    late StaticCopingGuideRepository repository;

    setUp(() {
      repository = StaticCopingGuideRepository();
    });

    test('메스꺼움 증상의 가이드를 반환', () async {
      // Act
      final result = await repository.getGuideBySymptom('메스꺼움');

      // Assert
      expect(result, isNotNull);
      expect(result!.symptomName, '메스꺼움');
      expect(result.shortGuide, isNotEmpty);
      expect(result.detailedSections, isNotEmpty);
    });

    test('모든 7가지 증상의 가이드를 반환', () async {
      // Arrange
      final expectedSymptoms = ['메스꺼움', '구토', '변비', '설사', '복통', '두통', '피로'];

      // Act
      final result = await repository.getAllGuides();

      // Assert
      expect(result.length, 7);
      for (var symptom in expectedSymptoms) {
        expect(result.any((g) => g.symptomName == symptom), isTrue);
      }
    });

    test('등록되지 않은 증상은 null 반환', () async {
      // Act
      final result = await repository.getGuideBySymptom('알 수 없는 증상');

      // Assert
      expect(result, isNull);
    });

    test('각 가이드는 4가지 섹션을 포함', () async {
      // Act
      final guides = await repository.getAllGuides();

      // Assert
      for (var guide in guides) {
        expect(guide.detailedSections, isNotNull);
        expect(guide.detailedSections!.length, 4);
      }
    });

    test('섹션은 정해진 순서: 즉시조치, 식이조절, 생활습관, 경과관찰', () async {
      // Act
      final guide = await repository.getGuideBySymptom('메스꺼움');

      // Assert
      expect(guide!.detailedSections![0].title, '즉시 조치');
      expect(guide.detailedSections![1].title, '식이 조절');
      expect(guide.detailedSections![2].title, '생활 습관');
      expect(guide.detailedSections![3].title, '경과 관찰');
    });

    test('가이드 데이터는 긍정적인 톤으로 작성됨', () async {
      // Act
      final guides = await repository.getAllGuides();

      // Assert
      for (var guide in guides) {
        expect(guide.shortGuide, isNot(contains('위험')));
        expect(guide.shortGuide, isNot(contains('심각')));
      }
    });
  });
}
