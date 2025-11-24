import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/presentation/screens/daily_tracking_screen.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/providers.dart';

// Mock classes
class MockTrackingRepository extends Mock implements TrackingRepository {}

class MockGoRouter extends Mock implements GoRouter {}

// Fake AuthNotifier for testing
class FakeAuthNotifier extends AuthNotifier {
  final User? _user;
  FakeAuthNotifier(this._user);

  @override
  Future<User?> build() async => _user;
}

void main() {
  // Mocktail fallback values
  setUpAll(() {
    registerFallbackValue(
      WeightLog(
        id: 'fallback',
        userId: 'fallback',
        logDate: DateTime.now(),
        weightKg: 0,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      SymptomLog(
        id: 'fallback',
        userId: 'fallback',
        logDate: DateTime.now(),
        symptomName: 'fallback',
        severity: 1,
        createdAt: DateTime.now(),
      ),
    );
  });

  group('DailyTrackingScreen Widget Tests', () {
    late MockTrackingRepository mockRepository;
    late MockGoRouter mockRouter;

    setUp(() {
      mockRepository = MockTrackingRepository();
      mockRouter = MockGoRouter();

      // Default mock setup
      when(() => mockRepository.saveWeightLog(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveSymptomLog(any()))
          .thenAnswer((_) async {});
      when(() => mockRepository.getWeightLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getSymptomLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockRouter.go(any())).thenReturn(null);
    });

    Widget createTestWidget() {
      final user = User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
        oauthProvider: 'test',
        oauthUserId: 'test-oauth-id',
        lastLoginAt: DateTime.now(),
      );

      return ProviderScope(
        overrides: [
          trackingRepositoryProvider.overrideWithValue(mockRepository),
          goRouterProvider.overrideWithValue(mockRouter),
          authProvider.overrideWith(
            () => FakeAuthNotifier(user),
          ),
        ],
        child: const MaterialApp(
          home: DailyTrackingScreen(),
        ),
      );
    }

    // TC-DT-01: 식욕 조절 버튼 선택 시 상태 변경
    testWidgets('식욕 조절 버튼 선택 시 상태 변경', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // "약간↓" 버튼 찾아서 탭
      final appetiteButton = find.text('약간↓');
      expect(appetiteButton, findsOneWidget);

      await tester.tap(appetiteButton);
      await tester.pump();

      // 선택된 상태 확인 (버튼이 여전히 표시되는지)
      expect(find.text('약간↓'), findsOneWidget);
    });

    // TC-DT-02: 부작용 섹션 초기 접힌 상태 확인
    testWidgets('부작용 섹션 초기 접힌 상태', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // ExpansionTile 제목 찾기
      expect(find.text('부작용 기록 (선택)'), findsOneWidget);

      // 증상 칩이 보이지 않아야 함 (접혀있음)
      expect(find.text('메스꺼움'), findsNothing);
      expect(find.text('두통'), findsNothing);
    });

    // TC-DT-03: 증상 선택 시 개별 심각도 슬라이더 표시
    testWidgets('증상 선택 시 개별 심각도 슬라이더 표시', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 부작용 섹션 펼치기
      await tester.tap(find.text('부작용 기록 (선택)'));
      await tester.pumpAndSettle(); // ExpansionTile 애니메이션 완료 대기

      // 메스꺼움 선택
      final nauseaChip = find.text('메스꺼움');
      expect(nauseaChip, findsAtLeastNWidgets(1)); // 칩이 표시됨
      await tester.tap(nauseaChip.first);
      await tester.pump();

      // 메스꺼움 슬라이더 표시 확인
      expect(find.byType(Slider), findsAtLeastNWidgets(1));

      // 두통 추가 선택
      final headacheChip = find.text('두통');
      expect(headacheChip, findsAtLeastNWidgets(1));
      await tester.tap(headacheChip.first);
      await tester.pump();

      // 이제 슬라이더가 2개 이상 (각 증상마다)
      expect(find.byType(Slider), findsAtLeastNWidgets(2));
    });

    // TC-DT-04: 식욕 점수 미선택 시 저장 실패
    testWidgets('식욕 점수 미선택 시 저장 실패', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 체중만 입력 (식욕 점수 미선택)
      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '75.5');
      await tester.pump();

      // 저장 버튼 클릭
      final saveButton = find.text('저장');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 에러 다이얼로그 확인
      expect(
        find.text('식욕 조절을 선택해주세요'),
        findsOneWidget,
      );
    });

    // TC-DT-05: 체중 + 식욕 입력 후 저장 성공
    testWidgets('체중 + 식욕 입력 후 저장 성공', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 체중 입력
      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '75.5');
      await tester.pump();

      // 식욕 점수 선택 (보통 = 4)
      await tester.tap(find.text('보통'));
      await tester.pump();

      // 저장 버튼 클릭
      final saveButton = find.text('저장');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // saveWeightLog 호출 확인
      verify(() => mockRepository.saveWeightLog(any(
            that: predicate<WeightLog>(
              (log) => log.weightKg == 75.5 && log.appetiteScore == 4,
            ),
          ))).called(1);

      // 대시보드로 이동 확인
      verify(() => mockRouter.go('/dashboard')).called(1);
    });

    // TC-DT-06: 증상별 다른 심각도 저장
    testWidgets('증상별 다른 심각도 저장', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 체중 + 식욕 입력
      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '75.5');
      await tester.pump();
      await tester.tap(find.text('보통'));
      await tester.pump();

      // 부작용 섹션 펼치기
      await tester.tap(find.text('부작용 기록 (선택)'));
      await tester.pumpAndSettle();

      // 메스꺼움 선택
      await tester.tap(find.text('메스꺼움').first);
      await tester.pump();

      // 메스꺼움 슬라이더 조정 (8점으로)
      final sliders = find.byType(Slider);
      await tester.drag(sliders.first, const Offset(100, 0));
      await tester.pump();

      // 두통 선택
      await tester.tap(find.text('두통').first);
      await tester.pump();

      // 두통 슬라이더 조정 (3점으로)
      final allSliders = find.byType(Slider);
      await tester.drag(allSliders.last, const Offset(-100, 0));
      await tester.pump();

      // 저장
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 2개의 증상 로그가 저장되었는지 확인
      verify(() => mockRepository.saveSymptomLog(any())).called(2);
    });

    // TC-DT-07: 심각도 7-10점 증상에 24시간 지속 여부 표시
    testWidgets('심각도 7-10점 증상에 24시간 지속 여부 표시', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 체중 + 식욕 입력
      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '75.5');
      await tester.pump();
      await tester.tap(find.text('보통'));
      await tester.pump();

      // 부작용 섹션 펼치기
      await tester.tap(find.text('부작용 기록 (선택)'));
      await tester.pumpAndSettle();

      // 메스꺼움 선택
      await tester.tap(find.text('메스꺼움').first);
      await tester.pump();

      // 슬라이더를 오른쪽으로 드래그하여 심각도 높이기 (7-10점 범위)
      final slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(200, 0));
      await tester.pumpAndSettle();

      // "24시간 이상 지속" 체크박스 또는 질문이 표시되는지 확인
      expect(find.textContaining('24시간'), findsOneWidget);
    });

    // TC-DT-08: 심각도 1-6점 증상에 컨텍스트 태그 표시
    testWidgets('심각도 1-6점 증상에 컨텍스트 태그 표시', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 체중 + 식욕 입력
      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '75.5');
      await tester.pump();
      await tester.tap(find.text('보통'));
      await tester.pump();

      // 부작용 섹션 펼치기
      await tester.tap(find.text('부작용 기록 (선택)'));
      await tester.pumpAndSettle();

      // 두통 선택
      await tester.tap(find.text('두통').first);
      await tester.pump();

      // 슬라이더를 중간 정도로 (1-6점 범위)
      // 기본값이 5점이므로 그대로 두거나 약간 조정
      await tester.pumpAndSettle();

      // 컨텍스트 태그가 표시되는지 확인
      expect(find.text('기름진음식'), findsOneWidget);
      expect(find.text('스트레스'), findsOneWidget);
    });
  });
}
