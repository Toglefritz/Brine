/**
 * @file firebaseConfig.cjs
 * @brief This file is responsible for initializing and configuring the Firebase
 * Admin SDK.
 *
 * The `firebaseConfig.cjs` file sets up the Firebase Admin SDK, which is
 * necessary for
 * performing server-side operations within Firebase Functions that require
 * access to Firebase services such as Firestore, Realtime Database,
 * Authentication, and more.
 *
 * @details
 * This file performs the following tasks:
 * - Imports the Firebase Admin SDK.
 * - Initializes the Firebase Admin SDK using the default application
 *   credentials.
 * - Exports the initialized Firebase Admin instance for use in other parts of
 *   the codebase.
 *
 * @note
 * Ensure that the Firebase project is properly set up and that the necessary credentials
 * are available in the environment where the functions are deployed. The Firebase Admin SDK
 * will automatically pick up the credentials from the environment.
 */

// Import the Firebase Admin SDK
const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Export the initialized Firebase Admin instance
module.exports = admin;