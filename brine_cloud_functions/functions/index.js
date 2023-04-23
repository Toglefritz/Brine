const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize the Firebase project
admin.initializeApp();

// Create a reference to the Firestore database
const db = admin.firestore();

// Defines a Firebase Callable Function called updateDeviceLevels that updates the "battery_level" and "salt_level" 
// fields in the Firestore document with the specified "device_id". The function checks if the user is authenticated 
// and validates the input data before updating the Firestore document.
const updateDeviceLevels = functions.https.onCall(async (data, context) => {
    // Check if the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated to update device levels.');
    }

    // Get the parameters from the request
    const deviceId = data.device_id;
    const batteryLevel = data.battery_level;
    const saltLevel = data.salt_level;

    // Validate the input data
    if (!deviceId || typeof batteryLevel === 'undefined' || typeof saltLevel === 'undefined') {
        throw new functions.https.HttpsError('invalid-argument', 'Device ID, battery level, and salt level are required.');
    }

    // Update the Firestore document
    try {
        await db.collection('devices').doc(deviceId).update({
            'battery_level': batteryLevel,
            'salt_level': saltLevel,
        });
        return { result: 'Device levels updated successfully.' };
    } catch (error) {
        throw new functions.https.HttpsError('unknown', 'An error occurred while updating the device levels.', error);
    }
});

exports.updateDeviceLevels = updateDeviceLevels;