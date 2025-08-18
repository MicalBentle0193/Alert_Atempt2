const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Triggered when a document is created in /notifications.
// Sends a notification to topic 'public'.
exports.sendNotificationToTopic = functions.firestore
  .document('notifications/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const title = data.title || 'Weather Alert';
    const body = data.body || '';
    const severity = data.severity || 'info';

    const message = {
      notification: {
        title: title,
        body: body,
      },
      android: {
        notification: {
          sound: 'scary_alert',
          channelId: 'wynford_alerts',
          defaultSound: false,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'scary_alert.wav',
          },
        },
      },
      topic: 'public',
      data: {
        severity: severity,
        source: 'firestore',
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log('Sent message:', response);
    } catch (error) {
      console.error('Error sending message:', error);
    }
  });
