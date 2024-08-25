/**
 * @file authMiddleware.cjs
 * @brief Middleware function for authenticating Firebase ID tokens.
 *
 * The `authMiddleware.cjs` file contains a middleware function that verifies
 * the Firebase ID token sent in the request headers. This middleware is used
 * to protect Firebase Functions endpoints, ensuring that only authenticated
 * users can access them.
 * 
 * For endpoints that require a value for the `userId` parameter, this 
 * middleware also checks that the `userId` in the request matches the `uid`
 * in the decoded token. This check helps prevent users from accessing data
 * that does not belong to them, even if they posess a valid ID token.
 * 
 * If the token is successfully verified, the user ID from the token is attached
 * to the request object as `req.user`. If the token is missing or invalid, an
 * unauthorized response is sent.
 * 
 * If the function is running in the Firebase Emulator Suite, the authentication
 * step is skipped, and the user ID is expected to be passed in a header for
 * testing purposes.
 * 
 * @details
 * This file performs the following tasks:
 * - Imports the Firebase Admin SDK authentication module.
 * - Defines an `authenticate` function that:
 *   - Extracts the ID token from the request headers.
 *   - Verifies the ID token using the Firebase Admin SDK.
 *   - Attaches the user ID from the token to the request object if verification 
 *     is successful.
 *   - Sends an unauthorized response if the token is missing or invalid.
 * - Exports the `authenticate` function for use in other parts of the codebase.
 *
 * The `authenticate` function is essential for securing Firebase Functions by
 * verifying the identity of the users making requests. It ensures that only
 * authenticated users can access protected endpoints.
 */

// Import the Firebase Admin SDK.
const { getAuth } = require('firebase-admin/auth');

/**
 * @function authenticate
 * @brief Middleware function to authenticate Firebase ID tokens.
 *
 * This function extracts the ID token from the request headers, verifies it
 * using the Firebase Admin SDK, and attaches the decoded token to the request
 * object. If the token is missing or invalid, an unauthorized response is sent.
 *
 * @param {Object} req - The HTTP request object.
 * @param {Object} res - The HTTP response object.
 * @param {Function} next - The next middleware function in the stack.
 *
 * @return {void}
 */
const authenticate = async (req, res, next) => {
  // If this function is running in the Firebase Emulator Suite, skip
  // authentication if the Authorization header is missing. This allows the
  // user ID to be passed in a header for testing purposes.
  if (process.env.FUNCTIONS_EMULATOR === 'true' && !req.headers.authorization) {
    // When running in the emulator, the user ID is expected to be passed
    // in a header for testing purposes.
    if (req.headers['x-user-id']) {
      // Attach the user ID to the request object.
      req.user = { uid: req.headers['x-user-id'] };
    }

    return next();
  }

  // Extract the ID token from the Authorization header
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  // If the ID token is missing, send an unauthorized response
  if (!idToken) {
    return res.status(401).json({ message: 'Unauthorized (no ID token)' });
  }

  try {
    // Verify the ID token using the Firebase Admin SDK
    const decodedToken = await getAuth().verifyIdToken(idToken);

    // Get the user ID from the decoded token.
    const uid = decodedToken.uid;

    // Check if the userId is provided in the request and matches the one in the 
    // token. This check is not used for endpoints that do not require a userId.
    const userId = req.body.userId || req.query.userId;
    if (userId && userId !== decodedToken.uid) {
      // If the userId is provided and does not match the one in the token,
      return res.status(403).json({ message: 'Forbidden (userId mismatch)' });
    }

    // Attach the user ID to the request object.
    console.log('Authenticated user:', uid);
    req.user = { uid: uid };

    next();
  } catch (error) {
    // If the token verification fails, send an unauthorized response.
    return res.status(401).json({ message: 'Unauthorized (token verification failed)' });
  }
};

// Export the authenticate function
module.exports = authenticate;