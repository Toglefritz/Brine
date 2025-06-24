/**
 * @file index.cjs
 * @brief Entry point for Firebase Cloud Functions.
 *
 * This file defines a series of HTTP endpoints for the Firebase Cloud Functions. Each endpoint calls a corresponding 
 * function that encapsulates the business logic for that endpoint. The separate function files are used to modularize 
 * and organize the code, making it easier to manage and maintain.
 *
 * @note The function files contain the actual implementation of the logic, 
 * keeping this file clean and focused on defining the endpoints.
 */

// Import the Firebase configuration and initialize the Firebase Admin SDK.
const admin = require('./config/adminInit.cjs');

// Import the Firebase Functions modules.
const { onRequest } = require("firebase-functions/v2/https");
const functions = require('firebase-functions');

// Allow all origins
const cors = require('cors')({ origin: true });

// Import the authentication middleware function that verifies the Firebase ID token.
const { authenticate, authenticateAnonymous } = require('./middleware/authMiddleware.cjs');

// Import the functions that handle the business logic for each endpoint. Each of these imported files contains one or
// more functions that implements the logic for the corresponding endpoint.

// Brine app functions
const { createUser } = require('./src/createUser.cjs');
const { getUserDevices } = require('./src/getUserDevices.cjs');
const { generatePSK } = require('./src/generatePSK.cjs');
const { updateDeviceLevels } = require('./src/updateDeviceLevels.cjs');
const { getDevice } = require('./src/getDevice.cjs');
const { addDeviceToUser } = require('./src/addDeviceToUser.cjs');
const { updateApplianceHeight } = require('./src/updateApplianceHeight.cjs');
const { removeDeviceFromUser } = require('./src/removeDeviceFromUser.cjs');
const { addFcmToken } = require('./src/addFcmToken.cjs');
const { deleteUser } = require('./src/deleteUser.cjs');

// Brine website functions
const { addLead } = require('./src/addLead.cjs');

/**
 * @brief HTTP endpoint to manually create a user document.
 * 
 * This function is called by the client after a user is created via Firebase Authentication. It expects the request
 * to be authenticated and include any necessary user info in the body.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.createUserDocument = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        const user = req.body;
        await createUser(req);

        res.status(200).send({ message: "User document created." });
    });
});

/**
 * @brief Endpoint used to add a device to the user's account.
 * 
 * This endpoint is called by the mobile app during the provisioning process to add a new device to the user's account. 
 * The function creates a new document in the "devices" collection and adds the device ID to the user's list of devices 
 * in the "users" collection.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.addDeviceToUser = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        addDeviceToUser(req, res);
    });
});

/**
 * @brief Endpoint used to get a list of Brine devices on the user's account.
 * 
 * This endpoint is called by the mobile app to retrieve a list of devices that are associated with the user's account. 
 * The function retrieves the list of devices from the Firestore database and returns it as a JSON response.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.getUserDevices = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        getUserDevices(req, res);
    });
});

/**
 * @brief Endpoint used to generate a pre-shared key (PSK) for a Brine device.
 * 
 * This endpoint is called by the mobile app during the provisioning process to generate a new pre-shared key (PSK) for 
 * a device. The PSK is stored in Firestore along with the device ID, a creation timestamp, and a validity flag. 
 * The function returns the PSK to the mobile app.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.generatePSK = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        generatePSK(req, res);
    });
});

/**
 * @brief Endpoint used to update the levels of a device.
 * 
 * This endpoint is called by the IoT device to update the salt and battery levels for the device in the Firestore 
 * database. The function receives the device ID and the new levels in the request body, updates the document in
 * the "devices" collection, and sends a success response.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.updateDeviceLevels = onRequest(async (req, res) => {
    updateDeviceLevels(req, res);
});

/**
 * @brief Endpoint used to get information about a Brine device.
 * 
 * This endpoint is called by the mobile app to retrieve information about the Brine device stored in the Firestore
 * database. The function retrieves the device document from Firestore and returns it as a JSON response after verifying
 * that the user has access to the device.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.getDevice = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        getDevice(req, res);
    });
});

/**
 * @brief Endpoint used to update the appliance height for a device.
 * 
 * This endpoint is called by the mobile app to update the appliance height for a water softener equipped with a Brine
 * monitor. The function receives the device ID and the new height in the request body, updates the document in the
 * "devices" collection, and sends a success response.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.updateApplianceHeight = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        updateApplianceHeight(req, res);
    });
});

/**
 * @brief Endpoint used to remove a Brine device from a user's account.
 * 
 * This endpoint is called by the mobile app when a user wants to remove a device from their account. The function 
 * removes the device ID from the user's list of devices and, if no other users are linked to the device, deletes
 * the device record from the "devices" collection.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.removeDeviceFromUser = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        removeDeviceFromUser(req, res);
    });
});

/**
 * @brief Endpoint used to provide an FCM token for push notifications.
 * 
 * This endpoint allows the mobile app to register an FCM token for a user. The function ensures that the token
 * is stored in Firestore under the `fcm_tokens` field in the user's document.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.addFcmToken = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        addFcmToken(req, res);
    });
});

/**
 * @brief Endpoint used to delete a user document from Firestore.
 * 
 * This endpoint allows authenticated users to delete their account data from Firestore.
 * The request must be authenticated, and the user's UID will be used to locate and delete their document.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.deleteUser = functions.https.onRequest(async (req, res) => {
    authenticate(req, res, async () => {
        deleteUser(req);
    });
});

/**
 * @brief Endpoint used to submit a new lead to the backend.
 * 
 * This endpoint is called by the mobile app to submit a lead. The function
 * sends an authenticated POST request to the Firebase Function endpoint.
 * 
 * @param {Object} req The HTTP request object.
 * @param {Object} res The HTTP response object.
 */
exports.addLead = functions.https.onRequest(async (req, res) => {
    cors(req, res, async () => {
        authenticateAnonymous(req, res, async () => {
            addLead(req, res);
        });
    });
});