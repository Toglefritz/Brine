const admin = require('../config/adminInit.cjs');

/**
 * @brief Updates the appliance height for a water softener equipped with a Brine monitor.
 * 
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
    // Get the user ID from the request, which was attached by the authenticate middleware.
    const userUid = req.user.uid;

    // Parse the request body to get the device ID
    const deviceId = req.body.deviceId;
    if (!deviceId) {
        res.status(400).send('Device ID must be provided');
        return;
    }

    // Extract the appliance height from the request body
    const applianceHeight = req.body.applianceHeight;

    // Check if the appliance height is provided
    if (!applianceHeight) {
        res.status(400).send('Appliance height must be provided');
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

        // Check if the user has access to the specified device by checking if the device ID is in the user's list of 
        // devices.
        const userDevices = userDocSnapshot.get("devices");
        if (!userDevices.includes(deviceId)) {
            res.status(403).send('User does not have access to the specified device');

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

        // Update the appliance height in the device document
        try {
            // Convert the appliance height to a number
            const applianceHeight = parseInt(req.body.appliance_height);

            // Update the appliance height in the device document
            await deviceDocRef.update({ appliance_height: applianceHeight });

            // Return a success message
            res.status(200).json('Appliance height updated successfully');
        }
        catch (error) {
            // If an error occurs, log it and return an internal server error.
            console.error("Error updating appliance height:", error);
            res.status(500).send('Internal Server Errorr');
        }
    } catch (error) {
        // If an error occurs, log it and return an internal server error.
        console.error("Error getting device levels:", error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { updateApplianceHeight };