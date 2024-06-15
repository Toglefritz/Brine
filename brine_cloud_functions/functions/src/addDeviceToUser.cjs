const admin = require('../adminInit.cjs');

/**
 * Adds a device to the user's list of devices.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<Object>} A promise that resolves to an object with the result message.
 * @throws {functions.https.HttpsError} If the function encounters an error.
 */
async function addDeviceToUser(req, res) {
    // Check for the Authorization header
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        res.status(401).send('Unauthorized');
        return;
    }

    // Extract the Firebase Auth ID token
    const idToken = req.headers.authorization.split('Bearer ')[1];

    // Extract the device ID from the request
    const deviceId = req.body.deviceId;
    if (!deviceId) {
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "deviceId".');
    }

    try {
        // Verify the ID token and get the UID
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userUid = decodedToken.uid;

        // Get the user document from Firestore
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        if (!userDocSnapshot.exists) {
            res.status(404).send('User not found');
            return;
        }

        // Add the device to the user's list of devices
        const devices = userDocSnapshot.get('devices') || [];
        devices.push(deviceId);
        await userDocRef.update({ devices: devices });

        res.status(200).send('Device added successfully');
    } catch (error) {
        console.error('Error verifying Firebase ID token:', error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { addDeviceToUser };