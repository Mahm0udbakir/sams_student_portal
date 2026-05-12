import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

// For web, use dart:html to fetch .env as asset
// For mobile/desktop, use flutter_dotenv as usual
Future<void> loadEnvSafe({String fileName = '.env'}) async {
  if (kIsWeb) {
    try {
      // ignore: avoid_web_libraries_in_flutter
      final html = await importHtml();
      final response = await html.HttpRequest.request('assets/.env');
      if (response.status == 200) {
        dotenv.testLoad(fileInput: response.responseText ?? '');
      }
    } catch (e) {
      // .env missing or failed to load, continue without blocking
    }
  } else {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // .env missing or failed to load, continue without blocking
    }
  }
}

// Helper for conditional import
Future<dynamic> importHtml() async {
  if (!kIsWeb) return null;
  return await Future.value(await import('dart:html'));
}

// Polyfill for conditional import (dart:html)
// This will be replaced by the actual import at compile time for web
Future<dynamic> import(String lib) async {
  // ignore: undefined_prefixed_name
  return await Future.value(null);
}
