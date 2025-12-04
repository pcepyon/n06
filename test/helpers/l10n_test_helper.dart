import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:n06/l10n/generated/app_localizations.dart';

/// Helper class for testing widgets with L10n support
///
/// Usage:
/// ```dart
/// testWidgets('displays Korean text', (tester) async {
///   await tester.pumpWidget(
///     L10nTestHelper.wrapWithL10n(
///       const MyWidget(),
///       locale: const Locale('ko'),
///     ),
///   );
///   expect(find.text('확인'), findsOneWidget);
/// });
/// ```
class L10nTestHelper {
  /// Wraps a widget with L10n support for testing
  static Widget wrapWithL10n(
    Widget child, {
    Locale locale = const Locale('ko'),
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }

  /// Wraps a widget with L10n and custom theme for testing
  static Widget wrapWithL10nAndTheme(
    Widget child, {
    Locale locale = const Locale('ko'),
    ThemeData? theme,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      theme: theme,
      home: Scaffold(body: child),
    );
  }
}
