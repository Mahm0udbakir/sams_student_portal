import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static bool get isLoaded => dotenv.isInitialized;

  static String read(
    String key, {
    String fallback = '',
  }) {
    return dotenv.env[key]?.trim().isNotEmpty == true
        ? dotenv.env[key]!.trim()
        : fallback;
  }
}