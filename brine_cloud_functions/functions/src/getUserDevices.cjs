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
 * returns a JSON object with a list of device IDs. For example,
 * 
 * [
 *    "vast_teal_elephant"
 * ]
 * 
 * The app then retrieves the details of each device before displaying them to the user.
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
        res.status(200).send({ devices: devices });
    } catch (error) {
        console.error('Error verifying Firebase ID token:', error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function to make it available for import
module.exports = { getUserDevices: getUserDevices };