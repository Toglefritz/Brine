const {onRequest} = require("firebase-functions/v2/https");
const {onCall} = require("firebase-functions/v2/https");
const functions = require('firebase-functions');
const admin = require("firebase-admin");

// Initialize the Firebase project
admin.initializeApp();

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
exports.addLead = onCall(async (data, context) => {
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
});


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

/// A function that triggers when a new user is created.
exports.createUserFile = functions.auth.user().onCreate((user) => createUser(user));


/// Calls the 'createUser' Firebase Cloud Function to create a new user  document in Firestore.
///
/// This function requires the client to be authenticated. If the client is  not authenticated, it will automatically 
/// authenticate anonymously.
///
/// The authenticated user's UID is used as both the document ID and the uid  field value in the document in Firestore. 
/// An empty devices array is also added to the document.
///
/// If an error occurs during the process, the error code and message are printed.
///
/// Example usage:
/// ```dart
/// createUser();
/// ```
///
/// The function does not return a value.
async function createUser(user) {
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

/**
 * This function is triggered by HTTP requests and checks if the user is authenticated 
 * by examining the Authorization header for a valid Firebase Auth ID token.
 * It retrieves the user document from the Firestore "users" collection.
 * If the user document exists, it extracts the list of devices and returns it in the response.
 * If the user is not authenticated or any other error occurs, it returns an appropriate error message.
 */
exports.getUserDevicesHttp = functions.https.onRequest(async (req, res) => {
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
  });


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
exports.updateDeviceLevels = onRequest(async (req, res) => {
  // Check if the request method is POST
  if (req.method !== 'POST') {
      res.status(400).send('Please send a POST request.');
      return;
  }

  // Authenticate the user
  try {
      await verifyIdToken(req);
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
      await admin.firestore().collection('devices').doc(deviceId).update({
          'battery_level': batteryLevel,
          'salt_level': saltLevel,
      });
      res.status(200).send({ result: 'Device levels updated successfully.' });
  } catch (error) {
      res.status(500).send({ error: 'An error occurred while updating the device levels.' });
  }
});

/**
 * This function is triggered by HTTP requests. It retrieves the salt level and battery level for the
 * specified IoT device associated with the authenticated user. The Firestore structure consists of a
 * "users" collection that stores user documents with an array of associated device IDs, and a "devices"
 * collection that stores device documents with device ID, salt level, and battery level.
 *
 * The function checks if the user is authenticated by examining the Authorization header for a valid
 * Firebase Auth ID token and verifies access to the specified device. If the user has access, it retrieves
 * the device document from the "devices" collection and returns the salt level and battery level.
 *
 * @throws {HttpsError} - Throws an error if the user is unauthenticated, the device ID is not provided,
 * the user or device is not found, or the user does not have access to the specified device.
 */
exports.getDeviceLevelsHttp = functions.https.onRequest(async (req, res) => {
    // Check for the Authorization header and extract the Firebase Auth ID token
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
      res.status(401).send('Unauthorized');
      return;
    }
    const idToken = req.headers.authorization.split('Bearer ')[1];
  
    // Parse the request body to get the device ID
    const deviceId = req.body.deviceId;
    if (!deviceId) {
      res.status(400).send('Device ID must be provided');
      return;
    }
  
    try {
      // Verify the ID token and get the UID
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const userUid = decodedToken.uid;
  
      // Get the user document from Firestore
      const userDocRef = admin.firestore().collection("users").doc(userUid);
      const userDocSnapshot = await userDocRef.get();
      if (!userDocSnapshot.exists) {
        res.status(404).send('User not found');
        return;
      }
  
      // Check if the user has access to the specified device
      const userDevices = userDocSnapshot.get("devices");
      if (!userDevices.includes(deviceId)) {
        res.status(403).send('User does not have access to the specified device');
        return;
      }
  
      // Get the device document from Firestore
      const deviceDocRef = admin.firestore().collection("devices").doc(deviceId);
      const deviceDocSnapshot = await deviceDocRef.get();
      if (!deviceDocSnapshot.exists) {
        res.status(404).send('Device not found');
        return;
      }
  
      // Get the battery level and salt level from the device document
      const batteryLevel = deviceDocSnapshot.get("battery_level");
      const saltLevel = deviceDocSnapshot.get("salt_level");
  
      // Return the battery level and salt level as JSON
      res.status(200).json({
        battery_level: batteryLevel,
        salt_level: saltLevel
      });
    } catch (error) {
      console.error("Error getting device levels:", error);
      res.status(500).send('Internal Server Error');
    }
  });