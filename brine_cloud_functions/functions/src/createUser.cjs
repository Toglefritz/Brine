const admin = require('../config/adminInit.cjs');

/**
 * Calls the 'createUser' Firebase Cloud Function to create a new user  document in Firestore.
 * 
 * This function is automatically triggered by the Firebase Auth system when a user creates a new account. It creates
 * a document in the "users" collection in Firebase Firestore with the user's UID as the document ID. The document 
 * contains the user's UID, an empty array for devices, and an empty array for FCM tokens. These arrays are initially
 * empty since this function is only responsible for creating the user document right after the user's account is
 * created. Other functions will be responsible for updating these arrays as the user interacts with the app.
 */
async function createUser(user) {
    // Get the user's UID from the user object.
    const uid = user.uid;

    try {
        // Create a new document in the "users" collection with the user's UID.
        await admin.firestore().collection('users').doc(uid).set({
            uid: uid,
            devices: [],
            fcm_tokens: [],
        });

        return { result: `User with UID ${uid} added.` };
    } catch (error) {
        // Handle any errors that occurred while adding the user to Firestore.
        console.error('Error adding user to Firestore: ', error);
        throw new functions.https.HttpsError('unknown', 'Failed to create user.');
    }
};

// Export the function to make it available for import
module.exports = { createUser };