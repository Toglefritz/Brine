const admin = require('../config/adminInit.cjs');

/**
 * @brief Adds a device to the user's list of devices and creates a record for the device itself.
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
 *     "device_id": "vast_teal_elephant",
 *     "name": "7b67",
 *     "battery_level": 0.7,
 *     "salt_distance": 800,
 *     "appliance_height": 1000,
 *     "last_updated": "2021-09-01T12:00:00Z"
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
 *
 *
 * Example usage:
 * 
 * POST /addDeviceToUser
 * {
 *  "deviceId": "vast_teal_elephant",
 *  "deviceName": "7b67"
 * }
 */
async function addDeviceToUser(req, res) {
    // Get the user ID from the request, which was attached by the authenticate 
    // middleware.
    const userUid = req.user.uid;

    // Extract the device ID and device name from the request
    const deviceId = req.body.deviceId;
    const deviceName = req.body.deviceName;

    console.log('Adding device to user', userUid, ':', deviceId, ';', deviceName);

    // Check if the device ID and device name are provided.
    if (!deviceId) {
        console.error('Device ID is required');
        res.status(400).send('Device ID is required');

        return;
    } else if (!deviceName) {
        console.error('Device name is required');
        res.status(400).send('Device name is required');

        return;
    }

    // Check if userUid is a valid non-empty string
    if (!userUid || typeof userUid !== 'string') {
        console.error('The user UID is missing or invalid.');
        res.status(400).send('The user UID is missing or invalid.');

        return;
    }

    // Step 1: Add the device to the user's list of devices.
    try {
        console.log('Adding device to user:', deviceId);

        // Get the user document from Firestore
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        // Check if the user document exists
        if (!userDocSnapshot.exists) {
            console.error('User not found');
            res.status(404).send('User not found');

            return;
        }

        // Get the existing list of devices from the user document.
        const devices = userDocSnapshot.get('devices') || [];

        // Check if the device is already in the user's list of devices. If it is, return a success message.
        if (devices.includes(deviceId)) {
            console.log('Device already added to user');

            // Simply continue to the next step if the device is already in the list.
        }
        // Othereise, add the device to the list of devices.
        else {
            devices.push(deviceId);
            await userDocRef.update({ devices: devices });
            console.log('Device added to user');
        }
    } catch (error) {
        // If an error occurs, log it and return an internal server error.
        console.error('Error adding device to user:', error);

        res.status(500).send('Internal Server Error');

        return;
    }


    // Step 2: Create a record for the device in the "devices" collection.
    try {
        // Get the device document from Firestore
        const deviceDocRef = admin.firestore().collection('devices').doc(deviceId);
        const deviceDocSnapshot = await deviceDocRef.get();

        // If the device does not exist, create a new record for it. The battery level, salt level, and appliance
        // height are all set to -1 initially to indicate that they are unknown.
        if (!deviceDocSnapshot.exists) {
            await deviceDocRef.set({
                device_id: deviceId,
                name: deviceName,
                battery_level: -1,  // -1 indicates unknown battery level
                salt_distance: -1,    // -1 indicates unknown salt level
                appliance_height: -1,  // -1 indicates unknown appliance height
                last_updated: new Date().toISOString(),
            });

            // Return a success message
            console.log('Device added successfully and record created in devices collection');
            res.status(200).send('Device added successfully');

            return;
        }
        // If the device already exists, return a success message, allowing the function to complete gracefully.
        else {
            console.log('Device already exists');
            res.status(200).send('Device added successfully with existing record in devices collection');

            return;
        }
    } catch (error) {
        // If an error occurs, log it and return an internal server error.
        console.error('Error adding device to devices collection:', error);
        res.status(500).send('Internal Server Error');

        return;
    }
}

// Export the function to make it available for import
module.exports = { addDeviceToUser };