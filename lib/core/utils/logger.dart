import 'dart:developer' as developer;
import '../config/app_config.dart';

class Logger {
  static void log(String message, {String? name}) {
    if (AppConfig.enableLogging) {
      developer.log(message, name: name ?? 'SAMS');
    }
  }
}
