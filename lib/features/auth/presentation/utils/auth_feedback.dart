import '../../domain/entities/auth_error.dart';

String authErrorTitle(AuthErrorType type) {
  switch (type) {
    case AuthErrorType.invalidEmail:
      return 'Invalid email';
    case AuthErrorType.weakPassword:
      return 'Weak password';
    case AuthErrorType.emailAlreadyInUse:
      return 'Email already used';
    case AuthErrorType.invalidCredential:
    case AuthErrorType.wrongPassword:
      return 'Wrong credentials';
    case AuthErrorType.userNotFound:
      return 'Account not found';
    case AuthErrorType.userDisabled:
      return 'Account disabled';
    case AuthErrorType.tooManyRequests:
      return 'Too many attempts';
    case AuthErrorType.operationNotAllowed:
      return 'Action not allowed';
    case AuthErrorType.network:
      return 'Network issue';
    case AuthErrorType.emailNotAllowed:
      return 'Email not allowed';
    case AuthErrorType.otpNotFound:
      return 'Verification code missing';
    case AuthErrorType.otpInvalid:
      return 'Invalid verification code';
    case AuthErrorType.otpExpired:
      return 'Verification code expired';
    case AuthErrorType.otpTooManyAttempts:
      return 'Too many OTP attempts';
    case AuthErrorType.otpAlreadyUsed:
      return 'Verification code already used';
    case AuthErrorType.invalidVerificationId:
      return 'Verification session expired';
    case AuthErrorType.documentCreationFailed:
      return 'Profile setup failed';
    case AuthErrorType.emailVerificationRequired:
      return 'Email verification required';
    case AuthErrorType.accountNotVerified:
      return 'Account not verified';
    case AuthErrorType.unknown:
      return 'Something went wrong';
  }
}

String authErrorMessage(AuthErrorType type, String fallbackMessage) {
  switch (type) {
    case AuthErrorType.invalidEmail:
      return 'Check the email address format and try again.';
    case AuthErrorType.weakPassword:
      return 'Use a stronger password with at least 6 characters.';
    case AuthErrorType.emailAlreadyInUse:
      return 'That email is already registered. Try signing in instead.';
    case AuthErrorType.invalidCredential:
    case AuthErrorType.wrongPassword:
      return 'Double-check your email and password.';
    case AuthErrorType.userNotFound:
      return 'No account exists for that email address.';
    case AuthErrorType.userDisabled:
      return 'This account is currently disabled.';
    case AuthErrorType.tooManyRequests:
      return 'Too many attempts. Wait a moment and try again.';
    case AuthErrorType.operationNotAllowed:
      return 'This sign-in method is not enabled or allowed.';
    case AuthErrorType.network:
      return 'Check your connection and try again.';
    case AuthErrorType.emailNotAllowed:
      return 'Use your approved university email address.';
    case AuthErrorType.otpNotFound:
      return 'The verification session could not be found.';
    case AuthErrorType.otpInvalid:
      return 'The verification code is not correct.';
    case AuthErrorType.otpExpired:
      return 'That verification code has expired.';
    case AuthErrorType.otpTooManyAttempts:
      return 'Too many wrong attempts. Request a new code.';
    case AuthErrorType.otpAlreadyUsed:
      return 'That code was already used. Request a new one.';
    case AuthErrorType.invalidVerificationId:
      return 'Start the verification flow again.';
    case AuthErrorType.documentCreationFailed:
      return 'We could not save your profile. Please try again.';
    case AuthErrorType.emailVerificationRequired:
      return 'Verify your email before continuing.';
    case AuthErrorType.accountNotVerified:
      return 'Your account is not verified yet.';
    case AuthErrorType.unknown:
      return fallbackMessage;
  }
}
