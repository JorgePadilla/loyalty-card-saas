import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart' show secureStorageProvider;
import '../storage/secure_storage.dart';

/// Locales the app supports.
const kSupportedLanguageCodes = ['en', 'es'];

/// Holds the active app [Locale]. Resolution order:
///   1. The language the user explicitly chose (persisted in secure storage)
///   2. The device language, if supported
///   3. English
/// The resolved language is always persisted so the API client can send a
/// matching `Accept-Language` header.
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(secureStorageProvider));
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._storage) : super(null) {
    _load();
  }

  final SecureStorage _storage;

  Future<void> _load() async {
    final saved = await _storage.getLocale();
    if (saved != null && kSupportedLanguageCodes.contains(saved)) {
      state = Locale(saved);
      return;
    }

    final device =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final resolved = kSupportedLanguageCodes.contains(device) ? device : 'en';
    state = Locale(resolved);
    await _storage.saveLocale(resolved);
  }

  /// Change the app language and remember the choice.
  Future<void> setLocale(String code) async {
    if (!kSupportedLanguageCodes.contains(code)) return;
    state = Locale(code);
    await _storage.saveLocale(code);
  }
}
