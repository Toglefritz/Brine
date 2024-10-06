const admin = require('../config/adminInit.cjs');

/**
 * @brief Retrieves information about a device by its device ID.
 * 
 * This function is called by the mobile app to retrieve information about a Brine device. The function
 * retrieves the device document from Firestore and returns the levels as a JSON response.
 * 
 * Each device document in Firestore has the following structure:
 * 
  * {
 *     "device_id": "vast_teal_elephant",
 *     "name": "7b67",
 *     "battery_level": 0.7,
 *     "salt_level": 0.4,
 *     "appliance_height": 1000,
 *     "last_updated": "2021-09-01T12:00:00Z"
 * }
 * 
 * The function is provided with the device ID as a query parameter. It retreives the device document from Firestore
 * and returns it as a JSON response after verifying that the user has access to the device.
 */
async function getDevice(req, res) {
    // Get the user ID from the request, which was attached by the authenticate middleware.
    const userUid = req.user.uid;

    // Parse the request query to get the device ID
    const deviceId = req.query.deviceId;
    if (!deviceId) {
        res.status(400).send('Device ID must be provided');
        return;
    }

    try {
        // Get the user document from Firestore.
        const userDocRef = admin.firestore().collection("users").doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        // Check if the user document exists.
        if (!userDocSnapshot.exists) {
            res.status(404).send('User not found');

            return;
        }

        // Get the device document from Firestore
        const deviceDocRef = admin.firestore().collection("devices").doc(deviceId);
        const deviceDocSnapshot = await deviceDocRef.get();

        // Check if the device document exists.
        if (!deviceDocSnapshot.exists) {
            res.status(404).send('Device not found');

            return;
        }

        // Check if the user has access to the specified device by checking if the device ID is in the user's list of 
        // devices.
        const userDevices = userDocSnapshot.get("devices");
        if (!userDevices.includes(deviceId)) {
            res.status(403).send('User does not have access to the specified device');

            return;
        }

        // Return the device document.
        const deviceData = deviceDocSnapshot.data();
        res.status(200).json(deviceData);
    } catch (error) {
        // If an error occurs, log it and return an internal server error.
        console.error("Error getting device:", error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { getDevice: getDevice };