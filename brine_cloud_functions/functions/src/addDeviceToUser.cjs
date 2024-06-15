const admin = require('../adminInit.cjs');

/**
 * Adds a device to the user's list of devices and creates a record for the device itself.
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
 * When the mobile app launches, it retrieves this list of devices via the getUserDevicesHttp call.
 * 
 * Information about the devices themselves are stored in the "devices" collection. The device ID of each device
 * ties these two collections together. For example,
 * 
 * {
 *     "deviceId": "vast_teal_elephant",
 *     "name": "7b67",
 *     "battery_level": 0.7,
 *     "salt_level": 0.4
 * }
 * 
 * After retrieving a list of devices on the user's account, the app also retrieves the details of each device before
 * displaying them to the user.
 * 
 * This function is called during the provisioning process when a new device is added to the user's account. It is 
 * reponsible for creating/adding the device to the user's list of devices and creating a record for the device itself.
 * 
 * The function is provided with the device ID and device name in the request body. It first verifies the Firebase ID
 * token in the Authorization header to get the UID of the user. It then retrieves the user document from Firestore and
 * adds the device to the list of devices. Finally, checks if the device already exists in the "devices" collection and
 * creates a new record if it doesn't.
 */
async function addDeviceToUser(req, res) {
    // Check for the Authorization header
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        console.error('Authorization header not found');
        res.status(401).send('Unauthorized');

        return;
    }

    // Extract the Firebase Auth ID token, verify it, and get the UID
    var decodedToken = null;
    try {
        // Get the ID token from the Authorization header
        const idToken = req.headers.authorization.split('Bearer ')[1];

        // Verify the ID token and get the UID
        decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (error) {
        console.error('Error verifying Firebase ID token:', error);
        res.status(401).send('Unauthorized');
    }

    // Extract the device ID and device name from the request
    const deviceId = req.body.deviceId;
    const deviceName = req.body.deviceName;
    if (!deviceId) {
        console.error('Device ID is required');
        res.status(400).send('Device ID is required');
    } else if (!deviceName) {
        console.error('Device name is required');
        res.status(400).send('Device name is required');
    }

    // Add the device to the user's list of devices
    try {
        // Get the user UID from the token
        const userUid = decodedToken.uid;

        // Get the user document from Firestore
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        // Check if the user document exists
        if (!userDocSnapshot.exists) {
            console.error('User not found');
            res.status(404).send('User not found');

            return;
        }

        // Add the device to the user's list of devices
        const devices = userDocSnapshot.get('devices') || [];
        devices.push(deviceId);
        await userDocRef.update({ devices: devices });
    } catch (error) {
        console.error('Error adding device to user:', error);
        res.status(500).send('Internal Server Error');
    }

    // Check if the device already exists in the "devices" collection
    try {
        // Get the device document from Firestore
        const deviceDocRef = admin.firestore().collection('devices').doc(deviceId);
        const deviceDocSnapshot = await deviceDocRef.get();

        // If the device does not exist, create a new record for it
        if (!deviceDocSnapshot.exists) {
            await deviceDocRef.set({
                deviceId: deviceId,
                name: deviceName,
                battery_level: -1,  // -1 indicates unknown battery level
                salt_level: -1    // -1 indicates unknown salt level
            });

            // Return a success message
            console.log('Device added successfully and record created in devices collection');
            res.status(200).send('Device added successfully');
        }
        // If the device already exists, return a success message
        else {
            console.log('Device already exists');
            res.status(200).send('Device added successfully with existing record in devices collection');
        }
    } catch (error) {
        console.error('Error adding device to devices collection:', error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { addDeviceToUser };