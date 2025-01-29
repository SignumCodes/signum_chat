import 'package:flutter/material.dart';


enum AppTheme { light, dark }

/// The abstract class for all theme states
abstract class ThemeState {}

/// The initial state when the app is starting or when no theme is applied yet.
class ThemeInitial extends ThemeState {}

/// State for light theme
class LightThemeState extends ThemeState {
  final Brightness brightness;

  LightThemeState() : brightness = Brightness.light;
}

/// State for dark theme
class DarkThemeState extends ThemeState {
  final Brightness brightness;

  DarkThemeState() : brightness = Brightness.dark;
}

/// State indicating the theme change is in progress (for example, during a network request or loading state)
class ThemeLoadingState extends ThemeState {}

/// State indicating there was an error while loading or changing the theme
class ThemeErrorState extends ThemeState {
  final String message;

  ThemeErrorState(this.message);
}

class LocalThemeState extends ThemeState{}
