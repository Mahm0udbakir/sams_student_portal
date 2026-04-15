import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_event.dart';
import 'theme_state.dart';

export 'theme_event.dart';
export 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<ThemeToggled>(_onThemeToggled);
  }

  void _onThemeModeChanged(ThemeModeChanged event, Emitter<ThemeState> emit) {
    if (state.themeMode == event.themeMode) {
      return;
    }
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onThemeToggled(ThemeToggled event, Emitter<ThemeState> emit) {
    final nextMode = event.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    if (state.themeMode == nextMode) {
      return;
    }
    emit(state.copyWith(themeMode: nextMode));
  }

  void setThemeMode(ThemeMode themeMode) {
    add(ThemeModeChanged(themeMode));
  }

  void toggleDarkMode(bool isDarkModeEnabled) {
    add(ThemeToggled(isDarkModeEnabled));
  }
}
