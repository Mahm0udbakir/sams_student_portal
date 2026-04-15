import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_event.dart';
import 'theme_state.dart';

export 'theme_event.dart';
export 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({ThemeMode initialThemeMode = ThemeMode.light})
    : super(ThemeState(themeMode: initialThemeMode)) {
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<ThemeToggled>(_onThemeToggled);
  }

  void _onThemeModeChanged(ThemeModeChanged event, Emitter<ThemeState> emit) {
    _emitMode(event.themeMode, emit);
  }

  void _onThemeToggled(ThemeToggled event, Emitter<ThemeState> emit) {
    _emitMode(event.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light, emit);
  }

  void _emitMode(ThemeMode mode, Emitter<ThemeState> emit) {
    if (state.themeMode == mode) {
      return;
    }
    emit(state.copyWith(themeMode: mode));
  }

  void setThemeMode(ThemeMode themeMode) {
    add(ThemeModeChanged(themeMode));
  }

  void toggleDarkMode(bool isDarkModeEnabled) {
    add(ThemeToggled(isDarkModeEnabled));
  }
}
