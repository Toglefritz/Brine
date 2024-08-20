const admin = require('../config/adminInit.cjs');

/**
 * @brief Retrieves the battery level and salt level of a device.
 * 
 * This function is called by the mobile app to retrieve the battery level and salt level of a device. The function
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
 * The function is provided with the device ID as a query parameter. It first retrieves the user document from Firestore
 * to check if the user has access to the specified device. It then retrieves the device document from Firestore and
 * returns the battery level and salt level as a JSON response. For example,
 * 
 * {
 *   "battery_level": 0.7,
 *   "salt_level": 0.4
 * }
 */
async function getDeviceLevels(req, res) {
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

        // Get the battery level and salt level from the device document
        const batteryLevel = deviceDocSnapshot.get("battery_level");
        const saltLevel = deviceDocSnapshot.get("salt_level");

        // Return the battery level and salt level as JSON
        res.status(200).json({
            battery_level: batteryLevel,
            salt_level: saltLevel
        });
    } catch (error) {
        // If an error occurs, log it and return an internal server error.
        console.error("Error getting device levels:", error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { getDeviceLevels: getDeviceLevels };