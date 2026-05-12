import '../../features/home/domain/repositories/home_repository.dart';

/// Optional overrides for tests or tooling. Production code should leave these null.
abstract final class AppRuntime {
  static HomeRepository? homeRepositoryOverride;
}
