const admin = require('../config/adminInit.cjs');

/**
 * Calls the 'createUser' Firebase Cloud Function to create a new user  document in Firestore.
 * 
 * This function requires the client to be authenticated. If the client is  not authenticated, it will automatically
 * authenticate anonymously.
 * 
 * The authenticated user's UID is used as both the document ID and the uid  field value in the document in Firestore.
 * An empty devices array is also added to the document.
 */
async function createUser(user) {
    // Get the user's UID from the user object.
    const uid = user.uid;

    try {
        // Create a new document in the "users" collection with the user's UID.
        await admin.firestore().collection('users').doc(uid).set({
            uid: uid,
            devices: [],
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