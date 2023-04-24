const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize the Firebase project
admin.initializeApp();

// Create a reference to the Firestore database
const db = admin.firestore();

/**
 * This helper function verifies the ID token sent in the request header.
 * It expects the request object (req) to contain an "Authorization" header
 * with a valid ID token, formatted as "Bearer <ID_TOKEN>". The function
 * verifies the ID token using Firebase Authentication and returns the
 * decoded token if the verification is successful. If the ID token is
 * missing, invalid, or expired, an Error with a message "Unauthorized" is thrown.
 *
 * @param {Object} req - The request object containing the "Authorization" header.
 * @returns {Promise<Object>} - A promise that resolves to the decoded ID token.
 * @throws {Error} - An error with the message "Unauthorized" if the ID token is missing, invalid, or expired.
 *
 * Example usage:
 *
 * try {
 *   const decodedToken = await verifyIdToken(req);
 *   // Proceed with the request processing using the decoded token
 * } catch (error) {
 *   // Handle the unauthorized request
 * }
 */

async function verifyIdToken(req) {
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        throw new Error('Unauthorized');
    }

    const idToken = req.headers.authorization.split('Bearer ')[1];
    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        return decodedToken;
    } catch (error) {
        throw new Error('Unauthorized');
    }
}

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
const updateDeviceLevels = functions.https.onRequest(async (req, res) => {
    // Check if the request method is POST
    if (req.method !== 'POST') {
        res.status(400).send('Please send a POST request.');
        return;
    }

    // Authenticate the user
    let decodedToken;
    try {
        decodedToken = await verifyIdToken(req);
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
        await db.collection('devices').doc(deviceId).update({
            'battery_level': batteryLevel,
            'salt_level': saltLevel,
        });
        res.status(200).send({ result: 'Device levels updated successfully.' });
    } catch (error) {
        res.status(500).send({ error: 'An error occurred while updating the device levels.' });
    }
});

exports.updateDeviceLevels = updateDeviceLevels;