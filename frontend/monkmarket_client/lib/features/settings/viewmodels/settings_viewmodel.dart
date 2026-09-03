import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/providers/providers.dart';

class SettingsState {
  final ThemeMode themeMode;

  const SettingsState({this.themeMode = ThemeMode.system});

  SettingsState copyWith({ThemeMode? themeMode}) {
    return SettingsState(themeMode: themeMode ?? this.themeMode);
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  final LocalStorage _localStorage;

  SettingsViewModel(this._localStorage) : super(const SettingsState());

  Future<void> loadSettings() async {
    final modeStr = await _localStorage.getThemeMode();
    final mode = _parseThemeMode(modeStr);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _localStorage.saveThemeMode(_themeModeToString(mode));
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
      return SettingsViewModel(ref.watch(localStorageProvider));
    });
