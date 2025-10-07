/**
 * @fileoverview Test suite for removeDeviceFromUser Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * removeDeviceFromUser Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and device removal requirements.
 * 
 * The removeDeviceFromUser function handles the complete device removal workflow:
 * 1. Validates required deviceId query parameter and user authentication
 * 2. Retrieves user document from Firestore users collection
 * 3. Validates user document exists and contains device in devices array
 * 4. Removes device ID from user's devices array
 * 5. Checks if any other users are still linked to the device
 * 6. Deletes device document from devices collection if no other users linked
 * 7. Returns appropriate success messages based on operation results
 * 8. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * This function is critical for device lifecycle management, ensuring proper cleanup
 * when devices are removed from user accounts. It implements a reference counting
 * mechanism to prevent premature deletion of shared devices while maintaining
 * data integrity and preventing orphaned device records.
 * 
 * Test Categories:
 * * Input validation - Tests deviceId parameter and user UID validation
 * * User authentication - Tests user document existence and validation
 * * Device removal - Tests device removal from user's devices array
 * * Reference counting - Tests checking for other users linked to device
 * * Device cleanup - Tests device document deletion when no users remain
 * * Response handling - Tests appropriate success and error messages
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual data states
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Firestore collections - Mocked for users and devices collection access
 * * Document references - Mocked for get, update, and delete operations
 * * Query operations - Mocked for array-contains queries to check device usage
 * * Authentication context - Mocked for user UID validation
 * 
 * Test Coverage:
 * * 100% code coverage for the removeDeviceFromUser function
 * * All execution paths including success and error scenarios
 * * Input validation for required parameters
 * * Device removal and reference counting logic
 * * Database operation success and failure conditions
 * * Response formatting and status code validation
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
 * for user documents, including get and update operations that are used
 * during user validation and device array management.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving user documents
 * @property {jest.Mock} update - Mock function for updating user device arrays
 */
const mockUserDocRef = {
    get: jest.fn(),
    update: jest.fn()
};

/**
 * Mock Firestore document reference for device operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for device documents, including delete operations that are used
 * during device cleanup when no users remain linked.
 * 
 * @type {Object}
 * @property {jest.Mock} delete - Mock function for deleting device documents
 */
const mockDeviceDocRef = {
    delete: jest.fn()
};

/**
 * Mock Firestore query result for checking device usage.
 * 
 * Simulates the query result returned when checking if other users
 * are still linked to a device using array-contains queries.
 * 
 * @type {Object}
 * @property {boolean} empty - Whether the query returned no results
 * @property {jest.Mock} get - Mock function for executing the query
 */
const mockQueryResult = {
    empty: true,
    get: jest.fn()
};

/**
 * Mock Firestore query builder for array-contains operations.
 * 
 * Provides mocked implementations of Firestore query operations
 * used to check if other users are linked to a device before deletion.
 * 
 * @type {Object}
 * @property {jest.Mock} where - Mock function for adding query conditions
 * @property {jest.Mock} get - Mock function for executing the query
 */
const mockQuery = {
    where: jest.fn().mockReturnThis(),
    get: jest.fn(() => Promise.resolve(mockQueryResult))
};

/**
 * Mock Firestore collection reference for users operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the users collection, including document reference creation
 * and query operations for checking device usage.
 * 
 * @type {Object}
 * @property {jest.Mock} doc - Mock function for getting user document references
 * @property {jest.Mock} where - Mock function for creating queries
 */
const mockUsersCollection = {
    doc: jest.fn(() => mockUserDocRef),
    where: jest.fn(() => mockQuery)
};

/**
 * Mock Firestore collection reference for devices operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the devices collection, including document reference creation
 * for device deletion operations.
 * 
 * @type {Object}
 * @property {jest.Mock} doc - Mock function for getting device document references
 */
const mockDevicesCollection = {
    doc: jest.fn(() => mockDeviceDocRef)
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate collection references
 * for both users and devices collections used in device removal workflow.
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 * 
 * @example
 * // Returns users collection reference for 'users' collection
 * mockFirestore.collection('users')
 * 
 * @example
 * // Returns devices collection reference for 'devices' collection
 * mockFirestore.collection('devices')
 */
const mockFirestore = {
    collection: jest.fn((collectionName) => {
        if (collectionName === 'users') {
            return mockUsersCollection;
        }
        if (collectionName === 'devices') {
            return mockDevicesCollection;
        }
    })
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
const { removeDeviceFromUser } = require('../src/removeDeviceFromUser.cjs');/**
 * T
est suite for removeDeviceFromUser Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete device removal workflow,
 * covering all success paths, error conditions, and edge cases. The tests ensure
 * that the function properly handles input validation, user authentication,
 * device removal, reference counting, and cleanup operations.
 * 
 * Test Structure:
 * * Input validation - Tests deviceId parameter and user UID validation
 * * User authentication - Tests user document existence and validation
 * * Device removal - Tests device removal from user's devices array
 * * Reference counting - Tests checking for other users linked to device
 * * Device cleanup - Tests device document deletion logic
 * * Response handling - Tests appropriate success and error messages
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual data states
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('removeDeviceFromUser', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * Simulates the Express.js request object that would be passed to the
     * removeDeviceFromUser function in a real HTTP request scenario. Contains
     * user authentication information and query parameters.
     * 
     * @type {Object}
     * @property {Object} user - User authentication information from middleware
     * @property {string} user.uid - Firebase Auth user ID
     * @property {Object} query - HTTP query parameters
     * @property {string} query.deviceId - Device ID to remove from user
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
     * that are used to check user validity and get device arrays.
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
     * 3. Configuring default successful user document scenarios
     * 4. Setting up default query and operation responses
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
         * user and valid device ID. Individual tests can override these
         * values to test specific error conditions or edge cases.
         */
        req = {
            user: { uid: 'test-user-uid' },
            query: { deviceId: 'test-device-123' }
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

        /**
         * Configure default user document snapshot for successful scenarios.
         * 
         * Sets up a user document that exists and has a devices array containing
         * the test device, representing a typical user with the device to remove.
         */
        mockUserDocSnapshot = {
            exists: true,
            get: jest.fn().mockReturnValue(['test-device-123', 'other-device'])
        };

        // Reset all Firestore mock function call history
        mockUserDocRef.get.mockClear();
        mockUserDocRef.update.mockClear();
        mockDeviceDocRef.delete.mockClear();
        mockUsersCollection.doc.mockClear();
        mockDevicesCollection.doc.mockClear();
        mockQuery.where.mockClear();
        mockQuery.get.mockClear();

        // Configure all Firestore operations to resolve successfully by default
        mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
        mockUserDocRef.update.mockResolvedValue();
        mockDeviceDocRef.delete.mockResolvedValue();
        mockQueryResult.empty = true; // Default: no other users have the device
        mockQuery.get.mockResolvedValue(mockQueryResult);
    });    
/**
     * Test group for input validation scenarios.
     * 
     * This test group validates that the removeDeviceFromUser function properly
     * enforces all input validation rules and returns appropriate error
     * responses when required data is missing or invalid.
     * 
     * The function must validate:
     * * deviceId - Required query parameter for device identification
     * * userUid - Required user identifier from authentication context
     * 
     * All validation failures should return HTTP 400 (Bad Request) status
     * with clear, actionable error messages that help clients understand
     * what data is required and how to correct their requests.
     */
    describe('Input validation', () => {
        /**
         * Tests validation of missing deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId query parameter is missing. The deviceId is essential
         * for identifying which device to remove from the user's account.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * No database operations should be attempted
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Missing deviceId query parameter
         * @expected HTTP 400 with "Device ID is required" message
         */
        test('should return 400 if deviceId is missing', async () => {
            // Arrange: Remove deviceId from query parameters
            req.query.deviceId = undefined;

            // Act: Call function with missing deviceId
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID is required');
        });

        /**
         * Tests validation of empty deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId query parameter is present but contains an empty string.
         * Empty device IDs are not valid for device removal operations.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * Empty strings should be treated the same as missing values
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Empty string deviceId query parameter
         * @expected HTTP 400 with "Device ID is required" message
         */
        test('should return 400 if deviceId is empty string', async () => {
            // Arrange: Set deviceId to empty string
            req.query.deviceId = '';

            // Act: Call function with empty deviceId
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID is required');
        });

        /**
         * Tests validation of missing userUid from authentication.
         * 
         * Verifies that the function properly rejects requests when the
         * user UID is missing from the authentication context. This could
         * happen if authentication middleware fails or is bypassed.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should indicate user UID is missing or invalid
         * * No database operations should be attempted
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Missing user UID in authentication context
         * @expected HTTP 400 with "The user UID is missing or invalid." message
         */
        test('should return 400 if userUid is missing', async () => {
            // Arrange: Remove user UID from authentication context
            req.user.uid = undefined;

            // Act: Call function with missing user UID
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('The user UID is missing or invalid.');
        });

        /**
         * Tests validation of invalid userUid data type.
         * 
         * Verifies that the function properly rejects requests when the
         * user UID is not a string. Firebase Auth UIDs are always strings,
         * so non-string values indicate corrupted authentication data.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should indicate user UID is missing or invalid
         * * Type validation should prevent processing of invalid data
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Non-string user UID in authentication context
         * @expected HTTP 400 with "The user UID is missing or invalid." message
         */
        test('should return 400 if userUid is not a string', async () => {
            // Arrange: Set user UID to non-string value
            req.user.uid = 123;

            // Act: Call function with invalid user UID type
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('The user UID is missing or invalid.');
        });
    });

    /**
     * Test group for user authentication scenarios.
     * 
     * This test group validates the function's behavior when handling
     * user authentication and document existence. The function must
     * verify that the authenticated user exists in the database before
     * attempting to remove devices from their account.
     */
    describe('User authentication', () => {
        /**
         * Tests handling of non-existent user documents.
         * 
         * Verifies that the function properly handles cases where an
         * authenticated user does not have a corresponding document in
         * the Firestore users collection.
         * 
         * Expected behavior:
         * * Function should return HTTP 404 (Not Found) status code
         * * Response message should clearly indicate user was not found
         * * No device operations should be attempted
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario User document does not exist in Firestore
         * @expected HTTP 404 with "User not found" message
         */
        test('should return 404 if user document does not exist', async () => {
            // Arrange: Configure user document to not exist
            mockUserDocSnapshot.exists = false;

            // Act: Attempt to remove device for non-existent user
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper not found response
            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.send).toHaveBeenCalledWith('User not found');
        });

        /**
         * Tests handling of user document retrieval errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during user document retrieval.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged for debugging purposes
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Firestore throws error during user document retrieval
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document retrieval error', async () => {
            // Arrange: Configure user document retrieval to fail
            mockUserDocRef.get.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to remove device when user retrieval fails
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });    /**
  
   * Test group for device removal scenarios.
     * 
     * This test group validates the core functionality of removing devices
     * from a user's device array. The function must properly handle various
     * device array states and update the user document accordingly.
     */
    describe('Device removal', () => {
        /**
         * Tests successful device removal from user's devices array.
         * 
         * Verifies that the function properly removes a device from the
         * user's devices array when the device exists in the array and
         * no other users are linked to the device.
         * 
         * Expected behavior:
         * * Function should remove device from user's devices array
         * * User document should be updated with modified array
         * * Device document should be deleted (no other users)
         * * Function should return HTTP 200 with success message
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Device exists in user array and no other users linked
         * @expected HTTP 200 with device removed and deleted
         */
        test('should remove device from user and delete device document', async () => {
            // Act: Remove device from user
            await removeDeviceFromUser(req, res);

            // Assert: Verify device was removed from user's array
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['other-device'] // test-device-123 removed
            });

            // Assert: Verify query was made to check for other users
            expect(mockUsersCollection.where).toHaveBeenCalledWith('devices', 'array-contains', 'test-device-123');
            expect(mockQuery.get).toHaveBeenCalled();

            // Assert: Verify device document was deleted (no other users)
            expect(mockDeviceDocRef.delete).toHaveBeenCalled();

            // Assert: Verify success response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device removed successfully');
        });

        /**
         * Tests device removal when other users are still linked.
         * 
         * Verifies that the function properly removes a device from the
         * user's devices array but does not delete the device document
         * when other users are still linked to the device.
         * 
         * Expected behavior:
         * * Function should remove device from user's devices array
         * * User document should be updated with modified array
         * * Device document should NOT be deleted (other users exist)
         * * Function should return HTTP 200 with success message
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Device exists in user array but other users are linked
         * @expected HTTP 200 with device removed but not deleted
         */
        test('should remove device from user but not delete device document when other users linked', async () => {
            // Arrange: Configure query to return other users with the device
            mockQueryResult.empty = false;

            // Act: Remove device from user
            await removeDeviceFromUser(req, res);

            // Assert: Verify device was removed from user's array
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['other-device'] // test-device-123 removed
            });

            // Assert: Verify query was made to check for other users
            expect(mockUsersCollection.where).toHaveBeenCalledWith('devices', 'array-contains', 'test-device-123');
            expect(mockQuery.get).toHaveBeenCalled();

            // Assert: Verify device document was NOT deleted (other users exist)
            expect(mockDeviceDocRef.delete).not.toHaveBeenCalled();

            // Assert: Verify success response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device removed successfully');
        });

        /**
         * Tests handling when device is not linked to user.
         * 
         * Verifies that the function properly handles cases where the
         * device ID is not present in the user's devices array. This
         * should be treated as a successful operation (idempotent).
         * 
         * Expected behavior:
         * * Function should detect device is not in user's array
         * * No update operation should be performed
         * * No device deletion should be attempted
         * * Function should return HTTP 200 with appropriate message
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Device is not in user's devices array
         * @expected HTTP 200 with "Device was not linked to user" message
         */
        test('should handle device not linked to user', async () => {
            // Arrange: Configure user devices array without the target device
            mockUserDocSnapshot.get.mockReturnValue(['other-device-1', 'other-device-2']);

            // Act: Attempt to remove device not linked to user
            await removeDeviceFromUser(req, res);

            // Assert: Verify no update was performed
            expect(mockUserDocRef.update).not.toHaveBeenCalled();

            // Assert: Verify no query for other users was made
            expect(mockUsersCollection.where).not.toHaveBeenCalled();

            // Assert: Verify no device deletion was attempted
            expect(mockDeviceDocRef.delete).not.toHaveBeenCalled();

            // Assert: Verify appropriate response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device was not linked to user');
        });

        /**
         * Tests handling of user document update errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during user document update operations.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged for debugging purposes
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Firestore throws error during user document update
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document update error', async () => {
            // Arrange: Configure user document update to fail
            mockUserDocRef.update.mockRejectedValue(new Error('Update failed'));

            // Act: Attempt to remove device when update fails
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });   
 /**
     * Test group for reference counting and device cleanup scenarios.
     * 
     * This test group validates the function's reference counting logic
     * and device cleanup operations. The function must properly check
     * if other users are linked to a device before deleting it.
     */
    describe('Reference counting and cleanup', () => {
        /**
         * Tests query error handling during reference counting.
         * 
         * Verifies that the function properly handles database errors
         * that occur during the query to check for other users linked
         * to the device.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged for debugging purposes
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Firestore throws error during reference counting query
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle query error during reference counting', async () => {
            // Arrange: Configure query to fail
            mockQuery.get.mockRejectedValue(new Error('Query failed'));

            // Act: Attempt to remove device when query fails
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests device document deletion error handling.
         * 
         * Verifies that the function properly handles database errors
         * that occur during device document deletion operations.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged for debugging purposes
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Firestore throws error during device document deletion
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle device document deletion error', async () => {
            // Arrange: Configure device deletion to fail
            mockDeviceDocRef.delete.mockRejectedValue(new Error('Delete failed'));

            // Act: Attempt to remove device when deletion fails
            await removeDeviceFromUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests correct query construction for reference counting.
         * 
         * Verifies that the function constructs the correct Firestore
         * query to check for other users linked to the device using
         * array-contains operations.
         * 
         * Expected behavior:
         * * Function should query users collection
         * * Query should use array-contains with correct device ID
         * * Query should be executed to get results
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Successful device removal with query validation
         * @expected Correct query constructed and executed
         */
        test('should construct correct query for reference counting', async () => {
            // Act: Remove device from user
            await removeDeviceFromUser(req, res);

            // Assert: Verify correct query construction
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            expect(mockUsersCollection.where).toHaveBeenCalledWith('devices', 'array-contains', 'test-device-123');
            expect(mockQuery.get).toHaveBeenCalled();
        });
    });

    /**
     * Test group for edge cases and boundary conditions.
     * 
     * This test group validates the function's behavior with unusual
     * data states and edge cases that might occur in production
     * environments.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of null devices array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's devices field is null.
         * 
         * Expected behavior:
         * * Function should treat null as empty array
         * * Function should return success message for not linked
         * * No operations should be performed
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario User document has null devices field
         * @expected HTTP 200 with "Device was not linked to user" message
         */
        test('should handle null devices array from user document', async () => {
            // Arrange: Configure user document with null devices array
            mockUserDocSnapshot.get.mockReturnValue(null);

            // Act: Attempt to remove device with null array
            await removeDeviceFromUser(req, res);

            // Assert: Verify appropriate response (device not linked)
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device was not linked to user');

            // Assert: Verify no operations were performed
            expect(mockUserDocRef.update).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.delete).not.toHaveBeenCalled();
        });

        /**
         * Tests handling of undefined devices array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's devices field is undefined.
         * 
         * Expected behavior:
         * * Function should treat undefined as empty array
         * * Function should return success message for not linked
         * * No operations should be performed
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario User document has undefined devices field
         * @expected HTTP 200 with "Device was not linked to user" message
         */
        test('should handle undefined devices array from user document', async () => {
            // Arrange: Configure user document with undefined devices array
            mockUserDocSnapshot.get.mockReturnValue(undefined);

            // Act: Attempt to remove device with undefined array
            await removeDeviceFromUser(req, res);

            // Assert: Verify appropriate response (device not linked)
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device was not linked to user');

            // Assert: Verify no operations were performed
            expect(mockUserDocRef.update).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.delete).not.toHaveBeenCalled();
        });

        /**
         * Tests device removal with different device IDs.
         * 
         * Verifies that the function properly handles various valid
         * device ID formats and removes the correct device from arrays.
         * 
         * Expected behavior:
         * * Function should handle different valid device ID formats
         * * Correct device should be removed from array
         * * Other devices should remain in array
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Different valid device ID provided
         * @expected Correct device removed from array
         */
        test('should handle different device ID formats', async () => {
            // Arrange: Configure different device ID and user array
            req.query.deviceId = 'different-device-456';
            mockUserDocSnapshot.get.mockReturnValue(['device-1', 'different-device-456', 'device-3']);

            // Act: Remove different device
            await removeDeviceFromUser(req, res);

            // Assert: Verify correct device was removed
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['device-1', 'device-3'] // different-device-456 removed
            });

            // Assert: Verify query used correct device ID
            expect(mockUsersCollection.where).toHaveBeenCalledWith('devices', 'array-contains', 'different-device-456');
        });

        /**
         * Tests device removal from single-device array.
         * 
         * Verifies that the function properly handles removal of the
         * only device from a user's devices array, resulting in an
         * empty array.
         * 
         * Expected behavior:
         * * Function should remove the single device
         * * User's devices array should become empty
         * * Device document should be deleted (no other users)
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario User has only one device to remove
         * @expected Device removed and array becomes empty
         */
        test('should handle removal of single device from array', async () => {
            // Arrange: Configure user with only the target device
            mockUserDocSnapshot.get.mockReturnValue(['test-device-123']);
            // Reset and reconfigure mocks for this specific test
            mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
            mockQueryResult.empty = true; // No other users have the device

            // Act: Remove the only device
            await removeDeviceFromUser(req, res);

            // Assert: Verify array becomes empty
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: [] // empty array after removal
            });

            // Assert: Verify device document was deleted
            expect(mockDeviceDocRef.delete).toHaveBeenCalled();

            // Assert: Verify success response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device removed successfully');
        });
    });   
 /**
     * Test group for Firestore integration and database operation validation.
     * 
     * This test group validates that the function makes the correct calls
     * to Firestore collections and operations with proper parameters.
     */
    describe('Firestore integration', () => {
        /**
         * Tests correct Firestore collection and operation access patterns.
         * 
         * Verifies that the function accesses the correct Firestore
         * collections and performs the expected operations during
         * the device removal workflow.
         * 
         * Expected database operations:
         * 1. Access 'users' collection with user UID
         * 2. Access 'devices' collection with device ID
         * 3. Perform get, update, query, and delete operations as needed
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Successful device removal with database operation validation
         * @expected Correct Firestore collections accessed with proper operations
         */
        test('should call correct Firestore collections and operations', async () => {
            // Arrange: Ensure mocks are properly configured
            mockQueryResult.empty = true; // No other users have the device

            // Act: Execute device removal workflow
            await removeDeviceFromUser(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            expect(mockFirestore.collection).toHaveBeenCalledWith('devices');

            // Assert: Verify correct document operations
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid');
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('test-device-123');

            // Assert: Verify operations were performed
            expect(mockUserDocRef.get).toHaveBeenCalled();
            expect(mockUserDocRef.update).toHaveBeenCalled();
            expect(mockUsersCollection.where).toHaveBeenCalled();
            expect(mockDeviceDocRef.delete).toHaveBeenCalled();
        });

        /**
         * Tests proper operation sequence for device removal.
         * 
         * Verifies that the function performs database operations in the
         * correct sequence: user validation, device removal, reference
         * counting, and cleanup.
         * 
         * Expected operation sequence:
         * 1. Get user document to validate and retrieve devices
         * 2. Update user document to remove device
         * 3. Query for other users with the device
         * 4. Delete device document if no other users
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Device removal with operation sequence validation
         * @expected Operations performed in correct sequence
         */
        test('should perform operations in correct sequence', async () => {
            // Arrange: Ensure mocks are properly configured
            mockQueryResult.empty = true; // No other users have the device

            // Act: Execute device removal workflow
            await removeDeviceFromUser(req, res);

            // Assert: Verify user document was retrieved first
            expect(mockUserDocRef.get).toHaveBeenCalled();
            
            // Assert: Verify user document was updated after validation
            expect(mockUserDocRef.update).toHaveBeenCalled();
            
            // Assert: Verify query was made after user update
            expect(mockQuery.get).toHaveBeenCalled();
            
            // Assert: Verify device deletion was performed last
            expect(mockDeviceDocRef.delete).toHaveBeenCalled();
            
            // Assert: Verify operations were called in correct order
            const userGetCalls = mockUserDocRef.get.mock.invocationCallOrder;
            const userUpdateCalls = mockUserDocRef.update.mock.invocationCallOrder;
            const queryCalls = mockQuery.get.mock.invocationCallOrder;
            const deviceDeleteCalls = mockDeviceDocRef.delete.mock.invocationCallOrder;
            
            expect(userGetCalls[0]).toBeLessThan(userUpdateCalls[0]);
            expect(userUpdateCalls[0]).toBeLessThan(queryCalls[0]);
            expect(queryCalls[0]).toBeLessThan(deviceDeleteCalls[0]);
        });

        /**
         * Tests correct document ID parameter passing.
         * 
         * Verifies that the function uses the correct document IDs
         * for all Firestore operations, ensuring data integrity.
         * 
         * Expected parameter usage:
         * * User operations use authenticated user UID
         * * Device operations use provided device ID
         * * Query operations use correct device ID for filtering
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Device removal with parameter validation
         * @expected Correct document IDs used for all operations
         */
        test('should use correct document IDs for operations', async () => {
            // Arrange: Configure specific IDs for validation
            req.user.uid = 'specific-user-123';
            req.query.deviceId = 'specific-device-456';
            mockUserDocSnapshot.get.mockReturnValue(['specific-device-456', 'other-device']);
            mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
            mockQueryResult.empty = true; // No other users have the device

            // Act: Execute device removal workflow
            await removeDeviceFromUser(req, res);

            // Assert: Verify correct user document ID
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('specific-user-123');
            
            // Assert: Verify correct device document ID
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('specific-device-456');
            
            // Assert: Verify correct device ID in query
            expect(mockUsersCollection.where).toHaveBeenCalledWith('devices', 'array-contains', 'specific-device-456');
        });
    });

    /**
     * Test group for response handling validation.
     * 
     * This test group validates that the function returns appropriate
     * HTTP status codes and messages for different scenarios.
     */
    describe('Response handling', () => {
        /**
         * Tests appropriate success messages for different scenarios.
         * 
         * Verifies that the function returns different success messages
         * based on the specific outcome of the device removal operation.
         * 
         * Expected responses:
         * * "Device removed successfully" - when device removed and possibly deleted
         * * "Device was not linked to user" - when device not in user's array
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Various successful device removal scenarios
         * @expected Appropriate success messages for each scenario
         */
        test('should return appropriate success messages', async () => {
            // Arrange: Ensure proper mock setup for successful removal
            mockQueryResult.empty = true; // No other users have the device

            // Test 1: Device removed successfully
            await removeDeviceFromUser(req, res);
            expect(res.send).toHaveBeenCalledWith('Device removed successfully');

            // Reset mocks for next test
            jest.clearAllMocks();
            res.status.mockReturnThis();

            // Test 2: Device not linked to user
            mockUserDocSnapshot.get.mockReturnValue(['other-device']);
            mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);

            await removeDeviceFromUser(req, res);
            expect(res.send).toHaveBeenCalledWith('Device was not linked to user');
        });

        /**
         * Tests consistent HTTP status codes.
         * 
         * Verifies that the function returns appropriate HTTP status
         * codes for different scenarios (200 for success, 400 for
         * validation errors, 404 for not found, 500 for server errors).
         * 
         * Expected status codes:
         * * 200 - Successful operations (removed or not linked)
         * * 400 - Input validation failures
         * * 404 - User not found
         * * 500 - Internal server errors
         * 
         * @test {Function} removeDeviceFromUser
         * @scenario Various scenarios with status code validation
         * @expected Correct HTTP status codes for each scenario
         */
        test('should return consistent HTTP status codes', async () => {
            // Arrange: Ensure proper mock setup for successful removal
            mockQueryResult.empty = true; // No other users have the device

            // Test successful removal
            await removeDeviceFromUser(req, res);
            expect(res.status).toHaveBeenCalledWith(200);

            // Reset for validation error test
            jest.clearAllMocks();
            res.status.mockReturnThis();
            req.query.deviceId = '';

            // Test validation error
            await removeDeviceFromUser(req, res);
            expect(res.status).toHaveBeenCalledWith(400);
        });
    });
});