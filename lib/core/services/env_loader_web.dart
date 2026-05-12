import 'dart:html' as html;

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnvSafeImpl({String fileName = '.env'}) async {
  try {
    final response = await html.HttpRequest.request(
      'assets/$fileName',
      method: 'GET',
    );
    if (response.status == 200) {
      dotenv.loadFromString(
        envString: response.responseText ?? '',
        isOptional: true,
      );
    }
  } catch (_) {}
}
