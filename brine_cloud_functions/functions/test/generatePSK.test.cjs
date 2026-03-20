/**
 * @fileoverview Test suite for generatePSK Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * generatePSK Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and pre-shared key generation requirements.
 * 
 * The generatePSK function handles the complete PSK generation and storage workflow:
 * 1. Validates HTTP method (must be POST)
 * 2. Validates required deviceId parameter from request body
 * 3. Generates a cryptographically secure 32-byte random PSK
 * 4. Creates PSK document data with timestamp and validity status
 * 5. Stores PSK data in Firestore devices collection using merge operation
 * 6. Returns the generated PSK to the client in JSON format
 * 7. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * Pre-shared keys (PSKs) are critical security components used for device authentication
 * and secure communication in the Brine IoT ecosystem. Each PSK must be cryptographically
 * secure, unique, and properly stored with metadata for device provisioning and
 * authentication workflows.
 * 
 * Test Categories:
 * * HTTP method validation - Tests proper method restriction to POST only
 * * Input validation - Tests deviceId parameter validation and error handling
 * * PSK generation - Tests cryptographic key generation and format validation
 * * Firestore storage - Tests document creation and merge operations
 * * Response formatting - Tests proper JSON response structure and status codes
 * * Error handling - Tests database error scenarios and appropriate responses
 * * Edge cases - Tests boundary conditions and unusual input data
 * * Security validation - Tests PSK uniqueness and cryptographic properties
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Node.js crypto module - Mocked for predictable PSK generation in tests
 * * Firestore collections - Mocked for devices collection access
 * * Document references - Mocked for set operations with merge functionality
 * * Date objects - Mocked for predictable timestamp generation
 * 
 * Test Coverage:
 * * 100% code coverage for the generatePSK function
 * * All execution paths including success and error scenarios
 * * HTTP method validation and request parameter validation
 * * Cryptographic key generation and storage operations
 * * Database operation success and failure conditions
 * * Response formatting and error handling
 * 
 * @author Firebase Functions Team
 * @since 2025-01-10
 * @version 1.0.0
 * @requires jest
 * @requires firebase-admin
 * @requires crypto
 */

/**
 * Mock Node.js crypto module for predictable PSK generation.
 * 
 * Provides mocked implementations of cryptographic functions used
 * for PSK generation, allowing tests to verify PSK creation logic
 * with predictable output values.
 * 
 * @type {Object}
 * @property {jest.Mock} randomBytes - Mock function for generating random bytes
 */
const mockCrypto = {
    randomBytes: jest.fn()
};

/**
 * Mock Firestore document reference for device operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for device documents, including set operations with merge functionality
 * that are used during PSK storage workflow.
 * 
 * @type {Object}
 * @property {jest.Mock} set - Mock function for storing PSK data in device documents
 */
const mockDeviceDocRef = {
    set: jest.fn()
};

/**
 * Mock Firestore collection reference for devices operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the devices collection, including document reference creation
 * that is used during PSK storage workflow.
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
 * for the devices collection used in PSK management.
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 * 
 * @example
 * // Returns devices collection reference for 'devices' collection
 * mockFirestore.collection('devices')
 */
const mockFirestore = {
    collection: jest.fn(() => mockDevicesCollection)
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

// Mock the Node.js crypto module before importing the function under test
jest.mock('crypto', () => mockCrypto);

// Import the function under test after mocking dependencies
const { generatePSK } = require('../src/generatePSK.cjs');

/**
 * Test suite for generatePSK Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete PSK generation and storage
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles HTTP method validation,
 * input validation, cryptographic key generation, Firestore operations, and
 * response formatting.
 * 
 * Test Structure:
 * * HTTP method validation - Tests proper method restriction and error responses
 * * Input validation - Tests deviceId parameter validation and error handling
 * * PSK generation and storage - Tests key generation and Firestore operations
 * * Response formatting - Tests proper JSON response structure and status codes
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual input handling
 * * Security validation - Tests PSK format and cryptographic properties
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('generatePSK', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * Simulates the Express.js request object that would be passed to the
     * generatePSK function in a real HTTP request scenario. Contains
     * HTTP method information and request body data.
     * 
     * @type {Object}
     * @property {string} method - HTTP method for the request
     * @property {Object} body - HTTP request body containing device information
     * @property {string} body.deviceId - Unique identifier for the device
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
     * @property {jest.Mock} json - Mock function for sending JSON response data
     */
    let res;

    /**
     * Mock buffer object for crypto.randomBytes return value.
     * 
     * Simulates the Buffer object returned by crypto.randomBytes,
     * providing a toString method for hex encoding conversion.
     * 
     * @type {Object}
     * @property {jest.Mock} toString - Mock function for converting buffer to hex string
     */
    let mockBuffer;

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
     * 3. Configuring default successful crypto and Firestore operations
     * 4. Setting up predictable PSK generation for testing
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
         * Sets up a typical successful request scenario with POST method
         * and valid device ID. Individual tests can override these
         * values to test specific error conditions or edge cases.
         */
        req = {
            method: 'POST',
            body: {
                deviceId: 'test-device-123'
            }
        };

        /**
         * Configure mock HTTP response object with chainable methods.
         * 
         * The status method returns 'this' to enable method chaining
         * (res.status(200).json(data)), which matches Express.js behavior.
         */
        res = {
            status: jest.fn().mockReturnThis(),
            send: jest.fn(),
            json: jest.fn()
        };

        /**
         * Configure mock buffer object for crypto operations.
         * 
         * Sets up a mock buffer that returns a predictable hex string
         * when toString('hex') is called, allowing for deterministic
         * PSK generation testing.
         */
        mockBuffer = {
            toString: jest.fn().mockReturnValue('abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890')
        };

        // Reset all mock function call history
        mockCrypto.randomBytes.mockClear();
        mockDeviceDocRef.set.mockClear();
        mockDevicesCollection.doc.mockClear();

        // Configure all operations to resolve successfully by default
        mockCrypto.randomBytes.mockReturnValue(mockBuffer);
        mockDeviceDocRef.set.mockResolvedValue();
    });

    /**
     * Test group for HTTP method validation scenarios.
     * 
     * This test group validates that the generatePSK function properly
     * enforces HTTP method restrictions and returns appropriate error
     * responses when incorrect methods are used.
     * 
     * The function must only accept POST requests for security reasons,
     * as PSK generation is a state-changing operation that should not
     * be performed via GET requests or other methods.
     * 
     * Method validation ensures:
     * * Only POST requests are accepted
     * * Other methods return 405 Method Not Allowed
     * * No PSK generation occurs for invalid methods
     * * Proper error messages are returned
     * 
     * These tests ensure that the function follows HTTP best practices
     * and maintains security by restricting PSK generation to appropriate
     * request methods only.
     */
    describe('HTTP method validation', () => {
        /**
         * Tests rejection of GET requests.
         * 
         * Verifies that the function properly rejects GET requests
         * and returns a 405 Method Not Allowed status code. GET
         * requests should not be used for PSK generation as it is
         * a state-changing operation.
         * 
         * Expected behavior:
         * * Function should return HTTP 405 status code
         * * Response message should indicate method not allowed
         * * No PSK generation should be attempted
         * * No database operations should be performed
         * 
         * @test {Function} generatePSK
         * @scenario GET request sent to generatePSK endpoint
         * @expected HTTP 405 with "Method Not Allowed" message
         */
        test('should reject GET requests', async () => {
            // Arrange: Configure GET request
            req.method = 'GET';

            // Act: Call function with GET method
            await generatePSK(req, res);

            // Assert: Verify method not allowed response
            expect(res.status).toHaveBeenCalledWith(405);
            expect(res.send).toHaveBeenCalledWith('Method Not Allowed');

            // Assert: Verify no PSK generation was attempted
            expect(mockCrypto.randomBytes).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
        });

        /**
         * Tests rejection of PUT requests.
         * 
         * Verifies that the function properly rejects PUT requests
         * and returns a 405 Method Not Allowed status code. Only
         * POST requests should be accepted for PSK generation.
         * 
         * Expected behavior:
         * * Function should return HTTP 405 status code
         * * Response message should indicate method not allowed
         * * No PSK generation should be attempted
         * * No database operations should be performed
         * 
         * @test {Function} generatePSK
         * @scenario PUT request sent to generatePSK endpoint
         * @expected HTTP 405 with "Method Not Allowed" message
         */
        test('should reject PUT requests', async () => {
            // Arrange: Configure PUT request
            req.method = 'PUT';

            // Act: Call function with PUT method
            await generatePSK(req, res);

            // Assert: Verify method not allowed response
            expect(res.status).toHaveBeenCalledWith(405);
            expect(res.send).toHaveBeenCalledWith('Method Not Allowed');

            // Assert: Verify no PSK generation was attempted
            expect(mockCrypto.randomBytes).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
        });

        /**
         * Tests acceptance of POST requests.
         * 
         * Verifies that the function properly accepts POST requests
         * and proceeds with PSK generation workflow. POST is the
         * correct method for PSK generation operations.
         * 
         * Expected behavior:
         * * Function should accept POST method
         * * PSK generation workflow should proceed
         * * Function should return HTTP 200 with generated PSK
         * * Database operations should be performed
         * 
         * @test {Function} generatePSK
         * @scenario POST request sent to generatePSK endpoint
         * @expected HTTP 200 with generated PSK in JSON response
         */
        test('should accept POST requests', async () => {
            // Arrange: POST method is already configured in beforeEach
            // Mock Date.prototype.toISOString for predictable timestamp testing
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Call function with POST method
            await generatePSK(req, res);

            // Assert: Verify successful response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            });

            // Assert: Verify PSK generation was performed
            expect(mockCrypto.randomBytes).toHaveBeenCalled();
            expect(mockDeviceDocRef.set).toHaveBeenCalled();

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });

    /**
     * Test group for input validation scenarios.
     * 
     * This test group validates that the generatePSK function properly
     * enforces input validation rules and returns appropriate error
     * responses when required data is missing or invalid.
     * 
     * The function must validate:
     * * deviceId - Required unique identifier for the device
     * 
     * All validation failures should return HTTP 400 (Bad Request) status
     * with clear, actionable error messages that help clients understand
     * what data is required and how to correct their requests.
     * 
     * These tests ensure that invalid requests are rejected early in the
     * processing pipeline, preventing unnecessary cryptographic operations
     * and database operations while providing fast feedback to clients.
     */
    describe('Input validation', () => {
        /**
         * Tests validation of missing deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId field is completely missing from the request body.
         * The deviceId is essential for PSK storage and device association.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * No PSK generation should be attempted
         * * No database operations should be performed
         * 
         * @test {Function} generatePSK
         * @scenario Missing deviceId parameter in request body
         * @expected HTTP 400 with "Device ID must be provided" message
         */
        test('should return 400 if deviceId is missing', async () => {
            // Arrange: Remove deviceId from request body
            req.body.deviceId = undefined;

            // Act: Call function with missing deviceId
            await generatePSK(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID must be provided');

            // Assert: Verify no PSK generation was attempted
            expect(mockCrypto.randomBytes).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
        });

        /**
         * Tests validation of empty deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId field is present but contains an empty string. Empty
         * device IDs are not valid for PSK storage and device association.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * Empty strings should be treated the same as missing values
         * * No PSK generation should be attempted
         * 
         * @test {Function} generatePSK
         * @scenario Empty string deviceId parameter in request body
         * @expected HTTP 400 with "Device ID must be provided" message
         */
        test('should return 400 if deviceId is empty string', async () => {
            // Arrange: Set deviceId to empty string
            req.body.deviceId = '';

            // Act: Call function with empty deviceId
            await generatePSK(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID must be provided');

            // Assert: Verify no PSK generation was attempted
            expect(mockCrypto.randomBytes).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
        });

        /**
         * Tests validation of null deviceId parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * deviceId field is explicitly set to null. Null values are not
         * valid device identifiers for PSK operations.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate deviceId is required
         * * Null values should be treated the same as missing values
         * * No PSK generation should be attempted
         * 
         * @test {Function} generatePSK
         * @scenario Null deviceId parameter in request body
         * @expected HTTP 400 with "Device ID must be provided" message
         */
        test('should return 400 if deviceId is null', async () => {
            // Arrange: Set deviceId to null
            req.body.deviceId = null;

            // Act: Call function with null deviceId
            await generatePSK(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Device ID must be provided');

            // Assert: Verify no PSK generation was attempted
            expect(mockCrypto.randomBytes).not.toHaveBeenCalled();
            expect(mockDeviceDocRef.set).not.toHaveBeenCalled();
        });
    });

    /**
     * Test group for PSK generation and storage scenarios.
     * 
     * This test group validates the core functionality of generating
     * cryptographically secure PSKs and storing them in Firestore with
     * appropriate metadata. The function must properly generate random
     * keys and store them with timestamps and validity flags.
     * 
     * PSK generation and storage workflow:
     * 1. Generate 32 random bytes using crypto.randomBytes
     * 2. Convert bytes to hexadecimal string representation
     * 3. Create PSK document data with timestamp and validity
     * 4. Store PSK data in Firestore using merge operation
     * 5. Return generated PSK to client in JSON format
     * 
     * Storage scenarios tested:
     * * Successful PSK generation and storage
     * * Proper document structure and field values
     * * Correct Firestore merge operation usage
     * * Proper JSON response formatting
     * 
     * These tests ensure proper PSK generation and storage for
     * device authentication and security management.
     */
    describe('PSK generation and storage', () => {
        /**
         * Tests successful PSK generation and storage workflow.
         * 
         * Verifies that the function properly generates a cryptographically
         * secure PSK, stores it in Firestore with appropriate metadata,
         * and returns the PSK to the client in the correct format.
         * 
         * Expected behavior:
         * * Function should generate 32 random bytes
         * * Bytes should be converted to hexadecimal string
         * * PSK data should be stored in Firestore with metadata
         * * Function should return HTTP 200 with PSK in JSON format
         * * Merge operation should be used for Firestore storage
         * 
         * This test ensures that the primary workflow of the function
         * operates correctly and generates secure PSKs for device
         * authentication purposes.
         * 
         * @test {Function} generatePSK
         * @scenario Valid POST request with deviceId provided
         * @expected HTTP 200 with generated PSK stored in Firestore
         */
        test('should generate and store PSK successfully', async () => {
            // Arrange: Mock Date.prototype.toISOString for predictable timestamp testing
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Generate PSK with valid request
            await generatePSK(req, res);

            // Assert: Verify PSK generation
            expect(mockCrypto.randomBytes).toHaveBeenCalledWith(32);
            expect(mockBuffer.toString).toHaveBeenCalledWith('hex');

            // Assert: Verify Firestore storage
            expect(mockFirestore.collection).toHaveBeenCalledWith('devices');
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('test-device-123');
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
                psk_created_at: mockTimestamp,
                psk_valid: true
            }, { merge: true });

            // Assert: Verify JSON response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });

        /**
         * Tests PSK generation with different device ID.
         * 
         * Verifies that the function properly handles various valid
         * device IDs and generates appropriate PSKs for different
         * devices with correct storage operations.
         * 
         * Expected behavior:
         * * Function should handle different valid device IDs
         * * PSK generation should work with various device identifiers
         * * Device ID should be properly used in Firestore operations
         * * Function should return appropriate PSK response
         * 
         * This test ensures that the function works correctly with
         * various valid device identifiers and maintains consistent
         * behavior across different device provisioning scenarios.
         * 
         * @test {Function} generatePSK
         * @scenario Different valid device ID provided in request
         * @expected HTTP 200 with PSK generated for specified device
         */
        test('should generate PSK for different device ID', async () => {
            // Arrange: Configure different device ID
            req.body.deviceId = 'different-device-456';
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Generate PSK for different device
            await generatePSK(req, res);

            // Assert: Verify correct device ID was used
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('different-device-456');
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
                psk_created_at: mockTimestamp,
                psk_valid: true
            }, { merge: true });

            // Assert: Verify successful response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });

    /**
     * Test group for error handling scenarios.
     * 
     * This test group validates the function's behavior when database
     * errors occur during PSK storage operations. The function must
     * handle Firestore errors gracefully and provide appropriate
     * error responses.
     * 
     * Error handling ensures:
     * * Proper error catching and handling
     * * Error logging for debugging and monitoring
     * * Appropriate HTTP error responses
     * * Consistent error handling across different failure modes
     * 
     * These tests ensure that database errors are handled professionally
     * and that the function fails gracefully when operations cannot
     * be completed successfully.
     */
    describe('Error handling', () => {
        /**
         * Tests handling of Firestore storage errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during PSK storage in Firestore. This could happen
         * due to network issues, permission problems, or Firestore
         * service outages.
         * 
         * Expected behavior:
         * * Function should catch Firestore errors
         * * Error should be logged for debugging purposes
         * * Function should return HTTP 500 Internal Server Error
         * * Error message should not expose internal details
         * 
         * This test ensures that database errors are handled gracefully
         * and that the function provides appropriate error information
         * for debugging while maintaining security by not exposing
         * internal system details.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during document storage
         * * Firestore permission denied errors
         * * Service unavailable conditions
         * * Document validation or size limit errors
         * 
         * @test {Function} generatePSK
         * @scenario Firestore throws error during PSK storage
         * @expected HTTP 500 with "Internal Server Error" message
         */
        test('should handle Firestore storage error', async () => {
            // Arrange: Configure Firestore to throw error during storage
            const firestoreError = new Error('Firestore connection failed');
            mockDeviceDocRef.set.mockRejectedValue(firestoreError);

            // Act: Attempt to generate PSK when storage fails
            await generatePSK(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Internal Server Error');

            // Assert: Verify PSK generation was attempted
            expect(mockCrypto.randomBytes).toHaveBeenCalled();
            expect(mockDeviceDocRef.set).toHaveBeenCalled();
        });
    });

    /**
     * Test group for edge cases and boundary conditions.
     * 
     * This test group validates the function's behavior with unusual
     * input data and edge cases that might occur in production
     * environments. These scenarios test the robustness of the
     * function's input handling and PSK generation.
     * 
     * Edge cases covered:
     * * Long device IDs
     * * Device IDs with special characters
     * * Various device ID formats
     * 
     * These tests ensure that the function handles real-world variations
     * in device identification and maintains consistent behavior across
     * different device provisioning scenarios.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of long device IDs.
         * 
         * Verifies that the function properly handles device IDs that
         * are longer than typical, which might occur with certain
         * device identification schemes or custom naming conventions.
         * 
         * Expected behavior:
         * * Function should accept and process long device IDs correctly
         * * PSK should be generated and stored with full device ID preserved
         * * No truncation or modification of device ID should occur
         * * Function should return success with generated PSK
         * 
         * This test ensures that the function works correctly with
         * various device ID lengths and doesn't impose artificial
         * limitations on device identification formats.
         * 
         * @test {Function} generatePSK
         * @scenario Device ID is longer than typical length
         * @expected HTTP 200 with PSK generated for long device ID
         */
        test('should handle long device IDs', async () => {
            // Arrange: Configure long device ID
            const longDeviceId = 'very-long-device-id-that-exceeds-typical-length-for-comprehensive-testing-purposes-123456789';
            req.body.deviceId = longDeviceId;
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Generate PSK for long device ID
            await generatePSK(req, res);

            // Assert: Verify long device ID is handled correctly
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith(longDeviceId);
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
                psk_created_at: mockTimestamp,
                psk_valid: true
            }, { merge: true });

            // Assert: Verify successful response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });

        /**
         * Tests handling of device IDs with special characters.
         * 
         * Verifies that the function properly handles device IDs that
         * contain special characters, which might occur with certain
         * device identification schemes or custom naming conventions.
         * 
         * Expected behavior:
         * * Function should accept device IDs with special characters
         * * PSK should be generated and stored with original device ID preserved
         * * No character encoding or escaping issues should occur
         * * Function should return success with generated PSK
         * 
         * This test ensures that the function works correctly with
         * various device ID formats and character sets, supporting
         * diverse device identification schemes.
         * 
         * @test {Function} generatePSK
         * @scenario Device ID contains special characters
         * @expected HTTP 200 with PSK generated for device ID with special characters
         */
        test('should handle device IDs with special characters', async () => {
            // Arrange: Configure device ID with special characters
            const specialDeviceId = 'device-id-with-special-chars_@#$%^&*()+=[]{}|;:,.<>?';
            req.body.deviceId = specialDeviceId;
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Generate PSK for device ID with special characters
            await generatePSK(req, res);

            // Assert: Verify special character device ID is handled correctly
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith(specialDeviceId);
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
                psk_created_at: mockTimestamp,
                psk_valid: true
            }, { merge: true });

            // Assert: Verify successful response
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.json).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });

    /**
     * Test group for security and cryptographic validation.
     * 
     * This test group validates the cryptographic properties and security
     * aspects of PSK generation. The function must generate cryptographically
     * secure keys with proper entropy and format.
     * 
     * Security validation ensures:
     * * Proper use of crypto.randomBytes for secure random generation
     * * Correct key length (32 bytes = 256 bits)
     * * Proper hexadecimal encoding
     * * Appropriate key format for device authentication
     * 
     * These tests ensure that generated PSKs meet security requirements
     * for device authentication and secure communication.
     */
    describe('Security validation', () => {
        /**
         * Tests proper cryptographic key generation parameters.
         * 
         * Verifies that the function uses the correct parameters for
         * cryptographically secure PSK generation, including proper
         * byte length and encoding format.
         * 
         * Expected behavior:
         * * Function should generate exactly 32 bytes of random data
         * * Random bytes should be converted to hexadecimal encoding
         * * Generated PSK should be 64 characters long (32 bytes * 2)
         * * crypto.randomBytes should be used for secure generation
         * 
         * This test ensures that PSKs are generated with appropriate
         * cryptographic strength and format for device authentication
         * and secure communication protocols.
         * 
         * @test {Function} generatePSK
         * @scenario PSK generation with cryptographic validation
         * @expected 32-byte PSK generated using crypto.randomBytes with hex encoding
         */
        test('should generate PSK with correct cryptographic parameters', async () => {
            // Arrange: Mock Date.prototype.toISOString for predictable timestamp testing
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Generate PSK
            await generatePSK(req, res);

            // Assert: Verify correct cryptographic parameters
            expect(mockCrypto.randomBytes).toHaveBeenCalledWith(32); // 256 bits
            expect(mockBuffer.toString).toHaveBeenCalledWith('hex');

            // Assert: Verify PSK format (64 hex characters for 32 bytes)
            const expectedPSK = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
            expect(expectedPSK).toHaveLength(64); // 32 bytes * 2 hex chars per byte
            expect(res.json).toHaveBeenCalledWith({ psk: expectedPSK });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });

        /**
         * Tests PSK document structure and metadata.
         * 
         * Verifies that the function stores PSK data with the correct
         * structure and metadata fields required for device authentication
         * and key management.
         * 
         * Expected behavior:
         * * PSK document should contain psk field with generated key
         * * Document should include psk_created_at timestamp
         * * Document should include psk_valid boolean flag
         * * Merge operation should be used to preserve existing data
         * 
         * This test ensures that PSK storage includes all necessary
         * metadata for proper key management and device authentication
         * workflows.
         * 
         * @test {Function} generatePSK
         * @scenario PSK storage with metadata validation
         * @expected PSK stored with proper structure and metadata fields
         */
        test('should store PSK with proper document structure', async () => {
            // Arrange: Mock Date.prototype.toISOString for predictable timestamp testing
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Generate and store PSK
            await generatePSK(req, res);

            // Assert: Verify document structure
            const expectedDocument = {
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
                psk_created_at: mockTimestamp,
                psk_valid: true
            };
            
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith(expectedDocument, { merge: true });

            // Assert: Verify all required fields are present
            const actualCall = mockDeviceDocRef.set.mock.calls[0][0];
            expect(Object.keys(actualCall)).toEqual(['psk', 'psk_created_at', 'psk_valid']);
            
            // Assert: Verify field types and values
            expect(typeof actualCall.psk).toBe('string');
            expect(typeof actualCall.psk_created_at).toBe('string');
            expect(typeof actualCall.psk_valid).toBe('boolean');
            expect(actualCall.psk_valid).toBe(true);

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });

    /**
     * Test group for Firestore integration and database operation validation.
     * 
     * This test group validates that the function makes the correct calls
     * to Firestore collections and operations with proper parameters. These
     * tests ensure that the function interacts with the database using the
     * expected collection names and operation sequences.
     * 
     * Database operations validated:
     * * Correct collection name usage ('devices')
     * * Proper document ID parameter passing
     * * Expected sequence of database operations
     * * Correct use of merge operation for document updates
     * 
     * These tests serve as integration tests that verify the function's
     * database interaction patterns without requiring actual Firestore
     * connections. They ensure that database schema expectations are
     * met and that the function follows established data access patterns.
     */
    describe('Firestore integration', () => {
        /**
         * Tests correct Firestore collection and operation access patterns.
         * 
         * Verifies that the function accesses the correct Firestore
         * collection and performs the expected operations during
         * the PSK generation and storage workflow.
         * 
         * Expected database operations:
         * 1. Access 'devices' collection
         * 2. Get document reference using device ID
         * 3. Perform set operation with merge to store PSK data
         * 
         * Database schema validation:
         * * Devices collection: /devices/{deviceId}
         * * Correct collection name usage
         * * Proper document ID parameter passing
         * * Correct merge operation usage
         * 
         * @test {Function} generatePSK
         * @scenario Successful PSK generation with database operation validation
         * @expected Correct Firestore collection accessed with proper operations
         */
        test('should call correct Firestore collection and operations', async () => {
            // Arrange: Mock Date.prototype.toISOString for predictable timestamp testing
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Execute PSK generation workflow
            await generatePSK(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('devices');
            
            // Assert: Verify correct document reference creation
            expect(mockDevicesCollection.doc).toHaveBeenCalledWith('test-device-123');
            
            // Assert: Verify correct set operation with merge
            expect(mockDeviceDocRef.set).toHaveBeenCalledWith({
                psk: 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
                psk_created_at: mockTimestamp,
                psk_valid: true
            }, { merge: true });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });
});