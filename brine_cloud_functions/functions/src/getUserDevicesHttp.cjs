const admin = require('../adminInit.cjs');

/**
 * This function is triggered by HTTP requests and checks if the user is authenticated 
 * by examining the Authorization header for a valid Firebase Auth ID token.
 * It retrieves the user document from the Firestore "users" collection.
 * If the user document exists, it extracts the list of devices and returns it in the response.
 * If the user is not authenticated or any other error occurs, it returns an appropriate error message.
 */
async function getUserDevicesHttp(req, res) {
    // Check for the Authorization header
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        res.status(401).send('Unauthorized');
        return;
    }

    // Extract the Firebase Auth ID token
    const idToken = req.headers.authorization.split('Bearer ')[1];

    try {
        // Verify the ID token and get the UID
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userUid = decodedToken.uid;

        // Get the user document from Firestore
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        if (!userDocSnapshot.exists) {
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
module.exports = { getUserDevicesHttp };