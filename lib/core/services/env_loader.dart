import 'env_loader_stub.dart' if (dart.library.html) 'env_loader_web.dart' as impl;

/// Loads [.env] without blocking app startup if the file is missing or fails (especially on web).
Future<void> loadEnvSafe({String fileName = '.env'}) async {
  await impl.loadEnvSafeImpl(fileName: fileName);
}
