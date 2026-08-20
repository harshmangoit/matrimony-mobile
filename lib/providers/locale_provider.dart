import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/localization/app_translations.dart';

const _storage = FlutterSecureStorage();
const _localeKey = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('hi')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final savedCode = await _storage.read(key: _localeKey);
      if (savedCode != null && (savedCode == 'en' || savedCode == 'hi')) {
        state = Locale(savedCode);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    if (newLocale.languageCode == 'en' || newLocale.languageCode == 'hi') {
      state = newLocale;
      await _storage.write(key: _localeKey, value: newLocale.languageCode);
    }
  }

  String translate(String key) {
    return AppTranslations.getText(state.languageCode, key);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

extension LocalizationExtension on WidgetRef {
  String tr(String key) {
    final locale = watch(localeProvider);
    return AppTranslations.getText(locale.languageCode, key);
  }
}
