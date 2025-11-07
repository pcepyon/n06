import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/presentation/screens/coping_guide_screen.dart';

void main() {
  group('CopingGuideScreen', () {
    testWidgets('위젯이 생성 가능함', (WidgetTester tester) async {
      // Test that the widget can be instantiated
      const screen = CopingGuideScreen();
      expect(screen, isNotNull);
    });
  });
}
