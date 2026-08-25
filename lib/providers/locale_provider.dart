import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/localization/app_translations.dart';
import 'auth_provider.dart';
import 'children_provider.dart';
import 'matches_provider.dart';
import 'payment_provider.dart';

const _storage = FlutterSecureStorage();
const _localeKey = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref _ref;

  LocaleNotifier(this._ref) : super(const Locale('hi')) {
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
      _reloadAppData();
    }
  }

  void _reloadAppData() {
    try {
      _ref.read(authProvider.notifier).reloadProfile();
      _ref.read(childrenProvider.notifier).loadChildren();
      final selectedChild = _ref.read(childrenProvider).selectedChild;
      if (selectedChild != null) {
        _ref.read(matchesProvider.notifier).loadMatches(selectedChild.id);
      }
      _ref.read(paymentProvider.notifier).loadPlansAndSubscription();
    } catch (_) {}
  }

  String translate(String key) {
    return AppTranslations.getText(state.languageCode, key);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

extension LocalizationExtension on WidgetRef {
  String tr(String key) {
    final locale = watch(localeProvider);
    return AppTranslations.getText(locale.languageCode, key);
  }
}
