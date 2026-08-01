import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Local app preferences (theme + notification toggles).
///
/// Not for secrets — tokens stay in [SecureStorageService].
class PreferencesStorage {
  PreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesStorage(prefs);
  }

  ThemeMode readThemeMode() {
    final raw = _prefs.getString(AppConstants.themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.themeModeKey, value);
  }

  bool readBool(String key, {bool defaultValue = true}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> clearPreferenceKeys() async {
    await _prefs.remove(AppConstants.themeModeKey);
    await _prefs.remove(AppConstants.notifyContributionsKey);
    await _prefs.remove(AppConstants.notifyLoansKey);
    await _prefs.remove(AppConstants.notifyMeetingsKey);
    await _prefs.remove(AppConstants.notifyAnnouncementsKey);
  }
}
