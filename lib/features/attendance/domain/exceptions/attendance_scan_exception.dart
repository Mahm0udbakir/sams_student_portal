class AttendanceScanException implements Exception {
  const AttendanceScanException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AttendanceDuplicateScanException extends AttendanceScanException {
  const AttendanceDuplicateScanException()
      : super('You already recorded attendance for this course and scan.');
}

class AttendanceSessionNotFoundException extends AttendanceScanException {
  const AttendanceSessionNotFoundException()
      : super('This attendance session is not available anymore.');
}
