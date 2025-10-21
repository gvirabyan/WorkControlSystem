const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendTestNotification = functions.https.onCall(async (data, context) => {
  const promoCode = data.promoCode;

  if (!promoCode) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "promoCode".');
  }

  const usersSnapshot = await admin.firestore().collection('users').where('promoCode', '==', promoCode).get();

  const tokens = [];
  usersSnapshot.forEach(userDoc => {
    const token = userDoc.data().fcmToken;
    if (token) {
      tokens.push(token);
    }
  });

  if (tokens.length > 0) {
    const payload = {
      notification: {
        title: 'Test Notification',
        body: 'This is a test notification from the company dashboard.',
      },
    };

    const response = await admin.messaging().sendToDevice(tokens, payload);
    console.log('Successfully sent message:', response);
    return { success: true, message: 'Notifications sent successfully.' };
  } else {
    console.log('No tokens found for the given promo code.');
    return { success: false, message: 'No tokens found.' };
  }
});
