const admin = require('../adminInit.cjs');

/**
 * This function is triggered by HTTP requests. It retrieves the salt level and battery level for the
 * specified IoT device associated with the authenticated user. The Firestore structure consists of a
 * "users" collection that stores user documents with an array of associated device IDs, and a "devices"
 * collection that stores device documents with device ID, salt level, and battery level.
 *
 * The function checks if the user is authenticated by examining the Authorization header for a valid
 * Firebase Auth ID token and verifies access to the specified device. If the user has access, it retrieves
 * the device document from the "devices" collection and returns the salt level and battery level.
 *
 * @throws {HttpsError} - Throws an error if the user is unauthenticated, the device ID is not provided,
 * the user or device is not found, or the user does not have access to the specified device.
 */
async function getDeviceLevelsHttp(req, res) {
    // Check for the Authorization header and extract the Firebase Auth ID token
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        res.status(401).send('Unauthorized');
        return;
    }
    const idToken = req.headers.authorization.split('Bearer ')[1];

    // Parse the request body to get the device ID
    const deviceId = req.body.deviceId;
    if (!deviceId) {
        res.status(400).send('Device ID must be provided');
        return;
    }

    try {
        // Verify the ID token and get the UID
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userUid = decodedToken.uid;

        // Get the user document from Firestore
        const userDocRef = admin.firestore().collection("users").doc(userUid);
        const userDocSnapshot = await userDocRef.get();
        if (!userDocSnapshot.exists) {
            res.status(404).send('User not found');
            return;
        }

        // Check if the user has access to the specified device
        const userDevices = userDocSnapshot.get("devices");
        if (!userDevices.includes(deviceId)) {
            res.status(403).send('User does not have access to the specified device');
            return;
        }

        // Get the device document from Firestore
        const deviceDocRef = admin.firestore().collection("devices").doc(deviceId);
        const deviceDocSnapshot = await deviceDocRef.get();
        if (!deviceDocSnapshot.exists) {
            res.status(404).send('Device not found');
            return;
        }

        // Get the battery level and salt level from the device document
        const batteryLevel = deviceDocSnapshot.get("battery_level");
        const saltLevel = deviceDocSnapshot.get("salt_level");

        // Return the battery level and salt level as JSON
        res.status(200).json({
            battery_level: batteryLevel,
            salt_level: saltLevel
        });
    } catch (error) {
        console.error("Error getting device levels:", error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { getDeviceLevelsHttp };