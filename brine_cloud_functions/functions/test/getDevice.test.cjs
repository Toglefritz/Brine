/**
 * @fileoverview Test suite for getDevice Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * getDevice Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and device data retrieval requirements.
 * 
 * The getDevice function handles the complete device information retrieval workflow:
 * 1. Validates required deviceId query parameter
 * 2. Extracts user UID from authenticated request context
 * 3. Verifies user document exists in Firestore
 * 4. Retrieves device document from devices collection
 * 5. Validates user has access to the requested device
 * 6. Returns device data in JSON format
 * 7. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * Device access control is critical for security, ensuring users can only access
 * devices they own. The function performs authorization checks by verifying that
 * the requested device ID exists in the user's devices array before returning
 * any device information.
 * 
 * Test Categories:
 * * Input validation - Tests deviceId query parameter validation
 * * User authentication - Tests user document existence and validation
 * * Device retrieval - Tests device document retrieval from Firestore
 * * Access control - Tests user authorization for device access
 * * Response formatting - Tests proper JSON response structure
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual data states
 * 
 * @author Firebase Functions Team
 * @since 2025-01-10
 * @version 1.0.0
 * @requires jest
 * @requires firebase-admin
 */
/**
 * M
ock Firestore document reference for user operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for user documents, including get operations that are used
 * during user validation and device access control.
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
 * during device information retrieval.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving device documents
 */
const mockDeviceDocRef = {
    get: jest.fn()
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate document references
 * for both users and devices collections.
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
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
const { getDevice } = require('../src/getDevice.cjs');

/**
 * Test suite for getDevice Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete device information retrieval
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles input validation,
 * user authentication, device retrieval, access control, and response formatting.
 */
describe('getDevice', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * @type {Object}
     * @property {Object} user - User authentication information from middleware
     * @property {string} user.uid - Firebase Auth user ID
     * @property {Object} query - HTTP query parameters
     * @property {string} query.deviceId - Device ID to retrieve
     */
    let req;

    /**
     * Mock Express response object for testing HTTP responses.
     * 
     * @type {Object}
     * @property {jest.Mock} status - Mock function for setting HTTP status codes
     * @property {jest.Mock} send - Mock function for sending response data
     * @property {jest.Mock} json - Mock function for sending JSON response data
     */
    let res;

    /**
     * Mock Firestore document snapshot for user documents.
     * 
     * @type {Object}
     * @property {boolean} exists - Whether the user document exists
     * @property {jest.Mock} get - Mock function for retrieving document field data
     */
    let mockUserDocSnapshot;

    /**
     * Mock Firestore document snapshot for device documents.
     * 
     * @type {Object}
     * @property {boolean} exists - Whether the device document exists
     * @property {jest.Mock} data - Mock function for retrieving document data
     */
    let mockDeviceDocSnapshot;

    /**
     * Set up test environment before each test execution.
     */
    beforeEach(() => {
        // Clear all mock function call history and reset implementations
        jest.clearAllMocks();

        req = {
            user: { uid: 'test-user-uid' },
            query: { deviceId: 'test-device-123' }
        };

        res = {
            status: jest.fn().mockReturnThis(),
            send: jest.fn(),
            json: jest.fn()
        };

        // Configure default user document snapshot
        mockUserDocSnapshot = {
            exists: true,
            get: jest.fn().mockReturnValue(['test-device-123', 'other-device'])
        };

        // Configure default device document snapshot
        mockDeviceDocSnapshot = {
            exists: true,
            data: jest.fn().mockReturnValue({
                device_id: 'test-device-123',
                name: 'Test Device',
                battery_level: 0.8,
                salt_distance: 500,
                appliance_height: 1200,
                last_updated: '2023-01-01T12:00:00Z'
            })
        };

        // Configure default resolved values
        mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
        mockDeviceDocRef.get.mockResolvedValue(mockDeviceDocSnapshot);
    });    /**
 
    * Test group for input validation scenarios.
     */
    describe('Input validation', () => {
        /**
         * Tests validation of missing deviceId parameter.
         */
        test('should return 400 if deviceId is missing', async () => {
            // Arrange: Remove deviceId from query
            req.query.deviceId = undefined;

            // Act: Call function with missing deviceId
            await getDevice(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID must be provided');
        });

        /**
         * Tests validation of empty deviceId parameter.
         */
        test('should return 400 if deviceId is empty string', async () => {
            // Arrange: Set deviceId to empty string
            req.query.deviceId = '';

            // Act: Call function with empty deviceId
            await getDevice(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID must be provided');
        });

        /**
         * Tests validation of null deviceId parameter.
         */
        test('should return 400 if deviceId is null', async () => {
            // Arrange: Set deviceId to null
            req.query.deviceId = null;

            // Act: Call function with null deviceId
            await getDevice(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID must be provided');
        });
    });

    /**
     * Test group for user authentication scenarios.
     */
    describe('User authentication', () => {
        /**
         * Tests handling of non-existent user documents.
         */
        test('should return 404 if user document does not exist', async () => {
            // Arrange: Configure user document to not exist
            mockUserDocSnapshot.exists = false;

            // Act: Attempt to get device for non-existent user
            await getDevice(req, res);

            // Assert: Verify proper not found response
            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.send).toHaveBeenCalledWith('User not found');
        });

        /**
         * Tests handling of user document retrieval errors.
         */
        test('should handle user document retrieval error', async () => {
            // Arrange: Configure user document retrieval to fail
            mockUserDocRef.get.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to get device when user retrieval fails
            await getDevice(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });    /*
*
     * Test group for device retrieval scenarios.
     */
    describe('Device retrieval', () => {
        /**
         * Tests successful device retrieval with valid access.
         */
        test('should return device data when user has access', async () => {
            // Act: Get device with valid access
            await getDevice(req, res);

            // Assert: Verify successful response with device data
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith({
                device_id: 'test-device-123',
                name: 'Test Device',
                battery_level: 0.8,
                salt_distance: 500,
                appliance_height: 1200,
                last_updated: '2023-01-01T12:00:00Z'
            });
        });

        /**
         * Tests handling of non-existent device documents.
         */
        test('should return 404 if device document does not exist', async () => {
            // Arrange: Configure device document to not exist
            mockDeviceDocSnapshot.exists = false;

            // Act: Attempt to get non-existent device
            await getDevice(req, res);

            // Assert: Verify proper not found response
            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.send).toHaveBeenCalledWith('Device not found');
        });

        /**
         * Tests handling of device document retrieval errors.
         */
        test('should handle device document retrieval error', async () => {
            // Arrange: Configure device document retrieval to fail
            mockDeviceDocRef.get.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to get device when retrieval fails
            await getDevice(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });
    });

    /**
     * Test group for access control scenarios.
     */
    describe('Access control', () => {
        /**
         * Tests access denial for unauthorized devices.
         */
        test('should return 403 if user does not have access to device', async () => {
            // Arrange: Configure user devices array without requested device
            mockUserDocSnapshot.get.mockReturnValue(['other-device-1', 'other-device-2']);

            // Act: Attempt to get device without access
            await getDevice(req, res);

            // Assert: Verify proper forbidden response
            expect(res.status).toHaveBeenCalledWith(403);
            expect(res.send).toHaveBeenCalledWith('User does not have access to the specified device');
        });

        /**
         * Tests access control with empty devices array.
         */
        test('should return 403 if user has no devices', async () => {
            // Arrange: Configure user with empty devices array
            mockUserDocSnapshot.get.mockReturnValue([]);

            // Act: Attempt to get device with no devices
            await getDevice(req, res);

            // Assert: Verify proper forbidden response
            expect(res.status).toHaveBeenCalledWith(403);
            expect(res.send).toHaveBeenCalledWith('User does not have access to the specified device');
        });
    });   
 /**
     * Test group for edge cases and boundary conditions.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of null devices array.
         */
        test('should handle null devices array from user document', async () => {
            // Arrange: Configure user document with null devices array
            mockUserDocSnapshot.get.mockReturnValue(null);

            // Act: Attempt to get device with null devices array
            await getDevice(req, res);

            // Assert: Verify proper error handling (should throw error due to null.includes())
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests handling of undefined devices array.
         */
        test('should handle undefined devices array from user document', async () => {
            // Arrange: Configure user document with undefined devices array
            mockUserDocSnapshot.get.mockReturnValue(undefined);

            // Act: Attempt to get device with undefined devices array
            await getDevice(req, res);

            // Assert: Verify proper error handling (should throw error due to undefined.includes())
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');
        });

        /**
         * Tests device retrieval with different valid device data.
         */
        test('should return different device data correctly', async () => {
            // Arrange: Configure different device data
            const differentDeviceData = {
                device_id: 'test-device-123',
                name: 'Different Device',
                battery_level: 0.3,
                salt_distance: 1000,
                appliance_height: 800,
                last_updated: '2023-06-15T08:30:00Z'
            };
            mockDeviceDocSnapshot.data.mockReturnValue(differentDeviceData);

            // Act: Get device with different data
            await getDevice(req, res);

            // Assert: Verify correct device data is returned
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith(differentDeviceData);
        });

        /**
         * Tests device access with long device ID.
         */
        test('should handle long device IDs', async () => {
            // Arrange: Configure long device ID
            const longDeviceId = 'very-long-device-id-that-exceeds-typical-length-123456789';
            req.query.deviceId = longDeviceId;
            mockUserDocSnapshot.get.mockReturnValue([longDeviceId, 'other-device']);
            
            const deviceData = {
                device_id: longDeviceId,
                name: 'Long ID Device',
                battery_level: 0.9,
                salt_distance: 300,
                appliance_height: 1500,
                last_updated: '2023-01-01T12:00:00Z'
            };
            mockDeviceDocSnapshot.data.mockReturnValue(deviceData);

            // Act: Get device with long ID
            await getDevice(req, res);

            // Assert: Verify successful response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith(deviceData);
        });
    });    /**

     * Test group for Firestore integration validation.
     */
    describe('Firestore integration', () => {
        /**
         * Tests correct Firestore collection and operation access patterns.
         */
        test('should call correct Firestore collections and operations', async () => {
            // Act: Execute device retrieval workflow
            await getDevice(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            expect(mockFirestore.collection).toHaveBeenCalledWith('devices');

            // Assert: Verify correct document operations
            expect(mockUserDocRef.get).toHaveBeenCalled();
            expect(mockDeviceDocRef.get).toHaveBeenCalled();
        });

        /**
         * Tests proper operation sequence for device retrieval.
         */
        test('should perform operations in correct sequence', async () => {
            // Act: Execute device retrieval workflow
            await getDevice(req, res);

            // Assert: Verify user document was retrieved first
            expect(mockUserDocRef.get).toHaveBeenCalled();
            
            // Assert: Verify device document was retrieved after user validation
            expect(mockDeviceDocRef.get).toHaveBeenCalled();
            
            // Assert: Verify operations were called in correct order
            const userGetCalls = mockUserDocRef.get.mock.invocationCallOrder;
            const deviceGetCalls = mockDeviceDocRef.get.mock.invocationCallOrder;
            expect(userGetCalls[0]).toBeLessThan(deviceGetCalls[0]);
        });

        /**
         * Tests correct document ID parameter passing.
         */
        test('should use correct document IDs for Firestore operations', async () => {
            // Arrange: Create specific collection mocks for detailed validation
            const mockUsersCollection = { doc: jest.fn(() => mockUserDocRef) };
            const mockDevicesCollection = { doc: jest.fn(() => mockDeviceDocRef) };

            mockFirestore.collection.mockImplementation((collectionName) => {
                if (collectionName === 'users') return mockUsersCollection;
                if (collectionName === 'devices') return mockDevicesCollection;
            });

            // Act: Execute device retrieval workflow
            await getDevice(req, res);

            // Assert: Verify correct document IDs were used
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid');
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('test-device-123');
        });
    });

    /**
     * Test group for response formatting validation.
     */
    describe('Response formatting', () => {
        /**
         * Tests proper JSON response structure for successful requests.
         */
        test('should return proper JSON structure for device data', async () => {
            // Act: Get device data
            await getDevice(req, res);

            // Assert: Verify JSON response was called
            expect(res.json).toHaveBeenCalled();
            
            // Assert: Verify response structure contains expected fields
            const responseData = res.json.mock.calls[0][0];
            expect(responseData).toHaveProperty('device_id');
            expect(responseData).toHaveProperty('name');
            expect(responseData).toHaveProperty('battery_level');
            expect(responseData).toHaveProperty('salt_distance');
            expect(responseData).toHaveProperty('appliance_height');
            expect(responseData).toHaveProperty('last_updated');
        });

        /**
         * Tests that device data is returned exactly as stored.
         */
        test('should return device data exactly as stored in Firestore', async () => {
            // Arrange: Configure specific device data
            const exactDeviceData = {
                device_id: 'test-device-123',
                name: 'Exact Test Device',
                battery_level: 0.75,
                salt_distance: 650,
                appliance_height: 1100,
                last_updated: '2023-03-15T14:22:33Z',
                custom_field: 'custom_value'
            };
            mockDeviceDocSnapshot.data.mockReturnValue(exactDeviceData);

            // Act: Get device data
            await getDevice(req, res);

            // Assert: Verify exact data is returned
            expect(res.json).toHaveBeenCalledWith(exactDeviceData);
        });
    });
});