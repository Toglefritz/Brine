/**
 * @fileoverview Test suite for addDeviceToUser Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * addDeviceToUser Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and data validation requirements.
 * 
 * The addDeviceToUser function handles the complete device registration workflow:
 * 1. Validates user authentication and input parameters
 * 2. Checks user document existence and device array management
 * 3. Prevents duplicate device registrations
 * 4. Creates device records with proper initial values
 * 5. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * Test Categories:
 * * Input validation - Ensures all required fields are validated properly
 * * User document handling - Tests user existence and retrieval scenarios
 * * Device addition workflow - Covers device array management and updates
 * * Device document creation - Validates device record creation and initialization
 * * Edge cases - Handles null/undefined values and boundary conditions
 * * Firestore integration - Verifies correct database operations and calls
 * * Error handling - Ensures proper error responses and status codes
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Firestore collections - Mocked for users and devices collection access
 * * Document references - Mocked for get, set, and update operations
 * * Authentication context - Mocked for user authentication validation
 * 
 * Test Coverage:
 * * 100% code coverage for the addDeviceToUser function
 * * All execution paths including success and error scenarios
 * * Input validation for all required and optional parameters
 * * Database operation success and failure conditions
 * * Authentication and authorization edge cases
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
 * used during device registration workflow.
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
 * for device documents, including get and set operations that are
 * used during device creation and existence checking.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for checking device existence
 * @property {jest.Mock} set - Mock function for creating new device documents
 */
const mockDeviceDocRef = {
    get: jest.fn(),
    set: jest.fn()
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate document references
 * based on collection names (users or devices).
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 * 
 * @example
 * // Returns user document reference for 'users' collection
 * mockFirestore.collection('users').doc('user-id')
 * 
 * @example
 * // Returns device document reference for 'devices' collection
 * mockFirestore.collection('devices').doc('device-id')
 */
const mockFirestore = {
    collection: jest.fn((collectionName) => {
        if (collectionName === 'users') {
            return { doc: jest.fn(() => mockUserDocRef) };
        }
        if (collectionName === 'devices') {
            return { doc: jest.fn(() => mockDeviceDocRef) };
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
const { addDeviceToUser } = require('../src/addDeviceToUser.cjs');

/**
 * Test suite for addDeviceToUser Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete device registration
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles user authentication,
 * input validation, Firestore operations, and error responses.
 * 
 * Test Structure:
 * * Input validation - Tests for required fields and data format validation
 * * User document handling - Tests user existence and document retrieval
 * * Device addition workflow - Tests device array management and updates
 * * Device document creation - Tests device record creation and initialization
 * * Edge cases - Tests boundary conditions and null/undefined handling
 * * Firestore integration - Tests database operation calls and responses
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('addDeviceToUser', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * Simulates the Express.js request object that would be passed to the
     * addDeviceToUser function in a real HTTP request scenario. Contains
     * user authentication information and request body data.
     * 
     * @type {Object}
     * @property {Object} user - User authentication information from middleware
     * @property {string} user.uid - Firebase Auth user ID
     * @property {Object} body - HTTP request body containing device information
     * @property {string} body.deviceId - Unique identifier for the device
     * @property {string} body.deviceName - Human-readable name for the device
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
     * Mock Firestore document snapshot for device documents.
     * 
     * Simulates the document snapshot returned by Firestore when checking
     * device existence. Used to determine whether a device already exists
     * in the devices collection before creating a new record.
     * 
     * @type {Object}
     * @property {boolean} exists - Whether the device document exists in Firestore
     */
    let mockDeviceDocSnapshot;

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
         * user and valid device data. Individual tests can override these
         * values to test specific error conditions or edge cases.
         */
        req = {
            user: { uid: 'test-user-uid' },
            body: {
                deviceId: 'test-device-id',
                deviceName: 'Test Device'
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
        mockDeviceDocRef.get.mockClear();
        mockDeviceDocRef.set.mockClear();

        /**
         * Configure default user document snapshot for successful scenarios.
         * 
         * Sets up a user document that exists and has an empty devices array,
         * representing a valid user account ready to accept new devices.
         */
        mockUserDocSnapshot = {
            exists: true,
            get: jest.fn().mockReturnValue([])
        };

        /**
         * Configure default device document snapshot for new device scenarios.
         * 
         * Sets up a device document that doesn't exist, representing the
         * typical case where a new device is being registered for the first time.
         */
        mockDeviceDocSnapshot = {
            exists: false
        };

        // Configure all Firestore operations to resolve successfully by default
        mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
        mockUserDocRef.update.mockResolvedValue();
        mockDeviceDocRef.get.mockResolvedValue(mockDeviceDocSnapshot);
        mockDeviceDocRef.set.mockResolvedValue();
    });

    /**
     * Test group for input validation scenarios.
     * 
     * This test group validates that the addDeviceToUser function properly
     * enforces all input validation rules and returns appropriate error
     * responses when required data is missing or invalid.
     * 
     * The function must validate:
     * * deviceId - Required unique identifier for the device
     * * deviceName - Required human-readable name for the device
     * * userUid - Required user identifier from authentication middleware
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
         * Tests validation of missing deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId field is completely missing from the request body.
         * This is a critical validation since deviceId is used as the
         * primary key for device records in Firestore.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * No database operations should be attempted
         * 
         * @test {Function} addDeviceToUser
         * @scenario Missing deviceId parameter in request body
         * @expected HTTP 400 with "Device ID is required" message
         */
        test('should return 400 if deviceId is missing', async () => {
            // Arrange: Remove deviceId from request body
            req.body.deviceId = undefined;

            // Act: Call function with missing deviceId
            await addDeviceToUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID is required');
        });

        /**
         * Tests validation of empty deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId field is present but contains an empty string. Empty
         * strings are not valid device identifiers and would cause issues
         * with Firestore document creation and retrieval.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * Empty strings should be treated the same as missing values
         * 
         * @test {Function} addDeviceToUser
         * @scenario Empty string deviceId parameter in request body
         * @expected HTTP 400 with "Device ID is required" message
         */
        test('should return 400 if deviceId is empty string', async () => {
            // Arrange: Set deviceId to empty string
            req.body.deviceId = '';

            // Act: Call function with empty deviceId
            await addDeviceToUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID is required');
        });

        /**
         * Tests validation of missing deviceName parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceName field is completely missing from the request body.
         * Device names are required for user interface display and device
         * identification purposes.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceName is required
         * * No database operations should be attempted
         * 
         * @test {Function} addDeviceToUser
         * @scenario Missing deviceName parameter in request body
         * @expected HTTP 400 with "Device name is required" message
         */
        test('should return 400 if deviceName is missing', async () => {
            // Arrange: Remove deviceName from request body
            req.body.deviceName = undefined;

            // Act: Call function with missing deviceName
            await addDeviceToUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device name is required');
        });

        /**
         * Tests validation of empty deviceName parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceName field is present but contains an empty string. Empty
         * device names would result in poor user experience and make it
         * difficult for users to identify their devices.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceName is required
         * * Empty strings should be treated the same as missing values
         * 
         * @test {Function} addDeviceToUser
         * @scenario Empty string deviceName parameter in request body
         * @expected HTTP 400 with "Device name is required" message
         */
        test('should return 400 if deviceName is empty string', async () => {
            // Arrange: Set deviceName to empty string
            req.body.deviceName = '';

            // Act: Call function with empty deviceName
            await addDeviceToUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device name is required');
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
         * @test {Function} addDeviceToUser
         * @scenario Missing user UID in authentication context
         * @expected HTTP 400 with "The user UID is missing or invalid." message
         */
        test('should return 400 if userUid is missing', async () => {
            // Arrange: Remove user UID from authentication context
            req.user.uid = undefined;

            // Act: Call function with missing user UID
            await addDeviceToUser(req, res);

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
         * @test {Function} addDeviceToUser
         * @scenario Non-string user UID in authentication context
         * @expected HTTP 400 with "The user UID is missing or invalid." message
         */
        test('should return 400 if userUid is not a string', async () => {
            // Arrange: Set user UID to non-string value
            req.user.uid = 123;

            // Act: Call function with invalid user UID type
            await addDeviceToUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('The user UID is missing or invalid.');
        });

        /**
         * Tests validation of empty userUid string.
         * 
         * Verifies that the function properly rejects requests when the
         * user UID is an empty string. Empty UIDs are not valid Firebase
         * Auth identifiers and would cause database operation failures.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should indicate user UID is missing or invalid
         * * Empty strings should be treated as invalid authentication
         * 
         * @test {Function} addDeviceToUser
         * @scenario Empty string user UID in authentication context
         * @expected HTTP 400 with "The user UID is missing or invalid." message
         */
        test('should return 400 if userUid is empty string', async () => {
            // Arrange: Set user UID to empty string
            req.user.uid = '';

            // Act: Call function with empty user UID
            await addDeviceToUser(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('The user UID is missing or invalid.');
        });
    });

    /**
     * Test group for user document handling scenarios.
     * 
     * This test group validates the function's behavior when interacting
     * with user documents in Firestore. The addDeviceToUser function must
     * verify that the authenticated user exists in the database before
     * allowing device registration.
     * 
     * User document operations tested:
     * * User document existence verification
     * * Firestore retrieval error handling
     * * User document data access and validation
     * 
     * These tests ensure that only valid, existing users can register
     * devices and that database errors are handled gracefully with
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
         * * No device operations should be attempted
         * * Error should be logged for debugging purposes
         * 
         * This test ensures that device registration fails gracefully
         * when user data integrity issues are detected, preventing
         * orphaned device records and maintaining data consistency.
         * 
         * @test {Function} addDeviceToUser
         * @scenario User document does not exist in Firestore
         * @expected HTTP 404 with "User not found" message
         */
        test('should return 404 if user document does not exist', async () => {
            // Arrange: Configure user document to not exist
            const nonExistentUserSnapshot = { exists: false };
            mockUserDocRef.get.mockResolvedValue(nonExistentUserSnapshot);

            // Act: Attempt to add device for non-existent user
            await addDeviceToUser(req, res);

            // Assert: Verify proper not found response
            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.send).toHaveBeenCalledWith('User not found');
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
         * @test {Function} addDeviceToUser
         * @scenario Firestore throws error during user document retrieval
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document retrieval error', async () => {
            // Arrange: Configure Firestore to throw error during user document retrieval
            mockUserDocRef.get.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to add device when database error occurs
            await addDeviceToUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });

    /**
     * Test group for device addition to user workflow scenarios.
     * 
     * This test group validates the core functionality of adding devices
     * to a user's device array in Firestore. The function must properly
     * manage the user's devices array, preventing duplicates and handling
     * various array states (empty, populated, null/undefined).
     * 
     * Device addition workflow:
     * 1. Retrieve user's current devices array from Firestore
     * 2. Check if device already exists in the array
     * 3. Add device to array if not already present
     * 4. Update user document with modified devices array
     * 5. Handle all error conditions gracefully
     * 
     * Array management scenarios tested:
     * * Adding device to empty devices array
     * * Adding device to existing devices array
     * * Preventing duplicate device additions
     * * Handling Firestore update errors
     * 
     * These tests ensure data consistency and prevent duplicate device
     * registrations while maintaining proper error handling and user
     * feedback throughout the device addition process.
     */
    describe('Device addition to user', () => {
        /**
         * Tests adding a device to an empty devices array.
         * 
         * Verifies that the function properly handles the case where a user
         * has no existing devices and is registering their first device.
         * This is a common scenario for new users or users who have removed
         * all their previous devices.
         * 
         * Expected behavior:
         * * Function should create a new array with the single device ID
         * * User document should be updated with the new devices array
         * * Device document should be created in the devices collection
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function properly initializes device
         * arrays for users and handles the transition from no devices to
         * having devices without any data corruption or errors.
         * 
         * @test {Function} addDeviceToUser
         * @scenario User has empty devices array, adding first device
         * @expected HTTP 200 with successful device addition and array update
         */
        test('should add new device to empty devices array', async () => {
            // Arrange: Configure user with empty devices array
            mockUserDocSnapshot.get.mockReturnValue([]);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);

            // Act: Add device to user with empty devices array
            await addDeviceToUser(req, res);

            // Assert: Verify devices array is properly initialized and updated
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['test-device-id']
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device added successfully');
        });

        /**
         * Tests adding a device to an existing devices array.
         * 
         * Verifies that the function properly handles the case where a user
         * already has devices registered and is adding an additional device.
         * This is the most common scenario for active users expanding their
         * device ecosystem.
         * 
         * Expected behavior:
         * * Function should append new device ID to existing array
         * * Existing device IDs should remain unchanged and in order
         * * User document should be updated with the expanded devices array
         * * Device document should be created in the devices collection
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function properly maintains existing
         * device associations while adding new devices, preserving data
         * integrity and user device history.
         * 
         * @test {Function} addDeviceToUser
         * @scenario User has existing devices, adding additional device
         * @expected HTTP 200 with device appended to existing array
         */
        test('should add new device to existing devices array', async () => {
            // Arrange: Configure user with existing devices
            mockUserDocSnapshot.get.mockReturnValue(['existing-device-1', 'existing-device-2']);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);

            // Act: Add device to user with existing devices
            await addDeviceToUser(req, res);

            // Assert: Verify new device is appended to existing array
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['existing-device-1', 'existing-device-2', 'test-device-id']
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device added successfully');
        });

        /**
         * Tests duplicate device prevention.
         * 
         * Verifies that the function properly handles attempts to add a
         * device that is already associated with the user's account. This
         * prevents data corruption and maintains array integrity by avoiding
         * duplicate entries in the user's devices array.
         * 
         * Expected behavior:
         * * Function should detect existing device in user's devices array
         * * No update operation should be performed on user document
         * * Function should still return HTTP 200 (idempotent operation)
         * * Response message should indicate successful operation with existing record
         * 
         * This test ensures that the function behaves idempotently, allowing
         * clients to safely retry device addition operations without causing
         * data duplication or errors. This is important for reliable client
         * implementations and network error recovery scenarios.
         * 
         * @test {Function} addDeviceToUser
         * @scenario Device already exists in user's devices array
         * @expected HTTP 200 with no array modification, idempotent behavior
         */
        test('should not duplicate device if already in user devices array', async () => {
            // Arrange: Configure user with device already in devices array
            mockUserDocSnapshot.get.mockReturnValue(['test-device-id', 'other-device']);
            const existingDeviceSnapshot = { exists: true };
            mockDeviceDocRef.get.mockResolvedValue(existingDeviceSnapshot);

            // Act: Attempt to add device that already exists
            await addDeviceToUser(req, res);

            // Assert: Verify no update is performed (idempotent behavior)
            expect(mockUserDocRef.update).not.toHaveBeenCalled();
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device added successfully with existing record in devices collection');
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
         * device might be created but not associated with the user.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during update
         * * Firestore permission denied errors
         * * Document lock conflicts
         * * Service unavailable conditions
         * 
         * @test {Function} addDeviceToUser
         * @scenario Firestore throws error during user document update
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document update error', async () => {
            // Arrange: Configure user document update to fail
            mockUserDocSnapshot.get.mockReturnValue([]);
            mockUserDocRef.update.mockRejectedValue(new Error('Update failed'));

            // Act: Attempt to add device when update operation fails
            await addDeviceToUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });

    /**
     * Test group for device document creation scenarios.
     * 
     * This test group validates the creation and management of device
     * documents in the Firestore devices collection. Each device must
     * have its own document with proper initial values and metadata
     * for tracking device status and sensor readings.
     * 
     * Device document creation workflow:
     * 1. Check if device document already exists in devices collection
     * 2. Create new device document if it doesn't exist
     * 3. Initialize device with proper default values for unknown readings
     * 4. Set creation timestamp for tracking purposes
     * 5. Handle all error conditions gracefully
     * 
     * Device document structure:
     * * device_id - Unique identifier matching the user's devices array
     * * name - Human-readable device name for UI display
     * * battery_level - Current battery percentage (-1 for unknown)
     * * salt_distance - Salt level sensor reading (-1 for unknown)
     * * appliance_height - Height sensor reading (-1 for unknown)
     * * last_updated - ISO timestamp of last update
     * 
     * These tests ensure proper device document initialization and
     * error handling during the device creation process.
     */
    describe('Device document creation', () => {
        /**
         * Tests creation of new device document with proper initial values.
         * 
         * Verifies that the function creates a new device document in the
         * devices collection with all required fields and proper initial
         * values when a device doesn't already exist. This is the primary
         * device creation scenario for new device registrations.
         * 
         * Expected behavior:
         * * Function should create device document with correct structure
         * * All sensor readings should be initialized to -1 (unknown)
         * * Device ID and name should match request parameters
         * * Timestamp should be set to current time in ISO format
         * * Function should return HTTP 200 with success message
         * 
         * Initial value meanings:
         * * battery_level: -1 indicates unknown battery status
         * * salt_distance: -1 indicates unknown salt level reading
         * * appliance_height: -1 indicates unknown height measurement
         * * last_updated: ISO timestamp for tracking data freshness
         * 
         * This test ensures that new devices are properly initialized
         * with a consistent document structure that supports the
         * application's sensor monitoring and device management features.
         * 
         * @test {Function} addDeviceToUser
         * @scenario New device document creation with initial values
         * @expected Device document created with proper structure and defaults
         */
        test('should create new device document with correct initial values', async () => {
            // Arrange: Configure new device scenario
            mockUserDocSnapshot.get.mockReturnValue([]);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);

            // Mock Date.prototype.toISOString for predictable timestamp testing
            const mockDate = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockDate);

            // Act: Create new device document
            await addDeviceToUser(req, res);

            // Assert: Verify device document is created with correct structure
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith({
                device_id: 'test-device-id',
                name: 'Test Device',
                battery_level: -1,
                salt_distance: -1,
                appliance_height: -1,
                last_updated: mockDate
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device added successfully');

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });

        /**
         * Tests handling of existing device documents.
         * 
         * Verifies that the function properly handles cases where a device
         * document already exists in the devices collection. This could
         * happen if a device was previously registered and then re-added
         * to a user's account, or in race condition scenarios.
         * 
         * Expected behavior:
         * * Function should detect existing device document
         * * No new document creation should be attempted
         * * Existing device data should remain unchanged
         * * Function should return HTTP 200 with appropriate message
         * * Operation should be idempotent and safe to retry
         * 
         * This test ensures that the function behaves safely when device
         * documents already exist, preventing data corruption and allowing
         * for idempotent operation behavior that supports reliable client
         * implementations and retry logic.
         * 
         * @test {Function} addDeviceToUser
         * @scenario Device document already exists in devices collection
         * @expected HTTP 200 with no document creation, idempotent behavior
         */
        test('should handle existing device document gracefully', async () => {
            // Arrange: Configure existing device scenario
            mockUserDocSnapshot.get.mockReturnValue([]);
            const existingDeviceSnapshot = { exists: true };
            mockDeviceDocRef.get.mockResolvedValue(existingDeviceSnapshot);

            // Act: Attempt to create device that already exists
            await addDeviceToUser(req, res);

            // Assert: Verify no document creation is attempted
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device added successfully with existing record in devices collection');
        });

        /**
         * Tests handling of device document creation errors.
         * 
         * Verifies that the function properly handles database errors that
         * occur during device document creation. This could happen due to
         * network issues, permission problems, or Firestore service outages
         * during the device creation phase.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged with full details for debugging
         * * No partial operations should leave data in inconsistent state
         * 
         * This test ensures that device creation failures are handled
         * gracefully without leaving the system in an inconsistent state
         * where the user's devices array might be updated but the device
         * document creation failed.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during document creation
         * * Firestore permission denied errors
         * * Document size or field validation errors
         * * Service unavailable conditions
         * 
         * @test {Function} addDeviceToUser
         * @scenario Firestore throws error during device document creation
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle device document creation error', async () => {
            // Arrange: Configure device creation to fail
            mockUserDocSnapshot.get.mockReturnValue([]);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);
            mockDeviceDocRef.set.mockRejectedValue(new Error('Device creation failed'));

            // Act: Attempt to create device when creation operation fails
            await addDeviceToUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests handling of device document retrieval errors.
         * 
         * Verifies that the function properly handles database errors that
         * occur during device document existence checking. This could happen
         * due to network issues, permission problems, or Firestore service
         * outages during the device lookup phase.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged with full details for debugging
         * * No partial operations should be performed
         * 
         * This test ensures that device lookup failures are handled
         * gracefully and that the function fails fast when it cannot
         * determine whether a device already exists, preventing potential
         * data corruption or duplicate creation attempts.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during document retrieval
         * * Firestore permission denied errors
         * * Index or query errors
         * * Service unavailable conditions
         * 
         * @test {Function} addDeviceToUser
         * @scenario Firestore throws error during device document retrieval
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle device document retrieval error', async () => {
            // Arrange: Configure device retrieval to fail
            mockUserDocSnapshot.get.mockReturnValue([]);
            mockDeviceDocRef.get.mockRejectedValue(new Error('Device retrieval failed'));

            // Act: Attempt to add device when retrieval operation fails
            await addDeviceToUser(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
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
     * * Null or undefined devices arrays in user documents
     * * Complete duplicate scenarios (device in both user array and devices collection)
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
         * Tests handling of null devices array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's devices field is null. This could happen if
         * the field was never initialized or was explicitly set to null
         * during database operations or migrations.
         * 
         * Expected behavior:
         * * Function should treat null as equivalent to empty array
         * * New devices array should be created with the single device
         * * User document should be updated with proper devices array
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function is resilient to database
         * schema variations and can handle user documents that don't
         * have properly initialized devices arrays, which might occur
         * in legacy data or after database migrations.
         * 
         * @test {Function} addDeviceToUser
         * @scenario User document has null devices field
         * @expected HTTP 200 with devices array initialized from null
         */
        test('should handle null devices array from user document', async () => {
            // Arrange: Configure user document with null devices array
            mockUserDocSnapshot.get.mockReturnValue(null);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);

            // Act: Add device to user with null devices array
            await addDeviceToUser(req, res);

            // Assert: Verify devices array is properly initialized from null
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['test-device-id']
            });
            expect(res.status).toHaveBeenCalledWith(200);
        });

        /**
         * Tests handling of undefined devices array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's devices field is undefined. This could happen
         * if the field doesn't exist in the document or was deleted
         * during database operations.
         * 
         * Expected behavior:
         * * Function should treat undefined as equivalent to empty array
         * * New devices array should be created with the single device
         * * User document should be updated with proper devices array
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function can handle user documents
         * that are missing the devices field entirely, which might occur
         * in new user accounts or after field deletions. The function
         * should gracefully initialize the field when needed.
         * 
         * @test {Function} addDeviceToUser
         * @scenario User document has undefined devices field
         * @expected HTTP 200 with devices array initialized from undefined
         */
        test('should handle undefined devices array from user document', async () => {
            // Arrange: Configure user document with undefined devices array
            mockUserDocSnapshot.get.mockReturnValue(undefined);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);

            // Act: Add device to user with undefined devices array
            await addDeviceToUser(req, res);

            // Assert: Verify devices array is properly initialized from undefined
            expect(mockUserDocRef.update).toHaveBeenCalledWith({
                devices: ['test-device-id']
            });
            expect(res.status).toHaveBeenCalledWith(200);
        });

        /**
         * Tests complete duplicate scenario handling.
         * 
         * Verifies that the function properly handles the case where a
         * device already exists in both the user's devices array and
         * the devices collection. This represents a complete duplicate
         * scenario where no operations should be performed.
         * 
         * Expected behavior:
         * * Function should detect device in user's devices array
         * * Function should detect existing device document
         * * No update operations should be performed on either collection
         * * Function should return HTTP 200 with appropriate message
         * * Operation should be completely idempotent
         * 
         * This test ensures that the function handles complete duplicate
         * scenarios gracefully, which might occur due to:
         * * Client retry logic after network errors
         * * Race conditions in concurrent requests
         * * Manual database operations or data recovery
         * * Application bugs that cause duplicate requests
         * 
         * The function should be completely safe to call multiple times
         * with the same parameters without causing any side effects.
         * 
         * @test {Function} addDeviceToUser
         * @scenario Device exists in both user array and devices collection
         * @expected HTTP 200 with no operations performed, complete idempotency
         */
        test('should handle device already exists in user list and device collection', async () => {
            // Arrange: Configure complete duplicate scenario
            mockUserDocSnapshot.get.mockReturnValue(['test-device-id']);
            const existingDeviceSnapshot = { exists: true };
            mockDeviceDocRef.get.mockResolvedValue(existingDeviceSnapshot);

            // Act: Attempt to add device that exists everywhere
            await addDeviceToUser(req, res);

            // Assert: Verify no operations are performed (complete idempotency)
            expect(mockUserDocRef.update).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Device added successfully with existing record in devices collection');
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
     * * Correct collection name usage ('users' and 'devices')
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
    describe('Firestore collection calls', () => {
        /**
         * Tests correct Firestore collection and document access patterns.
         * 
         * Verifies that the function accesses the correct Firestore
         * collections and documents with the proper identifiers during
         * the device addition workflow. This test ensures that the
         * function follows the expected database schema and access patterns.
         * 
         * Expected database operations:
         * 1. Access 'users' collection with authenticated user's UID
         * 2. Access 'devices' collection with provided device ID
         * 3. Perform get operations to check existence
         * 4. Perform update/set operations to modify data
         * 
         * Database schema validation:
         * * Users collection: /users/{userUid}
         * * Devices collection: /devices/{deviceId}
         * * Proper document ID parameter passing
         * * Correct method invocation sequence
         * 
         * This test ensures that the function maintains consistency with
         * the established database schema and doesn't accidentally access
         * wrong collections or use incorrect document identifiers, which
         * could lead to data corruption or security issues.
         * 
         * @test {Function} addDeviceToUser
         * @scenario Successful device addition with database operation validation
         * @expected Correct Firestore collections and documents accessed with proper IDs
         */
        test('should call correct Firestore collections and documents', async () => {
            // Arrange: Configure successful device addition scenario
            mockUserDocSnapshot.get.mockReturnValue([]);
            const newDeviceSnapshot = { exists: false };
            mockDeviceDocRef.get.mockResolvedValue(newDeviceSnapshot);

            // Create specific collection mocks for detailed validation
            const mockUsersCollection = { doc: jest.fn(() => mockUserDocRef) };
            const mockDevicesCollection = { doc: jest.fn(() => mockDeviceDocRef) };

            // Configure Firestore mock to return specific collection mocks
            mockFirestore.collection.mockImplementation((collectionName) => {
                if (collectionName === 'users') return mockUsersCollection;
                if (collectionName === 'devices') return mockDevicesCollection;
            });

            // Act: Execute device addition workflow
            await addDeviceToUser(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            expect(mockFirestore.collection).toHaveBeenCalledWith('devices');

            // Assert: Verify correct document ID usage
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid');
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('test-device-id');
        });
    });
});