const admin = require('./adminInit.js');

const { onRequest } = require("firebase-functions/v2/https");
const { onCall } = require("firebase-functions/v2/https");
const functions = require('firebase-functions');

// Import the `addLead` function.
require('./src/addLead.js');
const { addLead } = require('./src/addLead.js');

// Call the `addLead` function as a Firebase Callable Function.
exports.addLead = onCall(async (data) => {
    addLead(data);
});

// Import the `createUser` function.
const { createUser } = require('./src/createUser.js');

/// A function that triggers when a new user is created.
exports.createUserDocument = functions.auth.user().onCreate((user) => {
    createUser(user);
});

// Import the `getUserDevicesHttp` function.
const { getUserDevicesHttp } = require('./src/getUserDevicesHttp.js');

// Call the `getUserDevicesHttp` function as an HTTP request.
exports.getUserDevicesHttp = functions.https.onRequest(async (req, res) => {
    getUserDevicesHttp(req, res);
});

// Import the `updateDeviceLevels` function.
const { updateDeviceLevels } = require('./src/updateDeviceLevels.js');

// Call the `updateDeviceLevels` function as an HTTP request.
exports.updateDeviceLevels = onRequest(async (req, res) => {
    updateDeviceLevels(req, res);
});

// Import the `getDeviceLevelsHttp` function.
const { getDeviceLevelsHttp } = require('./src/getDeviceLevelsHttp.js');

// Call the `getDeviceLevelsHttp` as an HTTP request.
exports.getDeviceLevelsHttp = functions.https.onRequest(async (req, res) => {
    getDeviceLevelsHttp(req, res);
});