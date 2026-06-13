const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { randomInt } = require('crypto');

admin.initializeApp();

function generateOtp() {
  return String(randomInt(100000, 1000000));
}

async function sendBrevoOtpEmail({
  email,
  name,
  otp,
  purpose,
  apiKey: incomingApiKey,
  senderEmail: incomingSenderEmail,
  senderName: incomingSenderName,
  templateId: incomingTemplateId,
}) {
  const apiKey = incomingApiKey || process.env.BREVO_API_KEY;
  const senderEmail = incomingSenderEmail || process.env.BREVO_SENDER_EMAIL;
  const senderName = incomingSenderName || process.env.BREVO_SENDER_NAME || 'SAMS Portal';
  const templateId = incomingTemplateId || process.env.BREVO_TEMPLATE_ID;

  if (!apiKey) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Brevo API key is missing on the server or in the app payload.',
    );
  }

  let resolvedSenderEmail = senderEmail;
  let resolvedSenderName = senderName;
  const parsedTemplateId = Number.parseInt(templateId || '', 10);
  if (!resolvedSenderEmail && Number.isFinite(parsedTemplateId) && parsedTemplateId > 0) {
    const templateResponse = await fetch(
      `https://api.brevo.com/v3/smtp/templates/${parsedTemplateId}`,
      {
        method: 'GET',
        headers: {
          'api-key': apiKey,
          accept: 'application/json',
        },
      },
    );

    if (templateResponse.ok) {
      const template = await templateResponse.json();
      const templateSender = template && template.sender ? template.sender : null;
      if (templateSender && typeof templateSender === 'object') {
        resolvedSenderEmail = String(templateSender.email || '').trim();
        resolvedSenderName = String(templateSender.name || resolvedSenderName).trim() || resolvedSenderName;
      }
    }
  }

  if (!resolvedSenderEmail) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Brevo sender email is missing. Add BREVO_SENDER_EMAIL or set a sender on the Brevo template.',
    );
  }

  const expiresLabel = new Date(Date.now() + 10 * 60 * 1000).toISOString();
  const subjectPrefix = purpose === 'signup' ? 'Verify your account' : 'Login code';
  const payload = {
    to: [{ email, name }],
    subject: `${subjectPrefix} - SAMS Student Portal`,
  };

  if (resolvedSenderEmail) {
    payload.sender = { name: resolvedSenderName, email: resolvedSenderEmail };
  }

  if (Number.isFinite(parsedTemplateId) && parsedTemplateId > 0) {
    payload.templateId = parsedTemplateId;
    payload.params = { name, otp, purpose, expiresAt: expiresLabel };
  } else {
    payload.htmlContent = `
      <html>
        <body style="font-family: Arial, sans-serif; background: #f4f8fb; margin: 0; padding: 24px;">
          <div style="max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 18px; padding: 28px; border: 1px solid #d7e3ef;">
            <h2 style="margin: 0 0 12px; color: #063454;">SAMS verification code</h2>
            <p style="margin: 0 0 10px; color: #1f2937;">Hello ${name},</p>
            <p style="margin: 0 0 16px; color: #374151;">Use the code below to ${purpose === 'signup' ? 'sign up' : 'sign in'} to the SAMS Student Portal.</p>
            <div style="font-size: 28px; letter-spacing: 8px; font-weight: 800; color: #063454; background: #eef6fb; padding: 16px 20px; border-radius: 14px; text-align: center;">${otp}</div>
            <p style="margin: 16px 0 0; color: #6b7280; font-size: 13px;">This code expires at ${expiresLabel}.</p>
          </div>
        </body>
      </html>
    `;
  }

  const response = await fetch('https://api.brevo.com/v3/smtp/email', {
    method: 'POST',
    headers: {
      'api-key': apiKey,
      'content-type': 'application/json',
      accept: 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new functions.https.HttpsError(
      'internal',
      `Brevo request failed: ${response.status} ${body}`,
    );
  }
}

exports.requestLoginOtp = functions.https.onCall(async (data) => {
  const email = String(data.email || '').trim().toLowerCase();
  const name = String(data.name || '').trim() || 'Student';
  const purpose = String(data.purpose || 'login').trim().toLowerCase();

  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'email is required.');
  }

  if (purpose !== 'login') {
    throw new functions.https.HttpsError('failed-precondition', 'This callable is for login only.');
  }

  const verificationId = admin.firestore().collection('auth_otps').doc().id;
  const otp = generateOtp();
  const expiresAt = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 10 * 60 * 1000),
  );

  await admin.firestore().collection('auth_otps').doc(verificationId).set({
    verificationId,
    email,
    name,
    purpose,
    otp,
    attempts: 0,
    maxAttempts: 5,
    consumed: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt,
  });

  await sendBrevoOtpEmail({
    email,
    name,
    otp,
    purpose,
    apiKey: String(data.brevoApiKey || '').trim(),
    senderEmail: String(data.brevoSenderEmail || '').trim(),
    senderName: String(data.brevoSenderName || '').trim(),
    templateId: String(data.brevoTemplateId || '').trim(),
  });

  return {
    verificationId,
    email,
    name,
    expiresAt: expiresAt.toDate().toISOString(),
    attemptsRemaining: 5,
  };
});

exports.requestSignupOtp = functions.https.onCall(async (data) => {
  const email = String(data.email || '').trim().toLowerCase();
  const name = String(data.name || '').trim() || 'Student';
  const purpose = String(data.purpose || 'signup').trim().toLowerCase();
  const firstName = String(data.firstName || '').trim();
  const lastName = String(data.lastName || '').trim();
  const studentId = String(data.studentId || '').trim();
  const department = String(data.department || '').trim();

  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'email is required.');
  }

  if (purpose !== 'signup') {
    throw new functions.https.HttpsError('failed-precondition', 'This callable is for signup only.');
  }

  let accountExists = false;
  try {
    await admin.auth().getUserByEmail(email);
    accountExists = true;
  } catch (error) {
    if (error.code !== 'auth/user-not-found') {
      throw new functions.https.HttpsError(
        'internal',
        `Could not check whether the account exists: ${error.message || error.toString()}`,
      );
    }
  }

  if (accountExists) {
    throw new functions.https.HttpsError(
      'already-exists',
      'An account already exists for this email address. Please sign in instead.',
    );
  }

  const userRecord = await admin.auth().createUser({
    email,
    displayName: name,
    emailVerified: false,
    disabled: false,
  });

  const createdAt = admin.firestore.FieldValue.serverTimestamp();
  await admin.firestore().collection('users').doc(userRecord.uid).set({
    uid: userRecord.uid,
    email,
    name,
    firstName,
    lastName,
    studentId,
    department,
    role: 'student',
    emailVerified: false,
    isActive: true,
    createdAt,
    updatedAt: createdAt,
    lastLoginAt: createdAt,
  }, { merge: true });

  const verificationId = admin.firestore().collection('auth_otps').doc().id;
  const otp = generateOtp();
  const expiresAt = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 10 * 60 * 1000),
  );
  const challengeRef = admin.firestore().collection('auth_otps').doc(verificationId);

  try {
    await challengeRef.set({
      verificationId,
      email,
      name,
      purpose,
      otp,
      attempts: 0,
      maxAttempts: 5,
      consumed: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
    });

    await sendBrevoOtpEmail({
      email,
      name,
      otp,
      purpose,
      apiKey: String(data.brevoApiKey || '').trim(),
      senderEmail: String(data.brevoSenderEmail || '').trim(),
      senderName: String(data.brevoSenderName || '').trim(),
      templateId: String(data.brevoTemplateId || '').trim(),
    });

    return {
      verificationId,
      email,
      name,
      expiresAt: expiresAt.toDate().toISOString(),
      attemptsRemaining: 5,
    };
  } catch (error) {
    await Promise.allSettled([
      challengeRef.delete(),
      admin.auth().deleteUser(userRecord.uid),
    ]);
    throw error;
  }
});

/**
 * Verifies a Brevo OTP challenge for purpose "login" and returns a Firebase custom token.
 * Deploy with: firebase deploy --only functions
 */
exports.exchangeLoginOtp = functions.https.onCall(async (data) => {
  const verificationId = String(data.verificationId || '').trim();
  const otp = String(data.otp || '').trim();

  if (!verificationId || !otp) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'verificationId and otp are required.',
    );
  }

  const docRef = admin.firestore().collection('auth_otps').doc(verificationId);
  const snap = await docRef.get();

  if (!snap.exists) {
    throw new functions.https.HttpsError(
      'not-found',
      'Verification session was not found.',
    );
  }

  const d = snap.data() || {};
  if (d.consumed === true) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'This verification code was already used.',
    );
  }

  if ((d.purpose || '').toLowerCase() !== 'login') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Invalid verification flow.',
    );
  }

  const expiresAt = d.expiresAt && d.expiresAt.toDate ? d.expiresAt.toDate() : null;
  if (!expiresAt || new Date() > expiresAt) {
    throw new functions.https.HttpsError(
      'deadline-exceeded',
      'This verification code expired.',
    );
  }

  const attempts = typeof d.attempts === 'number' ? d.attempts : 0;
  const maxAttempts = typeof d.maxAttempts === 'number' ? d.maxAttempts : 5;
  if (attempts >= maxAttempts) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Too many failed attempts.',
    );
  }

  const storedOtp = String(d.otp || '').trim();
  if (storedOtp !== otp) {
    await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid verification code.',
    );
  }

  await docRef.update({
    consumed: true,
    verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const email = String(d.email || '')
    .trim()
    .toLowerCase();
  if (!email) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Challenge is missing email.',
    );
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (e) {
    throw new functions.https.HttpsError(
      'not-found',
      'No Firebase account exists for this email.',
    );
  }

  const token = await admin.auth().createCustomToken(userRecord.uid);
  return { customToken: token };
});

exports.exchangeSignupOtp = functions.https.onCall(async (data) => {
  const verificationId = String(data.verificationId || '').trim();
  const otp = String(data.otp || '').trim();

  if (!verificationId || !otp) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'verificationId and otp are required.',
    );
  }

  const docRef = admin.firestore().collection('auth_otps').doc(verificationId);
  const snap = await docRef.get();

  if (!snap.exists) {
    throw new functions.https.HttpsError(
      'not-found',
      'Verification session was not found.',
    );
  }

  const d = snap.data() || {};
  if (d.consumed === true) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'This verification code was already used.',
    );
  }

  if ((d.purpose || '').toLowerCase() !== 'signup') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Invalid verification flow.',
    );
  }

  const expiresAt = d.expiresAt && d.expiresAt.toDate ? d.expiresAt.toDate() : null;
  if (!expiresAt || new Date() > expiresAt) {
    throw new functions.https.HttpsError(
      'deadline-exceeded',
      'This verification code expired.',
    );
  }

  const attempts = typeof d.attempts === 'number' ? d.attempts : 0;
  const maxAttempts = typeof d.maxAttempts === 'number' ? d.maxAttempts : 5;
  if (attempts >= maxAttempts) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Too many failed attempts.',
    );
  }

  const storedOtp = String(d.otp || '').trim();
  if (storedOtp !== otp) {
    await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid verification code.',
    );
  }

  await docRef.update({
    consumed: true,
    verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const email = String(d.email || '').trim().toLowerCase();
  if (!email) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Challenge is missing email.',
    );
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (e) {
    if (e && e.code !== 'auth/user-not-found') {
      throw e;
    }

    const fallbackDisplayName = String(d.name || '').trim() || email.split('@')[0] || 'Student';
    userRecord = await admin.auth().createUser({
      email,
      displayName: fallbackDisplayName,
      emailVerified: true,
      disabled: false,
    });
  }

  await admin.auth().updateUser(userRecord.uid, {
    emailVerified: true,
  });

  const token = await admin.auth().createCustomToken(userRecord.uid);
  return { customToken: token };
});
