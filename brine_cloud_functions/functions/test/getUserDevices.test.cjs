/**
 * @fileoverview Test suite for getUserDevices Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * getUserDevices Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and device list retrieval requirements.
 * 
 * The getUserDevices function handles the complete user device list retrieval workflow:
 * 1. Extracts user UID from authenticated request context
 * 2. Retrieves user document from Firestore users collection
 * 3. Validates user document exists and contains device list
 * 4. Iterates through user's device IDs to retrieve device details
 * 5. Fetches each device document from devices collection
 * 6. Filters out non-existent devices and returns valid device data
 * 7. Returns device list in structured JSON response format
 * 8. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * This function is critical for the mobile app's main interface, providing users
 * with a complete list of their registered devices including all device metadata
 * such as battery levels, sensor readings, and device status information.
 * 
 * Test Categories:
 * * User authentication - Tests user document existence and validation
 * * Device list retrieval - Tests user device array processing
 * * Device detail fetching - Tests individual device document retrieval
 * * Response formatting - Tests proper JSON response structure
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual data states
 * * Performance scenarios - Tests handling of multiple devices
 * * Data integrity - Tests filtering of non-existent devices
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Firestore collections - Mocked for users and devices collection access
 * * Document references - Mocked for get operations on user and device documents
 * * Authentication context - Mocked for user UID validation
 * 
 * Test Coverage:
 * * 100% code coverage for the getUserDevices function
 * * All execution paths including success and error scenarios
 * * User document validation and device array processing
 * * Device document retrieval and filtering logic
 * * Database operation success and failure conditions
 * * Response formatting and JSON structure validation
 * 
 * @author Firebase Functions Team
 * @since 2025-01-10
 * @version 1.0.0
 * @requires jest
 * @requires firebase-admin
 *//**
 
* Mock Firestore document reference for user operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for user documents, including get operations that are used
 * during user validation and device list retrieval.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving user documents
 */
const mockUserDocRef = {
    get: jest.fn()
};

/**
 * Mock Firestore document reference for device operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for device documents, including get operations that are used
 * during device detail retrieval for each device in user's list.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving device documents
 */
const mockDeviceDocRef = {
    get: jest.fn()
};

/**
 * Mock Firestore collection reference for users operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the users collection, including document reference creation
 * that is used during user document retrieval.
 * 
 * @type {Object}
 * @property {jest.Mock} doc - Mock function for getting user document references
 */
const mockUsersCollection = {
    doc: jest.fn(() => mockUserDocRef)
};

/**
 * Mock Firestore collection reference for devices operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the devices collection, including document reference creation
 * that is used during device document retrieval.
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
 * for both users and devices collections used in device list management.
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
const { getUserDevices } = require('../src/getUserDevices.cjs');/**
 * Tes
t suite for getUserDevices Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete user device list retrieval
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles user authentication,
 * device list processing, device detail retrieval, and response formatting.
 * 
 * Test Structure:
 * * User authentication - Tests user document existence and validation
 * * Device list retrieval - Tests processing of user's device array
 * * Device detail fetching - Tests individual device document retrieval
 * * Response formatting - Tests proper JSON response structure
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual data states
 * * Performance scenarios - Tests handling of multiple devices efficiently
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('getUserDevices', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * Simulates the Express.js request object that would be passed to the
     * getUserDevices function in a real HTTP request scenario. Contains
     * user authentication information from middleware.
     * 
     * @type {Object}
     * @property {Object} user - User authentication information from middleware
     * @property {string} user.uid - Firebase Auth user ID
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
     * 4. Setting up default device document responses
     * 
     * This approach ensures test isolation and prevents state leakage
     * between tests that could cause false positives or negatives.
     */
    beforeEach(() => {
        // Clear all mock function call history and reset implementations
        jest.clearAllMocks();

        /**
         * Configure mock HTTP request object with valid default authentication.
         * 
         * Sets up a typical successful request scenario with authenticated
         * user context. Individual tests can override these values to test
         * specific error conditions or edge cases.
         */
        req = {
            user: { uid: 'test-user-uid' }
        };

        /**
         * Configure mock HTTP response object with chainable methods.
         * 
         * The status method returns 'this' to enable method chaining
         * (res.status(200).send(data)), which matches Express.js behavior.
         */
        res = {
            status: jest.fn().mockReturnThis(),
            send: jest.fn()
        };

        /**
         * Configure default user document snapshot for successful scenarios.
         * 
         * Sets up a user document that exists and has a devices array with
         * sample device IDs, representing a typical user with registered devices.
         */
        mockUserDocSnapshot = {
            exists: true,
            get: jest.fn().mockReturnValue(['device-1', 'device-2'])
        };

        // Reset all Firestore mock function call history
        mockUserDocRef.get.mockClear();
        mockDeviceDocRef.get.mockClear();
        mockUsersCollection.doc.mockClear();
        mockDevicesCollection.doc.mockClear();

        // Configure all Firestore operations to resolve successfully by default
        mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
    });    /**

     * Test group for user authentication scenarios.
     * 
     * This test group validates the function's behavior when handling
     * user authentication and document existence. The function must
     * verify that the authenticated user exists in the database before
     * attempting to retrieve their device list.
     * 
     * User authentication scenarios:
     * * Non-existent user documents (404 Not Found)
     * * User document retrieval errors (500 Internal Server Error)
     * * Valid user authentication with existing documents
     * 
     * These tests ensure that only valid, existing users can retrieve
     * device lists and that authentication errors are handled gracefully.
     */
    describe('User authentication', () => {
        /**
         * Tests handling of non-existent user documents.
         * 
         * Verifies that the function properly handles cases where an
         * authenticated user does not have a corresponding document in
         * the Firestore users collection. This could happen if the user
         * document was deleted or if there's a synchronization issue.
         * 
         * Expected behavior:
         * * Function should return HTTP 404 (Not Found) status code
         * * Response message should clearly indicate user was not found
         * * No device operations should be attempted
         * * Error should be handled gracefully
         * 
         * @test {Function} getUserDevices
         * @scenario User document does not exist in Firestore
         * @expected HTTP 404 with "User not found" message
         */
        test('should return 404 if user document does not exist', async () => {
            // Arrange: Configure user document to not exist
            mockUserDocSnapshot.exists = false;

            // Act: Attempt to get devices for non-existent user
            await getUserDevices(req, res);

            // Assert: Verify proper not found response
            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.send).toHaveBeenCalledWith('User not found');
        });

        /**
         * Tests handling of user document retrieval errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during user document retrieval. This could happen
         * due to network issues, permission problems, or Firestore
         * service outages.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate internal server error
         * * Error should be logged for debugging purposes
         * * No partial operations should be performed
         * 
         * @test {Function} getUserDevices
         * @scenario Firestore throws error during user document retrieval
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle user document retrieval error', async () => {
            // Arrange: Configure user document retrieval to fail
            mockUserDocRef.get.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to get devices when user retrieval fails
            await getUserDevices(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });

    /**
     * Test group for device list retrieval scenarios.
     * 
     * This test group validates the core functionality of retrieving
     * and processing the user's device list. The function must properly
     * handle various device array states and retrieve device details
     * for each device in the user's list.
     * 
     * Device list scenarios tested:
     * * Empty device arrays (users with no devices)
     * * Single device arrays (users with one device)
     * * Multiple device arrays (users with several devices)
     * * Mixed scenarios (some devices exist, some don't)
     * 
     * These tests ensure proper device list processing and response
     * formatting for all possible user device configurations.
     */
    describe('Device list retrieval', () => {
        /**
         * Tests successful device list retrieval with multiple devices.
         * 
         * Verifies that the function properly retrieves device details
         * for multiple devices in a user's device array and returns
         * them in the correct JSON format.
         * 
         * Expected behavior:
         * * Function should iterate through all device IDs
         * * Each device document should be retrieved from Firestore
         * * Device data should be collected and returned in array
         * * Function should return HTTP 200 with devices array
         * 
         * @test {Function} getUserDevices
         * @scenario User has multiple devices in their device array
         * @expected HTTP 200 with array of device objects in JSON response
         */
        test('should return device list for user with multiple devices', async () => {
            // Arrange: Configure multiple device documents
            const device1Data = {
                device_id: 'device-1',
                name: 'Device One',
                battery_level: 0.8,
                salt_distance: 500
            };
            const device2Data = {
                device_id: 'device-2',
                name: 'Device Two',
                battery_level: 0.6,
                salt_distance: 300
            };

            const mockDevice1Snapshot = { exists: true, data: () => device1Data };
            const mockDevice2Snapshot = { exists: true, data: () => device2Data };

            mockDeviceDocRef.get
                .mockResolvedValueOnce(mockDevice1Snapshot)
                .mockResolvedValueOnce(mockDevice2Snapshot);

            // Act: Get devices for user with multiple devices
            await getUserDevices(req, res);

            // Assert: Verify successful response with device array
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({
                devices: [device1Data, device2Data]
            });
        });

        /**
         * Tests device list retrieval with empty device array.
         * 
         * Verifies that the function properly handles users who have
         * no devices registered to their account and returns an empty
         * devices array in the response.
         * 
         * Expected behavior:
         * * Function should handle empty device array gracefully
         * * No device document retrievals should be attempted
         * * Function should return HTTP 200 with empty devices array
         * * Response structure should remain consistent
         * 
         * @test {Function} getUserDevices
         * @scenario User has empty devices array
         * @expected HTTP 200 with empty devices array in JSON response
         */
        test('should return empty device list for user with no devices', async () => {
            // Arrange: Configure user with empty devices array
            mockUserDocSnapshot.get.mockReturnValue([]);

            // Act: Get devices for user with no devices
            await getUserDevices(req, res);

            // Assert: Verify successful response with empty array
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({ devices: [] });

            // Assert: Verify no device document retrievals were attempted
            expect(mockDeviceDocRef.get).not.toHaveBeenCalled();
        });

        /**
         * Tests device list retrieval with single device.
         * 
         * Verifies that the function properly handles users who have
         * exactly one device registered to their account and returns
         * the device data in the correct array format.
         * 
         * Expected behavior:
         * * Function should retrieve single device document
         * * Device data should be returned in array format
         * * Function should return HTTP 200 with single-item array
         * * Response structure should be consistent with multiple devices
         * 
         * @test {Function} getUserDevices
         * @scenario User has single device in their device array
         * @expected HTTP 200 with single device object in array
         */
        test('should return device list for user with single device', async () => {
            // Arrange: Configure user with single device
            mockUserDocSnapshot.get.mockReturnValue(['single-device']);
            
            const singleDeviceData = {
                device_id: 'single-device',
                name: 'Only Device',
                battery_level: 0.9,
                salt_distance: 400
            };

            const mockSingleDeviceSnapshot = { exists: true, data: () => singleDeviceData };
            mockDeviceDocRef.get.mockResolvedValue(mockSingleDeviceSnapshot);

            // Act: Get devices for user with single device
            await getUserDevices(req, res);

            // Assert: Verify successful response with single device array
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({
                devices: [singleDeviceData]
            });
        });
    });    /**

     * Test group for device detail fetching scenarios.
     * 
     * This test group validates the function's behavior when retrieving
     * individual device documents from the devices collection. The function
     * must handle cases where some devices exist and others don't, filtering
     * out non-existent devices from the final response.
     * 
     * Device fetching scenarios:
     * * All devices exist and are retrieved successfully
     * * Some devices don't exist and are filtered out
     * * Device document retrieval errors
     * * Mixed success and failure scenarios
     * 
     * These tests ensure robust device detail retrieval and proper
     * filtering of invalid or non-existent device references.
     */
    describe('Device detail fetching', () => {
        /**
         * Tests filtering of non-existent devices from response.
         * 
         * Verifies that the function properly handles cases where some
         * device IDs in the user's device array don't correspond to
         * existing device documents. Non-existent devices should be
         * filtered out of the response.
         * 
         * Expected behavior:
         * * Function should attempt to retrieve all device documents
         * * Non-existent devices should be filtered out
         * * Only existing devices should be included in response
         * * Function should return HTTP 200 with filtered device array
         * 
         * @test {Function} getUserDevices
         * @scenario Some devices in user array don't exist in devices collection
         * @expected HTTP 200 with only existing devices in response
         */
        test('should filter out non-existent devices', async () => {
            // Arrange: Configure mixed existing and non-existing devices
            mockUserDocSnapshot.get.mockReturnValue(['existing-device', 'non-existent-device']);
            
            const existingDeviceData = {
                device_id: 'existing-device',
                name: 'Existing Device',
                battery_level: 0.7
            };

            const mockExistingSnapshot = { exists: true, data: () => existingDeviceData };
            const mockNonExistentSnapshot = { exists: false };

            mockDeviceDocRef.get
                .mockResolvedValueOnce(mockExistingSnapshot)
                .mockResolvedValueOnce(mockNonExistentSnapshot);

            // Act: Get devices with mixed existence
            await getUserDevices(req, res);

            // Assert: Verify only existing device is returned
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({
                devices: [existingDeviceData]
            });
        });

        /**
         * Tests handling of device document retrieval errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during individual device document retrieval. The
         * function should continue processing other devices and handle
         * errors gracefully.
         * 
         * Expected behavior:
         * * Function should catch device retrieval errors
         * * Error should be logged for debugging purposes
         * * Function should return HTTP 500 Internal Server Error
         * * Processing should stop on first error
         * 
         * @test {Function} getUserDevices
         * @scenario Firestore throws error during device document retrieval
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle device document retrieval error', async () => {
            // Arrange: Configure device document retrieval to fail
            mockDeviceDocRef.get.mockRejectedValue(new Error('Device retrieval failed'));

            // Act: Attempt to get devices when device retrieval fails
            await getUserDevices(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests successful retrieval of all device documents.
         * 
         * Verifies that the function properly retrieves all device
         * documents when all devices in the user's array exist and
         * are accessible in the devices collection.
         * 
         * Expected behavior:
         * * Function should retrieve all device documents successfully
         * * All device data should be included in response
         * * Function should return HTTP 200 with complete device array
         * * Device data should be returned exactly as stored
         * 
         * @test {Function} getUserDevices
         * @scenario All devices in user array exist and are retrievable
         * @expected HTTP 200 with all device data in response
         */
        test('should retrieve all devices when all exist', async () => {
            // Arrange: Configure all devices to exist
            mockUserDocSnapshot.get.mockReturnValue(['device-a', 'device-b', 'device-c']);
            
            const deviceAData = { device_id: 'device-a', name: 'Device A', battery_level: 0.8 };
            const deviceBData = { device_id: 'device-b', name: 'Device B', battery_level: 0.6 };
            const deviceCData = { device_id: 'device-c', name: 'Device C', battery_level: 0.9 };

            const mockSnapshotA = { exists: true, data: () => deviceAData };
            const mockSnapshotB = { exists: true, data: () => deviceBData };
            const mockSnapshotC = { exists: true, data: () => deviceCData };

            mockDeviceDocRef.get
                .mockResolvedValueOnce(mockSnapshotA)
                .mockResolvedValueOnce(mockSnapshotB)
                .mockResolvedValueOnce(mockSnapshotC);

            // Act: Get all existing devices
            await getUserDevices(req, res);

            // Assert: Verify all devices are returned
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({
                devices: [deviceAData, deviceBData, deviceCData]
            });
        });
    });   
 /**
     * Test group for edge cases and boundary conditions.
     * 
     * This test group validates the function's behavior with unusual
     * data states and edge cases that might occur in production
     * environments. These scenarios test the robustness of the
     * function's data handling and error recovery.
     * 
     * Edge cases covered:
     * * Null devices arrays from user documents
     * * Undefined devices arrays from user documents
     * * Large numbers of devices (performance considerations)
     * * Various device data formats and structures
     * 
     * These tests ensure that the function handles real-world data
     * inconsistencies and edge cases gracefully.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of null devices array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's devices field is null. This could happen if
         * the field was never initialized or was explicitly set to null.
         * 
         * Expected behavior:
         * * Function should handle null devices array gracefully
         * * Function should return HTTP 500 due to iteration error
         * * Error should be caught and handled appropriately
         * 
         * @test {Function} getUserDevices
         * @scenario User document has null devices field
         * @expected HTTP 500 due to null iteration error
         */
        test('should handle null devices array from user document', async () => {
            // Arrange: Configure user document with null devices array
            mockUserDocSnapshot.get.mockReturnValue(null);

            // Act: Attempt to get devices with null array
            await getUserDevices(req, res);

            // Assert: Verify error handling (null cannot be iterated)
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests handling of undefined devices array from user document.
         * 
         * Verifies that the function properly handles cases where the
         * user document's devices field is undefined. This could happen
         * if the field doesn't exist in the document.
         * 
         * Expected behavior:
         * * Function should handle undefined devices array gracefully
         * * Function should return HTTP 500 due to iteration error
         * * Error should be caught and handled appropriately
         * 
         * @test {Function} getUserDevices
         * @scenario User document has undefined devices field
         * @expected HTTP 500 due to undefined iteration error
         */
        test('should handle undefined devices array from user document', async () => {
            // Arrange: Configure user document with undefined devices array
            mockUserDocSnapshot.get.mockReturnValue(undefined);

            // Act: Attempt to get devices with undefined array
            await getUserDevices(req, res);

            // Assert: Verify error handling (undefined cannot be iterated)
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests handling of large device arrays.
         * 
         * Verifies that the function can handle users with many devices
         * without performance issues or errors. This tests the scalability
         * of the device retrieval logic.
         * 
         * Expected behavior:
         * * Function should handle large device arrays efficiently
         * * All devices should be processed and returned
         * * Function should return HTTP 200 with all device data
         * * No performance degradation should occur
         * 
         * @test {Function} getUserDevices
         * @scenario User has many devices in their device array
         * @expected HTTP 200 with all devices processed successfully
         */
        test('should handle large number of devices', async () => {
            // Arrange: Configure user with many devices
            const manyDeviceIds = Array.from({ length: 10 }, (_, i) => `device-${i}`);
            mockUserDocSnapshot.get.mockReturnValue(manyDeviceIds);

            // Configure all devices to exist
            const deviceDataArray = manyDeviceIds.map(id => ({
                device_id: id,
                name: `Device ${id}`,
                battery_level: Math.random()
            }));

            // Mock device document retrieval for all devices
            deviceDataArray.forEach(deviceData => {
                mockDeviceDocRef.get.mockResolvedValueOnce({
                    exists: true,
                    data: () => deviceData
                });
            });

            // Act: Get devices for user with many devices
            await getUserDevices(req, res);

            // Assert: Verify all devices are returned
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({
                devices: deviceDataArray
            });

            // Assert: Verify all device documents were retrieved
            expect(mockDeviceDocRef.get).toHaveBeenCalledTimes(10);
        });

        /**
         * Tests device data with various field structures.
         * 
         * Verifies that the function properly handles device documents
         * with different field structures and data types, ensuring
         * that device data is returned exactly as stored.
         * 
         * Expected behavior:
         * * Function should return device data exactly as stored
         * * Various field types and structures should be preserved
         * * Function should return HTTP 200 with original data
         * * No data transformation should occur
         * 
         * @test {Function} getUserDevices
         * @scenario Devices have various field structures and data types
         * @expected HTTP 200 with original device data preserved
         */
        test('should handle devices with various field structures', async () => {
            // Arrange: Configure devices with different field structures
            mockUserDocSnapshot.get.mockReturnValue(['complex-device']);
            
            const complexDeviceData = {
                device_id: 'complex-device',
                name: 'Complex Device',
                battery_level: 0.75,
                salt_distance: 600,
                appliance_height: 1200,
                last_updated: '2023-01-01T12:00:00Z',
                psk: 'abc123def456',
                psk_created_at: '2023-01-01T10:00:00Z',
                psk_valid: true,
                custom_field: 'custom_value',
                nested_object: {
                    sub_field: 'sub_value',
                    sub_number: 42
                }
            };

            const mockComplexSnapshot = { exists: true, data: () => complexDeviceData };
            mockDeviceDocRef.get.mockResolvedValue(mockComplexSnapshot);

            // Act: Get device with complex structure
            await getUserDevices(req, res);

            // Assert: Verify complex device data is returned exactly
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith({
                devices: [complexDeviceData]
            });
        });
    });    /*
*
     * Test group for Firestore integration and database operation validation.
     * 
     * This test group validates that the function makes the correct calls
     * to Firestore collections and operations with proper parameters. These
     * tests ensure that the function interacts with the database using the
     * expected collection names and operation sequences.
     * 
     * Database operations validated:
     * * Correct collection name usage ('users' and 'devices')
     * * Proper document ID parameter passing
     * * Expected sequence of database operations
     * * Correct method calls on document references
     * 
     * These tests serve as integration tests that verify the function's
     * database interaction patterns without requiring actual Firestore
     * connections.
     */
    describe('Firestore integration', () => {
        /**
         * Tests correct Firestore collection and operation access patterns.
         * 
         * Verifies that the function accesses the correct Firestore
         * collections and performs the expected operations during
         * the device list retrieval workflow.
         * 
         * Expected database operations:
         * 1. Access 'users' collection with user UID
         * 2. Access 'devices' collection for each device ID
         * 3. Perform get operations on all document references
         * 
         * @test {Function} getUserDevices
         * @scenario Successful device list retrieval with database validation
         * @expected Correct Firestore collections accessed with proper operations
         */
        test('should call correct Firestore collections and operations', async () => {
            // Arrange: Configure successful device retrieval scenario
            const deviceData = { device_id: 'device-1', name: 'Test Device' };
            const mockDeviceSnapshot = { exists: true, data: () => deviceData };
            mockDeviceDocRef.get.mockResolvedValue(mockDeviceSnapshot);

            // Act: Execute device list retrieval workflow
            await getUserDevices(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            expect(mockFirestore.collection).toHaveBeenCalledWith('devices');

            // Assert: Verify correct document operations
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid');
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('device-1');
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('device-2');

            // Assert: Verify get operations were called
            expect(mockUserDocRef.get).toHaveBeenCalled();
            expect(mockDeviceDocRef.get).toHaveBeenCalledTimes(2);
        });

        /**
         * Tests proper operation sequence for device list retrieval.
         * 
         * Verifies that the function performs database operations in the
         * correct sequence: first retrieving user document, then iterating
         * through device IDs to retrieve device documents.
         * 
         * Expected operation sequence:
         * 1. Get user document to retrieve device list
         * 2. Iterate through device IDs
         * 3. Get each device document individually
         * 
         * @test {Function} getUserDevices
         * @scenario Device list retrieval with operation sequence validation
         * @expected Operations performed in correct sequence
         */
        test('should perform operations in correct sequence', async () => {
            // Arrange: Configure device retrieval scenario
            const deviceData = { device_id: 'device-1', name: 'Test Device' };
            const mockDeviceSnapshot = { exists: true, data: () => deviceData };
            mockDeviceDocRef.get.mockResolvedValue(mockDeviceSnapshot);

            // Act: Execute device list retrieval workflow
            await getUserDevices(req, res);

            // Assert: Verify user document was retrieved first
            expect(mockUserDocRef.get).toHaveBeenCalled();
            
            // Assert: Verify device documents were retrieved after user validation
            expect(mockDeviceDocRef.get).toHaveBeenCalled();
            
            // Assert: Verify operations were called in correct order
            const userGetCalls = mockUserDocRef.get.mock.invocationCallOrder;
            const deviceGetCalls = mockDeviceDocRef.get.mock.invocationCallOrder;
            expect(userGetCalls[0]).toBeLessThan(deviceGetCalls[0]);
        });
    });

    /**
     * Test group for response formatting validation.
     * 
     * This test group validates that the function returns responses in
     * the correct JSON format with proper structure and data organization.
     * The response format is critical for mobile app integration.
     * 
     * Response format requirements:
     * * Response must contain 'devices' field with array value
     * * Device objects must be returned exactly as stored
     * * Response structure must be consistent across all scenarios
     * * HTTP status codes must be appropriate for each scenario
     */
    describe('Response formatting', () => {
        /**
         * Tests proper JSON response structure for successful requests.
         * 
         * Verifies that the function returns device data in the correct
         * JSON structure with the 'devices' field containing an array
         * of device objects.
         * 
         * Expected response structure:
         * {
         *   "devices": [
         *     { device_id: "...", name: "...", ... },
         *     { device_id: "...", name: "...", ... }
         *   ]
         * }
         * 
         * @test {Function} getUserDevices
         * @scenario Successful device retrieval with response format validation
         * @expected Proper JSON structure with devices array
         */
        test('should return proper JSON structure for device list', async () => {
            // Arrange: Configure device data
            const deviceData = {
                device_id: 'test-device',
                name: 'Test Device',
                battery_level: 0.8
            };
            const mockDeviceSnapshot = { exists: true, data: () => deviceData };
            mockUserDocSnapshot.get.mockReturnValue(['test-device']);
            mockDeviceDocRef.get.mockResolvedValue(mockDeviceSnapshot);

            // Act: Get device list
            await getUserDevices(req, res);

            // Assert: Verify response structure
            expect(res.send).toHaveBeenCalled();
            const responseData = res.send.mock.calls[0][0];
            expect(responseData).toHaveProperty('devices');
            expect(Array.isArray(responseData.devices)).toBe(true);
            expect(responseData.devices).toHaveLength(1);
            expect(responseData.devices[0]).toEqual(deviceData);
        });

        /**
         * Tests consistent response structure for empty device lists.
         * 
         * Verifies that the function maintains consistent response
         * structure even when users have no devices, returning an
         * empty array in the devices field.
         * 
         * Expected response structure:
         * {
         *   "devices": []
         * }
         * 
         * @test {Function} getUserDevices
         * @scenario Empty device list with response format validation
         * @expected Consistent JSON structure with empty devices array
         */
        test('should return consistent structure for empty device list', async () => {
            // Arrange: Configure user with no devices
            mockUserDocSnapshot.get.mockReturnValue([]);

            // Act: Get empty device list
            await getUserDevices(req, res);

            // Assert: Verify consistent response structure
            expect(res.send).toHaveBeenCalled();
            const responseData = res.send.mock.calls[0][0];
            expect(responseData).toHaveProperty('devices');
            expect(Array.isArray(responseData.devices)).toBe(true);
            expect(responseData.devices).toHaveLength(0);
        });
    });
});