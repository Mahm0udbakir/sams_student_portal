class AttendanceScanException implements Exception {
  const AttendanceScanException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AttendanceDuplicateScanException extends AttendanceScanException {
  const AttendanceDuplicateScanException()
      : super('You already scanned attendance for this session.');
}

class AttendanceSessionNotFoundException extends AttendanceScanException {
  const AttendanceSessionNotFoundException()
      : super('This attendance session is not available anymore.');
}
