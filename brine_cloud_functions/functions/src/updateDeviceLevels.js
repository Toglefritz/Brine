const admin = require('./../adminInit.js');

/**
 * This function updates the battery level and salt level of a device in a Firestore document.
 * The function is an HTTP-triggered Firebase Cloud Function that requires authentication via
 * Firebase Authentication. It expects a POST request containing a valid ID token in the
 * Authorization header, formatted as "Bearer <ID_TOKEN>". The request body should contain
 * a JSON object with the following properties:
 *
 * - device_id (string): The unique identifier of the device.
 * - battery_level (number): The updated battery level (between 0 and 1) of the device.
 * - salt_level (number): The updated salt level (between 0 and 1) of the device.
 *
 * If the request is successful, the function returns a JSON object with a "result" property
 * containing a success message. If an error occurs (e.g., due to invalid input data or
 * authentication failure), the function returns an appropriate error message and HTTP status code.
 *
 * Example usage:
 *
 * POST /updateDeviceLevels HTTP/1.1
 * Host: REGION-YOUR_PROJECT_ID.cloudfunctions.net
 * Content-Type: application/json
 * Authorization: Bearer <ID_TOKEN>
 *
 * {
 *   "device_id": "vast_teal_elephant",
 *   "battery_level": 0.7,
 *   "salt_level": 0.4
 * }
 */
async function updateDeviceLevels(req, res) {
    // Check if the request method is POST
    if (req.method !== 'POST') {
        res.status(400).send('Please send a POST request.');
        return;
    }

    // Authenticate the user
    try {
        await verifyIdToken(req);
    } catch (error) {
        res.status(401).send('Unauthorized');
        return;
    }

    // Get the parameters from the request
    const deviceId = req.body.device_id;
    const batteryLevel = req.body.battery_level;
    const saltLevel = req.body.salt_level;

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
        });
        res.status(200).send({ result: 'Device levels updated successfully.' });
    } catch (error) {
        res.status(500).send({ error: 'An error occurred while updating the device levels.' });
    }
}

// Export the function to make it available for import
module.exports = { updateDeviceLevels };