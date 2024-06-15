const admin = require('./adminInit.cjs');

const { onRequest } = require("firebase-functions/v2/https");
const { onCall } = require("firebase-functions/v2/https");
const functions = require('firebase-functions');

// Import the `addLead` function.
require('./src/addLead.cjs');
const { addLead } = require('./src/addLead.cjs');

// Call the `addLead` function as a Firebase Callable Function.
exports.addLead = onCall(async (data) => {
    addLead(data);
});

// Import the `createUser` function.
const { createUser } = require('./src/createUser.cjs');

/// A function that triggers when a new user is created.
exports.createUserDocument = functions.auth.user().onCreate((user) => {
    createUser(user);
});

// Import the `getUserDevicesHttp` function.
const { getUserDevicesHttp } = require('./src/getUserDevicesHttp.cjs');

// Call the `getUserDevicesHttp` function as an HTTP request.
exports.getUserDevicesHttp = functions.https.onRequest(async (req, res) => {
    getUserDevicesHttp(req, res);
});

// Import the `updateDeviceLevels` function.
const { updateDeviceLevels } = require('./src/updateDeviceLevels.cjs');

// Call the `updateDeviceLevels` function as an HTTP request.
exports.updateDeviceLevels = onRequest(async (req, res) => {
    updateDeviceLevels(req, res);
});

// Import the `getDeviceLevelsHttp` function.
const { getDeviceLevelsHttp } = require('./src/getDeviceLevelsHttp.cjs');

// Call the `getDeviceLevelsHttp` as an HTTP request.
exports.getDeviceLevelsHttp = functions.https.onRequest(async (req, res) => {
    getDeviceLevelsHttp(req, res);
});

// Import the `addDeviceToUser` function.
const { addDeviceToUser } = require('./src/addDeviceToUser.cjs');

// Call the `addDeviceToUser` function as an HTTP request.
exports.addDeviceToUser = functions.https.onRequest(async (req, res) => {
    addDeviceToUser(req, res);
});