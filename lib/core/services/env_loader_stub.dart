import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnvSafeImpl({String fileName = '.env'}) async {
  try {
    await dotenv.load(fileName: fileName);
  } catch (_) {}
}
