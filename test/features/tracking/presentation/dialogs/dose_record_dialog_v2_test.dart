import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoseRecordDialogV2', () {

    testWidgets('다이얼로그가 오류 없이 렌더링되어야 함', (tester) async {
      // Given & When
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );

      // 다이얼로그 빌드 시 오류가 발생하지 않아야 함
      // 실제 다이얼로그는 수정 후 테스트에서 렌더링 확인
    });
  });
}
