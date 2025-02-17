const admin = require('../config/adminInit.cjs');
const functions = require('firebase-functions');

/**
 * Deletes a user document from the "users" collection in Firestore.
 * 
 * This function is responsible for removing the user's document when an account deletion is requested.
 * It ensures that the user's associated data (such as device ownership and FCM tokens) is properly removed.
 * 
 * Other functions should handle any necessary cleanup of related data before or after the user document is deleted.
 * 
 * @param {Object} user - The user object containing the UID of the user to be deleted.
 * @returns {Object} - A result object confirming the deletion.
 */
async function deleteUser(req) {
    // Get the user ID from the authenticated request
    const uid = req.user.uid;

    try {
        // Reference to the user's document in Firestore
        const userDocRef = admin.firestore().collection('users').doc(uid);

        // Check if the user document exists before attempting to delete it
        const userDoc = await userDocRef.get();
        if (!userDoc.exists) {
            console.warn(`User with UID ${uid} does not exist.`);
            return { result: `User with UID ${uid} not found.` };
        }

        // Delete the user document
        await userDocRef.delete();

        console.log(`User document for UID ${uid} successfully deleted.`);
        return { result: `User with UID ${uid} deleted.` };
    } catch (error) {
        console.error('Error deleting user from Firestore:', error);
        throw new functions.https.HttpsError('unknown', 'Failed to delete user.');
    }
};

// Export the function to make it available for import
module.exports = { deleteUser };