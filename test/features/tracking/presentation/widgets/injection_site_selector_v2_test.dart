import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/presentation/widgets/injection_site_selector_v2.dart';

void main() {
  group('InjectionSiteSelectorV2 - AlertDialog intrinsic dimension issue', () {
    testWidgets('should render without error inside AlertDialog', (tester) async {
      // Arrange
      String? selectedSite;
      final recentRecords = <DoseRecord>[
        DoseRecord(
          id: '1',
          doseScheduleId: 'schedule-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now().subtract(const Duration(days: 3)),
          injectionSite: 'abdomen_upper_left',
          actualDoseMg: 1.0,
          createdAt: DateTime.now(),
        ),
      ];

      // Act - 이 부분에서 AlertDialog 내부에 위젯을 렌더링하면 에러 발생 예상
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('투여 기록'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InjectionSiteSelectorV2(
                                initialSite: null,
                                recentRecords: recentRecords,
                                onSiteSelected: (site) {
                                  selectedSite = site;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('다이얼로그 열기'),
                ),
              ),
            ),
          ),
        ),
      );

      // 버튼 탭하여 다이얼로그 열기
      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      // Assert - 다이얼로그가 에러 없이 렌더링되어야 함
      expect(find.text('주사 부위 선택'), findsOneWidget);
      expect(find.text('복부 (4개 부위)'), findsOneWidget);
      
      // ExpansionTile 확장하여 버튼들이 보이는지 확인
      await tester.tap(find.text('복부 (4개 부위)'));
      await tester.pumpAndSettle();

      // 주사 부위 버튼들이 렌더링되어야 함
      expect(find.text('좌측 상단'), findsOneWidget);
      expect(find.text('우측 상단'), findsOneWidget);
      expect(find.text('좌측 하단'), findsOneWidget);
      expect(find.text('우측 하단'), findsOneWidget);
    });

    testWidgets('should maintain grid layout with Wrap widget', (tester) async {
      // Arrange
      String? selectedSite;
      final recentRecords = <DoseRecord>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InjectionSiteSelectorV2(
                initialSite: null,
                recentRecords: recentRecords,
                onSiteSelected: (site) {
                  selectedSite = site;
                },
              ),
            ),
          ),
        ),
      );

      // 복부 그룹 확장
      await tester.tap(find.text('복부 (4개 부위)'));
      await tester.pumpAndSettle();

      // Assert - 4개의 버튼이 모두 표시되어야 함
      expect(find.text('좌측 상단'), findsOneWidget);
      expect(find.text('우측 상단'), findsOneWidget);
      expect(find.text('좌측 하단'), findsOneWidget);
      expect(find.text('우측 하단'), findsOneWidget);

      // 버튼 선택 기능 확인
      await tester.tap(find.text('좌측 상단'));
      await tester.pump();

      expect(selectedSite, 'abdomen_upper_left');
    });

    testWidgets('should show rotation warning for recently used site', (tester) async {
      // Arrange
      String? selectedSite;
      final recentRecords = <DoseRecord>[
        DoseRecord(
          id: '1',
          doseScheduleId: 'schedule-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now().subtract(const Duration(days: 3)),
          injectionSite: 'abdomen_upper_left',
          actualDoseMg: 1.0,
          createdAt: DateTime.now(),
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InjectionSiteSelectorV2(
                initialSite: null,
                recentRecords: recentRecords,
                onSiteSelected: (site) {
                  selectedSite = site;
                },
              ),
            ),
          ),
        ),
      );

      // 복부 그룹 확장
      await tester.tap(find.text('복부 (4개 부위)'));
      await tester.pumpAndSettle();

      // 최근 사용한 부위 선택
      await tester.tap(find.text('좌측 상단'));
      await tester.pumpAndSettle();

      // Assert - 경고 메시지가 표시되어야 함
      expect(find.textContaining('일 전에 사용했습니다'), findsOneWidget);
      expect(find.textContaining('1주 이상 간격을 권장합니다'), findsOneWidget);
    });
  });
}
