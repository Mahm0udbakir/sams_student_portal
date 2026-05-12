import 'package:dio/dio.dart';

import '../config/env.dart';

class BrevoEmailService {
  BrevoEmailService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> sendOtpEmail({
    required String email,
    required String name,
    required String otp,
    required String purpose,
    required DateTime expiresAt,
  }) async {
    final apiKey = AppEnv.read('BREVO_API_KEY');
    final senderEmail = AppEnv.read('BREVO_SENDER_EMAIL');
    final senderName = AppEnv.read('BREVO_SENDER_NAME', fallback: 'SAMS Portal');
    final templateId = AppEnv.read('BREVO_TEMPLATE_ID');

    if (apiKey.isEmpty) {
      throw StateError('BREVO_API_KEY is missing from .env');
    }

    final subjectPrefix = purpose == 'signup' ? 'Verify your account' : 'Login code';
    final payload = <String, dynamic>{
      'sender': {'name': senderName, 'email': senderEmail},
      'to': [
        {'email': email, 'name': name},
      ],
      'subject': '$subjectPrefix - SAMS Student Portal',
    };

    final parsedTemplateId = int.tryParse(templateId);
    if (parsedTemplateId != null && parsedTemplateId > 0) {
      payload['templateId'] = parsedTemplateId;
      payload['params'] = {
        'name': name,
        'otp': otp,
        'purpose': purpose,
        'expiresAt': expiresAt.toIso8601String(),
      };
    } else {
      payload['htmlContent'] = _buildOtpEmailBody(
        name: name,
        otp: otp,
        purpose: purpose,
        expiresAt: expiresAt,
      );
    }

    await _dio.post(
      'https://api.brevo.com/v3/smtp/email',
      options: Options(
        headers: {
          'api-key': apiKey,
          'content-type': 'application/json',
          'accept': 'application/json',
        },
      ),
      data: payload,
    );
  }

  String _buildOtpEmailBody({
    required String name,
    required String otp,
    required String purpose,
    required DateTime expiresAt,
  }) {
    final label = purpose == 'signup' ? 'sign up' : 'sign in';
    return '''
      <html>
        <body style="font-family: Arial, sans-serif; background: #f4f8fb; margin: 0; padding: 24px;">
          <div style="max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 18px; padding: 28px; border: 1px solid #d7e3ef;">
            <h2 style="margin: 0 0 12px; color: #063454;">SAMS verification code</h2>
            <p style="margin: 0 0 10px; color: #1f2937;">Hello $name,</p>
            <p style="margin: 0 0 16px; color: #374151;">Use the code below to $label to the SAMS Student Portal.</p>
            <div style="font-size: 28px; letter-spacing: 8px; font-weight: 800; color: #063454; background: #eef6fb; padding: 16px 20px; border-radius: 14px; text-align: center;">$otp</div>
            <p style="margin: 16px 0 0; color: #6b7280; font-size: 13px;">This code expires at ${expiresAt.toLocal()}.</p>
          </div>
        </body>
      </html>
    ''';
  }
}
