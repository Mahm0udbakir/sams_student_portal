import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class ThemeToggled extends ThemeEvent {
  const ThemeToggled(this.isDarkModeEnabled);

  final bool isDarkModeEnabled;

  @override
  List<Object?> get props => [isDarkModeEnabled];
}
