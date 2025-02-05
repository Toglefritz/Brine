const admin = require('../config/adminInit.cjs');

/**
 * @brief Retrieves the list of devices associated with the user's account.
 * 
 * In the Brine Firestore database, each user has a document in the "users" collection with a list of devices that 
 * are associated to their account. For example,
 * 
 *  {
 *      "uid": "abc123",
 *      "devices": [
 *         "vast_teal_elephant",
 *      ]
 *  }
 * 
 * When the mobile app launches, it retrieves this list of devices via the `getUserDevicesHttp` call. This call
 * returns a JSON object with an inner list of objects representing the Brine devices on the user' saccount. For 
 * example,
 * 
 * {
 *   "devices" : [ {
 *     "appliance_height" : 1067,
 *     "last_updated" : "2025-01-10T22:18:39.379Z",
 *     "device_id" : "vast_teal_elephant",
 *     "battery_level" : 99.2421875,
 *     "psk_created_at" : "2025-01-15T03:12:03.598Z",
 *     "name" : "b76b",
 *     "psk" : "0cf06f8876cd5490c318f50be6b8b0d79d47ff7b7ba7cf3b56d8a779c6a693d8",
 *     "salt_distance" : 700,
 *     "psk_valid" : true
 *   } ]
 * }
 * 
 */
async function getUserDevices(req, res) {
    // Get the user ID from the request, which was attached by the authenticate 
    // middleware.
    const userUid = req.user.uid;

    try {
        // Get the user document from Firestore
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        // Check if the user document exists.
        if (!userDocSnapshot.exists) {
            // If the user document does not exist, return a 404 error.
            res.status(404).send('User not found');
            return;
        }

        // Get the list of devices from the user document
        const devices = userDocSnapshot.get('devices');

        // For each device, get the device document from Firestore
        const deviceDocs = [];
        for (const device of devices) {
            const deviceDocRef = admin.firestore().collection('devices').doc(device);
            const deviceDocSnapshot = await deviceDocRef.get();
            if (deviceDocSnapshot.exists) {
                deviceDocs.push(deviceDocSnapshot.data());
            }
        }

        // Return the list of devices as a JSON response
        res.status(200).send({ devices: deviceDocs });
    } catch (error) {
        console.error('Error verifying Firebase ID token:', error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { getUserDevices: getUserDevices };