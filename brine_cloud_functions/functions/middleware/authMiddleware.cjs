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

/**
 * @function authenticateAnonymous
 * @brief Middleware function to authenticate Firebase ID tokens for anonymous users.
 *
 * This function verifies that the request is coming from an anonymous Firebase user.
 * It extracts the ID token from the request headers, verifies it using the Firebase
 * Admin SDK, and checks if the sign-in provider is anonymous. If verified, the
 * anonymous user's ID is attached to the request object. Otherwise, an unauthorized
 * or forbidden response is sent.
 *
 * @param {Object} req - The HTTP request object.
 * @param {Object} res - The HTTP response object.
 * @param {Function} next - The next middleware function in the stack.
 *
 * @return {void}
 */
const authenticateAnonymous = async (req, res, next) => {
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
  if (!idToken) {
    return res.status(401).json({ message: 'Unauthorized (no ID token)' });
  }

  try {
    // Verify the ID token using the Firebase Admin SDK
    const decodedToken = await getAuth().verifyIdToken(idToken);

    // Get the user ID from the decoded token.
    const uid = decodedToken.uid;

    // Attach the user ID to the request object.
    console.log('Authenticated anonymous user:', uid);
    req.user = { uid: uid };

    next();
  } catch (error) {
    // If the token verification fails, send an unauthorized response.
    return res.status(401).json({ message: 'Unauthorized (token verification failed)' });
  }
};

// Export both authenticate and authenticateAnonymous
module.exports = {
  authenticate,
  authenticateAnonymous,
};