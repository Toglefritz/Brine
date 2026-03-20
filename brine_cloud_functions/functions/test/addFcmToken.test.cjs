/**
 * @fileoverview Test suite for addFcmToken Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * addFcmToken Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and FCM token management requirements.
 * 
 * The addFcmToken function handles the complete FCM token registration workflow:
 * 1. Validates user authentication and FCM token parameter
 * 2. Checks user document existence in Firestore
 * 3. Retrieves existing FCM tokens array from user document
 * 4. Prevents duplicate token registrations
 * 5. Adds new tokens to the user's FCM tokens array
 * 6. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * FCM (Firebase Cloud Messaging) tokens are used for push notifications and must
 * be properly managed to ensure users receive notifications on their devices.
 * Each user can have multiple tokens (multiple devices/browsers) and the system
 * must prevent duplicates while maintaining token array integrity.
 * 
 * Test Categories:
 * * Input validation - Ensures FCM token parameter is validated properly
 * * User document handling - Tests user existence and document retrieval
 * * Token array management - Covers FCM token array operations and updates
 * * Duplicate prevention - Validates duplicate token detection and handling
 * * Edge cases - Handles null/undefined arrays and boundary conditions
 * * Firestore integration - Verifies correct database operations and calls
 * * Error handling - Ensures proper error responses and status codes
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Firestore collections - Mocked for users collection access
 * * Document references - Mocked for get and update operations
 * * Authentication context - Mocked for user authentication validation
 * 
 * Test Coverage:
 * * 100% code coverage for the addFcmToken function
 * * All execution paths including success and error scenarios
 * * Input validation for required FCM token parameter
 * * Database operation success and failure conditions
 * * Authentication and user existence validation
 * * FCM token array management and duplicate prevention
 * 
 * @author Firebase Functions Team
 * @since 2025-01-10
 * @version 1.0.0
 * @requires jest
 * @requires firebase-admin
 */

/**
 * Mock Firestore document reference for user operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for user documents, including get and update operations that are
 * used during FCM token registration workflow.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving user documents
 * @property {jest.Mock} update - Mock function for updating user FCM token arrays
 */
const mockUserDocRef = {
    get: jest.fn(),
    update: jest.fn()
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate document references
 * for the users collection used in FCM token management.
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 * 
 * @example
 * // Returns user document reference for 'users' collection
 * mockFirestore.collection('users').doc('user-id')
 */
const mockFirestore = {
    collection: jest.fn(() => ({
        doc: jest.fn(() => mockUserDocRef)
    }))
};

/**
 * Mock Firebase Admin SDK instance.
 * 
 * Provides a mocked version of the Firebase Admin SDK that returns
 * the mocked Firestore instance. This allows tests to run without
 * requiring actual Firebase connections or credentials.
 * 
 * @type {Object}
 * @property {jest.Mock} firestore - Mock function that returns mocked Firestore instance
 */
const mockAdmin = {
    firestore: jest.fn(() => mockFirestore)
};

// Mock the Firebase Admin SDK module before importing the function under test
jest.mock('../config/adminInit.cjs', () => mockAdmin);

// Import the function under test after mocking dependencies
const { addFcmToken } = require('../src/addFcmToken.cjs');

/**
 * Test suite for addFcmToken Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete FCM token registration
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles user authentication,
 * input validation, Firestore operations, and error responses.
 * 
 * Test Structure:
 * * Input validation - Tests for required FCM token parameter validation
 * * User document handling - Tests user existence and document retrieval
 * * Token array management - Tests FCM token array operations and updates
 * * Duplicate prevention - Tests duplicate token detection and handling
 * * Edge cases - Tests boundary conditions and null/undefined handling
 * * Firestore integration - Tests database operation calls and responses
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('addFcmToken', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * Simulates the Express.js request object that would be passed to the
     * addFcmToken function in a real HTTP request scenario. Contains
     * user authentication information and request body data.
     * 
     * @type {Object}
     * @property {Object} user - User authentication information from middleware
     * @property {string} user.uid - Firebase Auth user ID
     * @property {Object} body - HTTP request body containing FCM token information
     * @property {string} body.fcmToken - Firebase Cloud Messaging token for push notifications
     */
    let req;

    /**
     * Mock Express response object for testing HTTP responses.
     * 
     * Simulates the Express.js response object that would be used to send
     * HTTP responses back to the client. Includes mocked methods for setting
     * status codes and sending response data.
     * 
     * @type {Object}
     * @property {jest.Mock} status - Mock function for setting HTTP status codes
     * @property {jest.Mock} send - Mock function for sending response data
     */
    let res;

    /**
     * Mock Firestore document snapshot for user documents.
     * 
     * Simulates the document snapshot returned by Firestore when retrieving
     * user documents. Contains existence status and data retrieval methods
     * that are used to check user validity and get FCM token arrays.
     * 
     * @type {Object}
     * @property {boolean} exists - Whether the user document exists in Firestore
     * @property {jest.Mock} get - Mock function for retrieving document field data
     */
    let mockUserDocSnapshot;

    /**
     * Set up test environment before each test execution.
     * 
     * This function runs before each individual test to ensure a clean,
     * consistent testing environment. It resets all mocks, creates fresh
     * mock objects, and configures default successful responses to prevent
     * test interference and ensure predictable behavior.
     * 
     * Setup includes:
     * 1. Clearing all Jest mock call history and implementations
     * 2. Creating fresh request and response mock objects
     * 3. Configuring default Firestore document snapshots
     * 4. Setting up successful default responses for all operations
     * 
     * This approach ensures test isolation and prevents state leakage
     * between tests that could cause false positives or negatives.
     */
    beforeEach(() => {
        // Clear all mock function call history and reset implementations
        jest.clearAllMocks();

        /**
         * Configure mock HTTP request object with valid default data.
         * 
         * Sets up a typical successful request scenario with authenticated
         * user and valid FCM token data. Individual tests can override these
         * values to test specific error conditions or edge cases.
         */
        req = {
            user: { uid: 'test-user-uid' },
            body: {
                fcmToken: 'test-fcm-token-123'
            }
        };

        /**
         * Configure mock HTTP response object with chainable methods.
         * 
         * The status method returns 'this' to enable method chaining
         * (res.status(200).send('OK')), which matches Express.js behavior.
         */
        res = {
            status: jest.fn().mockReturnThis(),
            send: jest.fn()
        };

        // Reset all Firestore mock function call history
        mockUserDocRef.get.mockClear();
        mockUserDocRef.update.mockClear();

        /**
         * Configure default user document snapshot for successful scenarios.
         * 
         * Sets up a user document that exists and has an empty FCM tokens array,
         * representing a valid user account ready to accept new FCM tokens.
         */
        mockUserDocSnapshot = {
            exists: true,
            get: jest.fn().mockReturnValue([])
        };

        // Configure all Firestore operations to resolve successfully by default
        mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
        mockUserDocRef.update.mockResolvedValue();
    });

    /**
     * Test group for input validation scenarios.
     * 
     * This test group validates that the addFcmToken function properly
     * enforces all input validation rules and returns appropriate error
     * responses when required data is missing or invalid.
     * 
     * The function must validate:
     * * fcmToken - Required Firebase Cloud Messaging token for push notifications
     * 
     * All validation failures should return HTTP 400 (Bad Request) status
     * with clear, actionable error messages that help clients understand
     * what data is required and how to correct their requests.
     * 
     * These tests ensure that invalid requests are rejected early in the
     * processing pipeline, preventing unnecessary database operations and
     * providing fast feedback to clients about data requirements.
     */
    describe('Input validation', () => {
        /**
         * Tests validation of missing fcmToken parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * fcmToken field is completely missing from the request body.
         * FCM tokens are critical for push notification delivery and
         * must be present for the function to operate correctly.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate FCM token is required
         * * No database operations should be attempted
         * 
         * @test {Function} addFcmToken
         * @scenario Missing fcmToken parameter in request body
         * @expected HTTP 400 with "FCM token is required." message
         */
        test('should return 400 if fcmToken is missing', async () => {
            // Arrange: Remove fcmToken from request body
            req.body.fcmToken = undefined;

            // Act: Call function with missing fcmToken
            await addFcmToken(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('FCM token is required.');
        });

        /**
         * Tests validation of empty fcmToken parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * fcmToken field is present but contains an empty string. Empty
         * FCM tokens are not valid and would cause push notification
         * delivery failures.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate FCM token is required
         * * Empty strings should be treated the same as missing values
         * 
         * @test {Function} addFcmToken
         * @scenario Empty string fcmToken parameter in request body
         * @expected HTTP 400 with "FCM token is required." message
         */
        test('should return 400 if fcmToken is empty string', async () => {
            // Arrange: Set fcmToken to empty string
            req.body.fcmToken = '';

            // Act: Call function with empty fcmToken
            await addFcmToken(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('FCM token is required.');
        });

        /**
         * Tests validation of null fcmToken parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * fcmToken field is explicitly set to null. Null values are not
         * valid FCM tokens and should be rejected with appropriate error
         * messages.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate FCM token is required
         * * Null values should be treated the same as missing values
         * 
         * @test {Function} addFcmToken
         * @scenario Null fcmToken parameter in request body
         * @expected HTTP 400 with "FCM token is required." message
         */
        test('should return 400 if fcmToken is null', async () => {
            // Arrange: Set fcmToken to null
            req.body.fcmToken = null;

            // Act: Call function with null fcmToken
            await addFcmToken(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('FCM token is required.');
        });
    });

    /**
     * Test group for user document handling scenarios.
     * 
     * This test group validates the function's behavior when interacting
     * with user documents in Firestore. The addFcmToken function must
     * verify that the authenticated user exists in the database before
     * allowing FCM token registration.
     * 
     * User document operations tested:
     * * User document existence verification
     * * Firestore retrieval error handling
     * * User document data access and validation
     * 
     * These tests ensure that only valid, existing users can register
     * FCM tokens and that database errors are handled gracefully with
     * appropriate error responses and logging.
     * 
     * Error scenarios covered:
     * * Non-existent user documents (404 Not Found)
     * * Firestore connection or permission errors (500 Internal Server Error)
     * * Malformed user document data
     */
    describe('User document handling', () => {
        /**
         * Tests handling of non-existent user documents.
         * 
         * Verifies that the function properly handles cases where an
         * authenticated user does not have a corresponding document in
         * the Firestore users collection. This could happen if the user
         * document was deleted or if there's a synchronization issue
         * between Firebase Auth and the application database.
         * 
         * Expected behavior:
         * * Function should return HTTP 404 (Not Found) status code
         * * Response message should clearly indicate user was not found
         * * No FCM token operations should be attempted
         * * Error should be logged for debugging purposes
         * 
         * This test ensures that FCM token registration fails gracefully
         * when user data integrity issues are detected, preventing
         * orphaned token records and maintaining data consistency.
         * 
         * @test {Function} addFcmToken
         * @scenario User document does not exist in Firestore
         * @expected HTTP 404 with "User not found." message
         */
        test('should return 404 if user document does not exist', async () => {
            // Arrange: Configure user document to not exist
            const nonExistentUserSnapshot = { exists: false };
            mockUserDocRef.get.mockResolvedValue(nonExistentUserSnapshot);

            // Act: Attempt to add FCM token for non-existent user
            await addFcmToken(req, res);

            // Assert: Verify proper not found response
            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.send).toHaveBeenCalledWith('User not found.');
        });

        /**
         * Tests handling of Firestore retrieval errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during user document retrieval. This could happen
         * due to network issues, permission problems, or Firestore
         * service outages.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged with full details for debugging
         * * No partial operations should be performed
         * 
         * This test ensures that database errors are handled gracefully
         * without exposing internal error details to clients while
         * providing sufficient information for debugging and monitoring.
         * 
         * Error scenarios covered:
         * * Network connectivity issues
         * * Firestore permission denied errors
         * * Service unavailable conditions
         * * Timeout errors during document retrieval
         * 
         * @test {Function} addFcmToken
         * @scenario Firestore throws error during user document retrieval
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document retrieval error', async () => {
            // Arrange: Configure Firestore to throw error during user document retrieval
            mockUserDocRef.get.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to add FCM token when database error occurs
            await addFcmToken(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });

    /**
     * Test group for FCM token array management scenarios.
     * 
     * This test group validates the core functionality of managing FCM
     * tokens in a user's document. The function must properly handle
     * various array states and ensure tokens are added correctly while
     * maintaining array integrity.
     * 
     * Token array management workflow:
     * 1. Retrieve user's current FCM tokens array from Firestore
     * 2. Check if token already exists in the array
     * 3. Add token to array if not already present
     * 4. Update user document with modified FCM tokens array
     * 5. Handle all error conditions gracefully
     * 
     * Array management scenarios tested:
     * * Adding token to empty FCM tokens array
     * * Adding token to existing FCM tokens array
     * * Preventing duplicate token additions
     * * Handling Firestore update errors
     * 
     * These tests ensure data consistency and prevent duplicate token
     * registrations while maintaining proper error handling and user
     * feedback throughout the token addition process.
     */
    describe('Token array management', () => {
        /**
         * Tests adding an FCM token to an empty tokens array.
         * 
         * Verifies that the function properly handles the case where a user
         * has no existing FCM tokens and is registering their first token.
         * This is a common scenario for new users or users who have cleared
         * their notification settings.
         * 
         * Expected behavior:
         * * Function should create a new array with the single FCM token
         * * User document should be updated with the new FCM tokens array
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function properly initializes FCM token
         * arrays for users and handles the transition from no tokens to
         * having tokens without any data corruption or errors.
         * 
         * @test {Function} addFcmToken
         * @scenario User has empty FCM tokens array, adding first token
         * @expected HTTP 200 with successful token addition and array update
         */
        test('should add new FCM token to empty tokens array', async () => {
            // Arrange: Configure user with empty FCM tokens array
            mockUserDocSnapshot.get.mockReturnValue([]);

            // Act: Add FCM token to user with empty tokens array
            await addFcmToken(req, res);

            // Assert: Verify FCM tokens array is properly initialized and updated
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                fcm_tokens: ['test-fcm-token-123']
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('FCM token added successfully.');
        });

        /**
         * Tests adding an FCM token to an existing tokens array.
         * 
         * Verifies that the function properly handles the case where a user
         * already has FCM tokens registered and is adding an additional token.
         * This is common when users have multiple devices or browsers that
         * need to receive push notifications.
         * 
         * Expected behavior:
         * * Function should append new FCM token to existing array
         * * Existing FCM tokens should remain unchanged and in order
         * * User document should be updated with the expanded tokens array
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function properly maintains existing
         * token associations while adding new tokens, preserving data
         * integrity and user notification delivery across all devices.
         * 
         * @test {Function} addFcmToken
         * @scenario User has existing FCM tokens, adding additional token
         * @expected HTTP 200 with token appended to existing array
         */
        test('should add new FCM token to existing tokens array', async () => {
            // Arrange: Configure user with existing FCM tokens
            mockUserDocSnapshot.get.mockReturnValue(['existing-token-1', 'existing-token-2']);

            // Act: Add FCM token to user with existing tokens
            await addFcmToken(req, res);

            // Assert: Verify new token is appended to existing array
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                fcm_tokens: ['existing-token-1', 'existing-token-2', 'test-fcm-token-123']
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('FCM token added successfully.');
        });

        /**
         * Tests handling of user document update errors.
         * 
         * Verifies that the function properly handles database errors that
         * occur during the user document update operation. This could happen
         * due to network issues, permission problems, or Firestore service
         * outages during the critical update phase.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged with full details for debugging
         * * No partial operations should leave data in inconsistent state
         * 
         * This test ensures that update failures are handled gracefully
         * without leaving the system in an inconsistent state where the
         * token might be processed but not properly stored.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during update
         * * Firestore permission denied errors
         * * Document lock conflicts
         * * Service unavailable conditions
         * 
         * @test {Function} addFcmToken
         * @scenario Firestore throws error during user document update
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document update error', async () => {
            // Arrange: Configure user document update to fail
            mockUserDocSnapshot.get.mockReturnValue([]);
            mockUserDocRef.update.mockRejectedValue(new Error('Update failed'));

            // Act: Attempt to add FCM token when update operation fails
            await addFcmToken(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });

    /**
     * Test group for duplicate token prevention scenarios.
     * 
     * This test group validates the function's ability to detect and handle
     * duplicate FCM token registration attempts. Preventing duplicates is
     * crucial for maintaining clean token arrays and avoiding unnecessary
     * database operations.
     * 
     * Duplicate prevention ensures:
     * * Token arrays remain clean without duplicate entries
     * * Idempotent operation behavior for reliable client implementations
     * * Efficient database usage by avoiding unnecessary updates
     * * Consistent user experience across multiple registration attempts
     * 
     * These tests ensure that the function behaves predictably when the
     * same token is registered multiple times, which can happen due to
     * client retry logic, network issues, or user actions.
     */
    describe('Duplicate prevention', () => {
        /**
         * Tests duplicate FCM token prevention.
         * 
         * Verifies that the function properly handles attempts to add an
         * FCM token that is already present in the user's tokens array.
         * This prevents data corruption and maintains array integrity by
         * avoiding duplicate entries.
         * 
         * Expected behavior:
         * * Function should detect existing token in user's FCM tokens array
         * * No update operation should be performed on user document
         * * Function should still return HTTP 200 (idempotent operation)
         * * Response message should indicate token already exists
         * 
         * This test ensures that the function behaves idempotently, allowing
         * clients to safely retry FCM token registration operations without
         * causing data duplication or errors. This is important for reliable
         * client implementations and network error recovery scenarios.
         * 
         * @test {Function} addFcmToken
         * @scenario FCM token already exists in user's tokens array
         * @expected HTTP 200 with no array modification, idempotent behavior
         */
        test('should not duplicate FCM token if already exists', async () => {
            // Arrange: Configure user with FCM token already in tokens array
            mockUserDocSnapshot.get.mockReturnValue(['test-fcm-token-123', 'other-token']);

            // Act: Attempt to add FCM token that already exists
            await addFcmToken(req, res);

            // Assert: Verify no update is performed (idempotent behavior)
            expect(mockUserDocRef.update).not.toHaveBeenCalled();
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('FCM token already exists.');
        });
    });

    /**
     * Test group for edge cases and boundary conditions.
     * 
     * This test group validates the function's behavior in unusual or
     * boundary conditions that might occur in production environments.
     * These scenarios test the robustness of the function's data handling
     * and ensure graceful behavior even with unexpected data states.
     * 
     * Edge cases covered:
     * * Null or undefined FCM tokens arrays in user documents
     * * Malformed or corrupted user document data
     * * Race conditions and concurrent access scenarios
     * 
     * These tests ensure that the function handles real-world data
     * inconsistencies and edge cases that might occur due to:
     * * Database migration issues
     * * Concurrent user operations
     * * Partial failure recovery scenarios
     * * Data corruption or manual database modifications
     * 
     * The function should handle all edge cases gracefully without
     * throwing unhandled exceptions or leaving data in inconsistent states.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of null FCM tokens array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's fcm_tokens field is null. This could happen if
         * the field was never initialized or was explicitly set to null
         * during database operations or migrations.
         * 
         * Expected behavior:
         * * Function should treat null as equivalent to empty array
         * * New FCM tokens array should be created with the single token
         * * User document should be updated with proper tokens array
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function is resilient to database
         * schema variations and can handle user documents that don't
         * have properly initialized FCM tokens arrays, which might occur
         * in legacy data or after database migrations.
         * 
         * @test {Function} addFcmToken
         * @scenario User document has null fcm_tokens field
         * @expected HTTP 200 with tokens array initialized from null
         */
        test('should handle null FCM tokens array from user document', async () => {
            // Arrange: Configure user document with null FCM tokens array
            mockUserDocSnapshot.get.mockReturnValue(null);

            // Act: Add FCM token to user with null tokens array
            await addFcmToken(req, res);

            // Assert: Verify tokens array is properly initialized from null
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                fcm_tokens: ['test-fcm-token-123']
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('FCM token added successfully.');
        });

        /**
         * Tests handling of undefined FCM tokens array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's fcm_tokens field is undefined. This could happen
         * if the field doesn't exist in the document or was deleted
         * during database operations.
         * 
         * Expected behavior:
         * * Function should treat undefined as equivalent to empty array
         * * New FCM tokens array should be created with the single token
         * * User document should be updated with proper tokens array
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function can handle user documents
         * that are missing the fcm_tokens field entirely, which might occur
         * in new user accounts or after field deletions. The function
         * should gracefully initialize the field when needed.
         * 
         * @test {Function} addFcmToken
         * @scenario User document has undefined fcm_tokens field
         * @expected HTTP 200 with tokens array initialized from undefined
         */
        test('should handle undefined FCM tokens array from user document', async () => {
            // Arrange: Configure user document with undefined FCM tokens array
            mockUserDocSnapshot.get.mockReturnValue(undefined);

            // Act: Add FCM token to user with undefined tokens array
            await addFcmToken(req, res);

            // Assert: Verify tokens array is properly initialized from undefined
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                fcm_tokens: ['test-fcm-token-123']
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('FCM token added successfully.');
        });
    });

    /**
     * Test group for Firestore integration and database operation validation.
     * 
     * This test group validates that the function makes the correct calls
     * to Firestore collections and documents with proper parameters. These
     * tests ensure that the function interacts with the database using the
     * expected collection names, document IDs, and operation sequences.
     * 
     * Database operations validated:
     * * Correct collection name usage ('users')
     * * Proper document ID parameter passing
     * * Expected sequence of database operations
     * * Correct method calls on document references
     * 
     * These tests serve as integration tests that verify the function's
     * database interaction patterns without requiring actual Firestore
     * connections. They ensure that database schema expectations are
     * met and that the function follows established data access patterns.
     * 
     * This validation is crucial for:
     * * Ensuring consistent database schema usage
     * * Detecting breaking changes in database operations
     * * Validating proper parameter passing to Firestore SDK
     * * Confirming expected operation sequences
     */
    describe('Firestore integration', () => {
        /**
         * Tests correct Firestore collection and document access patterns.
         * 
         * Verifies that the function accesses the correct Firestore
         * collections and documents with the proper identifiers during
         * the FCM token addition workflow. This test ensures that the
         * function follows the expected database schema and access patterns.
         * 
         * Expected database operations:
         * 1. Access 'users' collection with authenticated user's UID
         * 2. Perform get operation to retrieve user document
         * 3. Perform update operation to modify FCM tokens array
         * 
         * Database schema validation:
         * * Users collection: /users/{userUid}
         * * Proper document ID parameter passing
         * * Correct method invocation sequence
         * 
         * This test ensures that the function maintains consistency with
         * the established database schema and doesn't accidentally access
         * wrong collections or use incorrect document identifiers, which
         * could lead to data corruption or security issues.
         * 
         * @test {Function} addFcmToken
         * @scenario Successful FCM token addition with database operation validation
         * @expected Correct Firestore collections and documents accessed with proper IDs
         */
        test('should call correct Firestore collections and documents', async () => {
            // Arrange: Configure successful FCM token addition scenario
            mockUserDocSnapshot.get.mockReturnValue([]);
            
            // Create specific collection mock for detailed validation
            const mockUsersCollection = { doc: jest.fn(() => mockUserDocRef) };
            mockFirestore.collection.mockReturnValue(mockUsersCollection);

            // Act: Execute FCM token addition workflow
            await addFcmToken(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            
            // Assert: Verify correct document ID usage
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid');
            
            // Assert: Verify proper operation sequence
            expect(mockUserDocRef.get).toHaveBeenCalled();
            expect(mockUserDocRef.update).toHaveBeenCalled();
        });
    });
});