import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;

  SettingsState({required this.themeMode, required this.language});

  SettingsState copyWith({ThemeMode? themeMode, String? language}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(SettingsState(themeMode: ThemeMode.light, language: 'vi'));

  void changeTheme(ThemeMode mode) => emit(state.copyWith(themeMode: mode));
  void changeLanguage(String lang) => emit(state.copyWith(language: lang));
}
