const admin = require('../config/adminInit.cjs');

/**
 * @brief Adds a new document to the "leads" collection in Firestore.
 * 
 * This function is called by the mobile app to provide information about a new Brine sales lead. The function
 * creates a new document in Firestore and returns the newly created document.
 * 
 * Each device document in Firestore has the following structure:
 * 
  * {
 *     "name": "Jeb",
 *     "email": jeb.kerman@brinemonitor.com,
 *     "timestamp": "2025-04-10T12:00:00Z"
 * }
 */
async function addLead(req, res) {
// TODO remove
console.log('addLead', req.body);

    // Get the user's name provided in the request body.
    const name = req.body.name;

    // Get the user's email provided in the request body.
    const email = req.body.email;

    // If either the name or email is missing, throw an error.
    if (!name || !email) {
        res.status(400).send('Name and email are required.');
        return;
    }

    // Create a timestamp for the document.
    const timestamp = new Date().toISOString();

// TODO
console.log('adding lead', name, email, timestamp);

    try {
        // Create a new document in the "leads" collection with the provided information.
        await admin.firestore().collection('leads').add({
            name: name,
            email: email,
            timestamp: timestamp,
        });


        res.status(200).send('Lead added successfully.');
    } catch (error) {
        // Handle any errors that occurred while adding the user to Firestore.
        console.error('Error adding user to Firestore: ', error);   
        res.status(500).send('Error adding lead to Firestore.');
    }
};

// Export the function to make it available for import
module.exports = { addLead };