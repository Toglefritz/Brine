
const admin = require('../adminInit.js');
const functions = require('firebase-functions');

/**
 * `addLead` is a Firebase Cloud Function designed to add a new lead document
 * to the 'leads' collection in Firestore. This function is callable from a client application.
 * 
 * The function now checks for an existing lead with the same email before attempting to create
 * a new lead. If a lead with the given email already exists, the function still completes successfully,
 * but returns a message indicating that a lead with the given email already exists.
 * 
 * @param {Object} data - The data argument is expected to be an object with the following properties:
 * @param {string} data.email - The email address of the lead.
 * @param {string} data.name - The name of the lead.
 * @param {number} data.timestamp - The timestamp when the lead was created.
 * 
 * These parameters are validated for type consistency before attempting to add the lead to the Firestore.
 * If any of the inputs are of the incorrect type, the function throws a Firebase 'invalid-argument' HttpsError.
 *
 * @param {Object} context - The function context which includes information about the user who invoked the function.
 *
 * The function then attempts to add a new document to the 'leads' collection with the passed data if no existing
 * lead with the same email is found. If the operation is successful, the function returns an object with a 'result' 
 * property that contains a message indicating the ID of the newly added document or a message indicating that a lead 
 * with the given email already exists. If an error occurs when trying to add the document, the function logs the error 
 * and throws a Firebase 'internal' HttpsError.
 */
async function addLead(data) {
    // Validate input
    if (!(typeof data.data.email === 'string') ||
        !(typeof data.data.name === 'string') ||
        !(typeof data.data.timestamp === 'number')) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'The function must be called with valid arguments. Expected "email" as string, "name" as string, and "timestamp" as number.'
        );
    }

    var email = data.data.email;
    var name = data.data.name;
    var timestamp = data.data.timestamp;

    const newLead = {
        email: email,
        name: name,
        timestamp: timestamp,
    };

    try {
        // Check if a lead with the given email already exists.
        const leadsRef = admin.firestore().collection('leads');
        const snapshot = await leadsRef.where('email', '==', email).get();

        if (!snapshot.empty) {
            // A lead with the given email already exists.
            console.log(`Lead with email: ${email} already exists.`);
            return { result: `Lead with email: ${email} already exists.` };
        } else {
            // Add the new lead.
            const docRef = await leadsRef.add(newLead);
            return { result: `Lead with ID: ${docRef.id} added.` };
        }
    } catch (error) {
        console.log('Error adding document: ', error);

        let message = 'Failed to add the lead';
        if (error.code === 'permission-denied') {
            message = 'Insufficient permissions to add the lead';
        } else if (error.code === 'unavailable') {
            message = 'The service is currently unavailable';
        } else if (error.code === 'deadline-exceeded') {
            message = 'The request timed out';
        }

        throw new functions.https.HttpsError(message, 'An internal error occurred', { detailedMessage: message });
    }
}

// Export the function to make it available for import
module.exports = { addLead };