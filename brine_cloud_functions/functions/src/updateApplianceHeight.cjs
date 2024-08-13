const admin = require('../adminInit.cjs');

/**
 * This function updates the appliance height for a water softener equipped with a Brine monitor in a Firestore 
 * document. The function expects a PATCH request containing the device ID of the Brine device for which the host
 * appliance height, and the new height of the appliance in millimeters. The request body should contain a JSON object 
 * with the following properties:
 *
 * - device_id (string): The unique identifier of the device.
 * - appliance_height (number): The height of the water softener (millimeters).
 * 
 * Because this function is expected to be used by the Brine app, it requires a Firebase Auth ID token in the 
 * Authorization header to authenticate the request.
 *
 * If the request is successful, the function returns a JSON object with a "result" property containing a success 
 * message. If an error occurs (e.g., due to invalid input data or authentication failure), the function returns an 
 * appropriate error message and HTTP status code.
 *
 * Example usage:
 *
 * POST /updateApplianceHeight HTTP/1.1
 * Host: REGION-YOUR_PROJECT_ID.cloudfunctions.net
 * Content-Type: application/json
 * Authorization: Bearer <Firebase ID token>
 *
 * {
 *   "device_id": "vast_teal_elephant",
 *   "appliance_height": 1000,
 * }
 */
async function updateApplianceHeight(req, res) {
    // Check if the request method is PATCH. A PATCH request is used for this function because it is updating a 
    // specific field of the resource.
    if (req.method !== 'PATCH') {
        res.status(400).send('Please send a PATCH request.');
        return;
    }

    // Verify the Firebase ID token in the Authorization header.
    try {
        await verifyIdToken(req);
    } catch (error) {
        res.status(401).send('Unauthorized');
        return;
    }

    // Get the parameters from the request
    const deviceId = req.body.device_id;
    const applianceHeight = req.body.appliance_height;

    // Note: The last updated timestamp is not updated with this request because that field is intended to express 
    // when the battery and salt levels were last updated. The appliance height is not expected to change frequently.

    // Validate the input data
    if (!deviceId || typeof applianceHeight === 'undefined') {
        res.status(400).send('Device ID and appliance height are required.');
        return;
    }

    // Update the Firestore document
    try {
        await admin.firestore().collection('devices').doc(deviceId).update({
            'appliance_height': applianceHeight,
        });
        res.status(200).send({ result: 'Appliance height updated successfully.' });
    } catch (error) {
        res.status(500).send({ error: 'An error occurred while updating the appliance height.' });
    }
}

// Export the function to make it available for import
module.exports = { updateApplianceHeight };