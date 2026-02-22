import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_localizations.dart';

class LocaleController extends ChangeNotifier {
  static const String _localeKey = 'app_locale_code';

  Locale _locale = _resolveDeviceLocale();
  bool _initialized = false;

  Locale get locale => _locale;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);

    if (savedCode != null && savedCode.isNotEmpty) {
      _locale = Locale(savedCode);
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) {
      return;
    }

    _locale = Locale(locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.languageCode);
    notifyListeners();
  }

  static Locale _resolveDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final supportedCodes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    final code = supportedCodes.contains(deviceLocale.languageCode)
        ? deviceLocale.languageCode
        : 'en';
    return Locale(code);
  }
}
