import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers/shared_preferences_provider.dart';

part 'locale_notifier.g.dart';

/// Manages app locale state with persistence
///
/// - null: Use system default locale
/// - Locale('ko'): Force Korean
/// - Locale('en'): Force English
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    // Load saved locale from SharedPreferences
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_key);
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
    return null; // null = system default (device detection)
  }

  /// Set app locale
  ///
  /// - null: Use system default
  /// - Locale('ko'): Force Korean
  /// - Locale('en'): Force English
  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key); // Revert to system default
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    state = locale;
  }
}
