const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

admin.initializeApp();

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
