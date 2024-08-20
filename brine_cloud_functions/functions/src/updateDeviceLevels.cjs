const admin = require('../config/adminInit.cjs');

/**
 * This function updates the battery level and salt level of a device in a Firestore document. The function expects a 
 * POST request containing the device ID of the Brine device for which the levels are being updated, and the salt and
 * battery level readings from that device. The request body should contain a JSON object with the following properties:
 *
 * - device_id (string): The unique identifier of the device.
 * - battery_level (number): The updated battery level (between 0 and 1) of the device.
 * - salt_level (number): The distance measured between the Brine deviee and the salt level (millimeters).
 *
 * If the request is successful, the function returns a JSON object with a "result" property containing a success 
 * message. If an error occurs (e.g., due to invalid input data or authentication failure), the function returns an 
 * appropriate error message and HTTP status code.
 *
 * Example usage:
 *
 * POST /updateDeviceLevels HTTP/1.1
 * Content-Type: application/json
 *
 * {
 *   "device_id": "vast_teal_elephant",
 *   "battery_level": 0.7,
 *   "salt_level": 0.4,
 * }
 */
async function updateDeviceLevels(req, res) {
    // TODO(Toglefritz): Perform an authentication check using the public key for the Brine device
    // to verify that the request is coming from the same device for which the levels are being updated.

    // Get the parameters from the request
    const deviceId = req.body.device_id;
    const batteryLevel = req.body.battery_level;
    const saltLevel = req.body.salt_level;

    // Get the current timestamp, which will be used as the last updated time.
    const lastUpdated = new Date().toISOString();

    // Validate the input data
    if (!deviceId || typeof batteryLevel === 'undefined' || typeof saltLevel === 'undefined') {
        res.status(400).send('Device ID, battery level, and salt level are required.');
        return;
    }

    // Update the Firestore document
    try {
        await admin.firestore().collection('devices').doc(deviceId).update({
            'battery_level': batteryLevel,
            'salt_level': saltLevel,
            'last_updated': lastUpdated,
        });
        res.status(200).send('Device levels updated successfully.');
    } catch (error) {
        res.status(500).send('An error occurred while updating the device levels.');
    }
}

// Export the function to make it available for import
module.exports = { updateDeviceLevels };