const admin = require('../config/adminInit.cjs');

/**
 * Adds an FCM token to the user's document in Firestore.
 * 
 * This function is called when a user registers a new device or updates their push notification token.
 * It ensures that the token is stored in the `fcm_tokens` array in the user's Firestore document.
 *
 * @param {Object} req - The HTTP request object.
 * @param {Object} res - The HTTP response object.
 */
async function addFcmToken(req, res) {
    try {
        // Get the user ID from the authenticated request
        const userUid = req.user.uid;

        // Get the FCM token from the request body
        const { fcmToken } = req.body;

        if (!fcmToken) {
            console.error('FCM token is required.');
            res.status(400).send('FCM token is required.');
            return;
        }

        // Reference to the user's document in Firestore
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        if (!userDocSnapshot.exists) {
            console.error(`User document not found for UID: ${userUid}`);
            res.status(404).send('User not found.');
            return;
        }

        // Get existing FCM tokens (default to empty array if not present)
        let fcmTokens = userDocSnapshot.get('fcm_tokens') || [];

        // Check if the token is already stored
        if (fcmTokens.includes(fcmToken)) {
            console.log(`FCM token already exists for user ${userUid}. No update needed.`);
            res.status(200).send('FCM token already exists.');
            return;
        }

        // Add the new token and update Firestore
        fcmTokens.push(fcmToken);
        await userDocRef.update({ fcm_tokens: fcmTokens });

        console.log(`FCM token added for user ${userUid}`);
        res.status(200).send('FCM token added successfully.');
    } catch (error) {
        console.error('Error adding FCM token:', error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function
module.exports = { addFcmToken };