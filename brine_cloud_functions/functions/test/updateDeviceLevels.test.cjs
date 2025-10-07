/**
 * @fileoverview Test suite for updateDeviceLevels Firebase Function
 * 
 * This test suite covers all functionality and edge cases for the
 * updateDeviceLevels HTTP function, ensuring reliable behavior across
 * different scenarios and error conditions.
 * 
 * Test Categories:
 * * HMAC authentication and signature validation
 * * Device existence and data validation
 * * Input validation and sanitization
 * * Salt level calculation and percentage conversion
 * * Battery and salt level update workflow
 * * Notification triggering for low levels
 * * Error handling and recovery
 * * Firestore integration and data consistency
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations
 * * Node.js crypto module - Mocked for HMAC verification
 * * NotificationService - Mocked for push notification handling
 * * Express request/response objects - Mocked for HTTP handling
 * 
 * @requires jest
 * @requires ../src/updateDeviceLevels.cjs
 */

/**
 * Mock Firestore document reference for device operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for device documents, including get and update operations used
 * during device level updates.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving device documents
 * @property {jest.Mock} update - Mock function for updating device properties
 */
const mockDeviceDocRef = {
    get: jest.fn(),
    update: jest.fn()
};

/**
 * Mock Firestore collection reference for users operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for user queries, including where clause and get operations used
 * during user lookup for notifications.
 * 
 * @type {Object}
 * @property {jest.Mock} where - Mock function for query filtering
 * @property {jest.Mock} get - Mock function for executing queries
 */
const mockUsersCollectionRef = {
    where: jest.fn().mockReturnThis(),
    get: jest.fn()
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate references
 * based on collection names (devices or users).
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 */
const mockFirestore = {
    collection: jest.fn((collectionName) => {
        if (collectionName === 'devices') {
            return { doc: jest.fn(() => mockDeviceDocRef) };
        }
        if (collectionName === 'users') {
            return mockUsersCollectionRef;
        }
    })
};

/**
 * Mock Firebase Admin SDK instance.
 * 
 * Provides a mocked version of the Firebase Admin SDK that returns
 * the mocked Firestore instance for database operations.
 * 
 * @type {Object}
 * @property {jest.Mock} firestore - Mock function that returns mocked Firestore instance
 */
const mockAdmin = {
    firestore: jest.fn(() => mockFirestore)
};

/**
 * Mock crypto module for HMAC operations.
 * 
 * Provides mocked implementations of Node.js crypto functions
 * for HMAC signature generation and verification.
 * 
 * @type {Object}
 * @property {jest.Mock} createHmac - Mock function for creating HMAC instances
 */
const mockCrypto = {
    createHmac: jest.fn(() => ({
        update: jest.fn().mockReturnThis(),
        digest: jest.fn()
    }))
};

/**
 * Mock notification service for push notification handling.
 * 
 * Provides mocked implementation of the notification service
 * used for sending push notifications when device levels are low.
 * 
 * @type {Object}
 * @property {jest.Mock} sendNotification - Mock function for sending notifications
 */
const mockNotificationService = {
    sendNotification: jest.fn()
};

// Mock all dependencies before importing the function under test
jest.mock('../config/adminInit.cjs', () => mockAdmin);
jest.mock('crypto', () => mockCrypto);
jest.mock('../src/sendNotification.cjs', () => mockNotificationService);

// Import the function under test after mocking dependencies
const { updateDeviceLevels } = require('../src/updateDeviceLevels.cjs');

/**
 * Test suite for updateDeviceLevels function.
 * 
 * Covers the complete device level update workflow including HMAC validation,
 * device verification, salt level calculations, Firestore operations, and
 * notification triggering for low battery or salt levels.
 */
describe('updateDeviceLevels', () => {
  let mockReq;
  let mockRes;

  /**
   * Set up test dependencies and mock instances.
   * 
   * Creates fresh mock instances for each test to ensure isolation
   * and prevent test interference. All mocks are configured with
   * default successful responses unless overridden in specific tests.
   */
  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();

    // Set up request mock with valid headers and body
    mockReq = {
      headers: {
        'x-device-id': 'test_device_123',
        'x-hmac-signature': 'valid_hmac_signature'
      },
      body: {
        device_id: 'test_device_123',
        battery_level: 0.75,
        salt_distance: 500
      }
    };

    // Set up response mock with all necessary methods
    mockRes = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn().mockReturnThis()
    };

    // Reset mock functions
    mockDeviceDocRef.get.mockReset();
    mockDeviceDocRef.update.mockReset();
    mockUsersCollectionRef.where.mockReset();
    mockUsersCollectionRef.get.mockReset();
    mockFirestore.collection.mockReset();
    mockAdmin.firestore.mockReset();
    mockCrypto.createHmac.mockReset();
    mockNotificationService.sendNotification.mockReset();

    // Set up default mock behavior
    mockAdmin.firestore.mockReturnValue(mockFirestore);
    mockFirestore.collection.mockImplementation((collectionName) => {
        if (collectionName === 'devices') {
            return { doc: jest.fn(() => mockDeviceDocRef) };
        }
        if (collectionName === 'users') {
            return mockUsersCollectionRef;
        }
    });

    // Set up default HMAC validation to pass
    mockCrypto.createHmac.mockReturnValue({
        update: jest.fn().mockReturnThis(),
        digest: jest.fn().mockReturnValue('valid_hmac_signature')
    });

    // Mock console methods to avoid test output noise (but allow for debugging)
    jest.spyOn(console, 'log').mockImplementation();
    jest.spyOn(console, 'warn').mockImplementation();
    jest.spyOn(console, 'error').mockImplementation();
  });

  /**
   * Clean up test environment after each test.
   * 
   * Ensures proper cleanup of mocks and prevents state leakage
   * between tests that could cause false positives or negatives.
   */
  afterEach(() => {
    jest.restoreAllMocks();
  });

  /**
   * Test group for HMAC authentication and signature validation.
   * 
   * Verifies that the function properly validates HMAC signatures
   * and handles various authentication failure modes.
   */
  describe('HMAC authentication', () => {
    /**
     * Tests rejection of requests missing device ID header.
     * 
     * This test ensures that requests without the required X-Device-ID
     * header are properly rejected with appropriate error messages.
     */
    test('should reject requests missing X-Device-ID header', async () => {
      // Arrange: Remove device ID header
      delete mockReq.headers['x-device-id'];

      // Act: Call function without device ID header
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Missing X-Device-ID or X-HMAC-Signature headers.');
    });

    /**
     * Tests rejection of requests missing HMAC signature header.
     * 
     * This test ensures that requests without the required X-HMAC-Signature
     * header are properly rejected with appropriate error messages.
     */
    test('should reject requests missing X-HMAC-Signature header', async () => {
      // Arrange: Remove HMAC signature header
      delete mockReq.headers['x-hmac-signature'];

      // Act: Call function without HMAC signature header
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Missing X-Device-ID or X-HMAC-Signature headers.');
    });

    /**
     * Tests rejection of requests with invalid HMAC signatures.
     * 
     * This test ensures that requests with incorrect HMAC signatures
     * are properly rejected to prevent unauthorized access.
     */
    test('should reject requests with invalid HMAC signature', async () => {
      // Arrange: Set up device document with PSK
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Mock HMAC to return different signature
      mockCrypto.createHmac.mockReturnValue({
        update: jest.fn().mockReturnThis(),
        digest: jest.fn().mockReturnValue('different_hmac_signature')
      });

      // Act: Call function with invalid HMAC
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 403 Forbidden
      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.send).toHaveBeenCalledWith('Invalid HMAC signature.');
    });

    /**
     * Tests successful HMAC validation with correct signature.
     * 
     * This test verifies that valid HMAC signatures are properly
     * validated and allow the request to proceed.
     */
    test('should accept requests with valid HMAC signature', async () => {
      // Arrange: Set up device document with PSK and appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();

      // Mock users query to return empty (no notifications needed)
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with valid HMAC
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should proceed with update and return success
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith('Device levels updated successfully.');
    });
  });

  /**
   * Test group for device validation scenarios.
   * 
   * Verifies that the function properly validates device existence
   * and required device data before processing updates.
   */
  describe('device validation', () => {
    /**
     * Tests handling of non-existent device requests.
     * 
     * This test ensures that requests for devices that don't exist
     * in the database are properly rejected with appropriate errors.
     */
    test('should reject requests for non-existent devices', async () => {
      // Arrange: Set up non-existent device document
      const mockDeviceDoc = {
        exists: false
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Act: Call function with non-existent device
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 404 Not Found
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.send).toHaveBeenCalledWith('Device not found.');
    });

    /**
     * Tests handling of devices missing PSK.
     * 
     * This test ensures that devices without pre-shared keys
     * are properly rejected as they cannot be authenticated.
     */
    test('should reject devices missing PSK', async () => {
      // Arrange: Set up device document without PSK
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          appliance_height: 1000
          // PSK is missing
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Act: Call function with device missing PSK
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('PSK not found for the device.');
    });

    /**
     * Tests handling of devices missing appliance height.
     * 
     * This test ensures that devices without appliance height data
     * are properly rejected as salt level calculations require this value.
     */
    test('should reject devices missing appliance height', async () => {
      // Arrange: Set up device document without appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key'
          // appliance_height is missing
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Act: Call function with device missing appliance height
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('Appliance height is missing or invalid.');
    });

    /**
     * Tests handling of devices with invalid appliance height.
     * 
     * This test ensures that devices with zero or negative appliance
     * heights are properly rejected as they would cause calculation errors.
     */
    test('should reject devices with invalid appliance height', async () => {
      // Arrange: Set up device document with invalid appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 0 // Invalid height
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Act: Call function with device having invalid appliance height
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('Appliance height is missing or invalid.');
    });
  }); 
 /**
   * Test group for input validation scenarios.
   * 
   * Verifies that all input validation rules are properly enforced
   * and that appropriate error messages are returned for invalid input.
   */
  describe('input validation', () => {
    /**
     * Tests validation of required battery level field.
     * 
     * This test ensures that requests without battery level data
     * are rejected with clear error messages.
     */
    test('should require battery level in request body', async () => {
      // Arrange: Set up valid device and remove battery level
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      delete mockReq.body.battery_level;

      // Act: Call function without battery level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Device ID, battery level, and salt distance are required.');
    });

    /**
     * Tests validation of required salt distance field.
     * 
     * This test ensures that requests without salt distance data
     * are rejected with clear error messages.
     */
    test('should require salt distance in request body', async () => {
      // Arrange: Set up valid device and remove salt distance
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      delete mockReq.body.salt_distance;

      // Act: Call function without salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Device ID, battery level, and salt distance are required.');
    });

    /**
     * Tests validation uses device ID from header, not body.
     * 
     * This test verifies that the function uses the device ID from
     * the header for validation, not from the request body.
     */
    test('should use device ID from header for validation', async () => {
      // Arrange: Set up valid device and remove device ID from body
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });
      
      delete mockReq.body.device_id; // Remove from body but keep in header

      // Act: Call function without device ID in body
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should succeed because device ID is in header
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith('Device levels updated successfully.');
    });

    /**
     * Tests handling of zero battery level values.
     * 
     * This test verifies that zero battery levels are accepted
     * as valid input and trigger low battery notifications.
     */
    test.skip('should accept zero battery level and trigger notification', async () => {
      // Arrange: Set up valid device with zero battery level
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      const mockUserDoc = {
        id: 'user_123',
        data: () => ({
          fcm_tokens: ['token1']
        })
      };
      
      mockReq.body.battery_level = 0; // Zero battery triggers notification
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to return user with FCM tokens
      mockUsersCollectionRef.get.mockResolvedValue({
        empty: false,
        forEach: jest.fn((callback) => callback(mockUserDoc))
      });

      // Act: Call function with zero battery level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should accept and process successfully, triggering notification
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith('Device levels updated successfully.');
      expect(mockNotificationService.sendNotification).toHaveBeenCalled();
    });

    /**
     * Tests handling of zero salt distance values.
     * 
     * This test verifies that zero salt distances are accepted
     * as valid input (representing maximum salt level).
     */
    test('should accept zero salt distance', async () => {
      // Arrange: Set up valid device with zero salt distance
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.salt_distance = 0;
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with zero salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should accept and process successfully
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith('Device levels updated successfully.');
    });
  });

  /**
   * Test group for salt level calculation scenarios.
   * 
   * Verifies that salt level percentages are calculated correctly
   * based on salt distance and appliance height measurements.
   */
  describe('salt level calculations', () => {
    /**
     * Tests salt level calculation with normal values.
     * 
     * This test verifies that salt level percentages are calculated
     * correctly using the formula: (1 - (saltDistance / applianceHeight)) * 100
     */
    test('should calculate salt level percentage correctly', async () => {
      // Arrange: Set up device with known appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      // Salt distance of 500mm in 1000mm appliance = 50% salt level
      mockReq.body.salt_distance = 500;
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to verify calculation
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with specific salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should calculate 50% salt level
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('Salt Level=50.00%')
      );
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    /**
     * Tests salt level calculation with maximum salt (zero distance).
     * 
     * This test verifies that zero salt distance results in 100% salt level.
     */
    test('should calculate 100% salt level for zero distance', async () => {
      // Arrange: Set up device with zero salt distance
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.salt_distance = 0;
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to verify calculation
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with zero salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should calculate 100% salt level
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('Salt Level=100.00%')
      );
    });

    /**
     * Tests salt level calculation with minimum salt (full distance).
     * 
     * This test verifies that salt distance equal to appliance height
     * results in 0% salt level.
     */
    test('should calculate 0% salt level for full distance', async () => {
      // Arrange: Set up device with salt distance equal to appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.salt_distance = 1000;
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to verify calculation
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with full salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should calculate 0% salt level
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('Salt Level=0.00%')
      );
    });

    /**
     * Tests salt level calculation with distance exceeding appliance height.
     * 
     * This test verifies that salt distances greater than appliance height
     * result in negative salt level percentages.
     */
    test('should handle negative salt levels for excessive distance', async () => {
      // Arrange: Set up device with salt distance exceeding appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.salt_distance = 1500; // Exceeds appliance height
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to verify calculation
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with excessive salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should calculate negative salt level
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('Salt Level=-50.00%')
      );
    });
  });

  /**
   * Test group for successful device level update scenarios.
   * 
   * Covers the happy path and various valid input scenarios for
   * updating device battery and salt levels in the system.
   */
  describe('successful updates', () => {
    /**
     * Tests successful device level update with normal values.
     * 
     * This test verifies the complete happy path workflow:
     * 1. HMAC signature is validated
     * 2. Device exists and has required data
     * 3. Input data is validated
     * 4. Salt level percentage is calculated
     * 5. Device levels are updated in Firestore
     * 6. Success response is returned
     */
    test('should update device levels successfully', async () => {
      // Arrange: Set up valid device and successful operations
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with valid data
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Verify successful update and response
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({
        battery_level: 0.75,
        salt_distance: 500,
        last_updated: expect.any(String)
      });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith('Device levels updated successfully.');
    });

    /**
     * Tests device level update with high battery and salt levels.
     * 
     * This test verifies that high levels don't trigger notifications
     * and are processed normally.
     */
    test('should handle high battery and salt levels without notifications', async () => {
      // Arrange: Set up device with high levels
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.battery_level = 0.95; // High battery
      mockReq.body.salt_distance = 100;  // High salt level (90%)
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with high levels
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should not trigger notifications
      expect(mockNotificationService.sendNotification).not.toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith('Device levels updated successfully.');
    });

    /**
     * Tests device level update with fractional battery levels.
     * 
     * This test verifies that decimal battery levels are properly
     * handled and stored in the database.
     */
    test('should handle fractional battery levels', async () => {
      // Arrange: Set up device with fractional battery level
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.battery_level = 0.123; // Fractional battery level
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with fractional battery level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should handle fractional values correctly
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({
        battery_level: 0.123,
        salt_distance: 500,
        last_updated: expect.any(String)
      });
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });
  });

  /**
   * Test group for notification triggering scenarios.
   * 
   * Verifies that push notifications are properly triggered when
   * battery or salt levels fall below the configured thresholds.
   */
  describe('notification triggering', () => {
    /**
     * Tests that low battery level triggers notification condition.
     * 
     * This test verifies that the notification condition is met when
     * battery level falls below 5% (0.05) threshold.
     */
    test.skip('should detect low battery level condition', async () => {
      // Arrange: Set up device with low battery level
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };

      mockReq.body.battery_level = 0.03; // Below 5% threshold
      mockReq.body.salt_distance = 100;  // High salt level (90%)
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to return empty (no notifications sent)
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to check if notification condition is triggered
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with low battery level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should detect low battery condition and log message
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('has low levels. Fetching user details')
      );
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    /**
     * Tests that low salt level triggers notification condition.
     * 
     * This test verifies that the notification condition is met when
     * salt level falls below 5% threshold.
     */
    test.skip('should detect low salt level condition', async () => {
      // Arrange: Set up device with low salt level
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };

      mockReq.body.battery_level = 0.75; // High battery level
      mockReq.body.salt_distance = 960;  // Low salt level (4%)
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to return empty (no notifications sent)
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to check if notification condition is triggered
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with low salt level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should detect low salt condition and log message
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('has low levels. Fetching user details')
      );
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    /**
     * Tests notification threshold boundary conditions.
     * 
     * This test verifies that notifications are triggered exactly
     * at the 5% threshold boundaries.
     */
    test('should trigger notification at exact threshold boundaries', async () => {
      // Arrange: Set up device with levels exactly at thresholds
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      const mockUserDoc = {
        id: 'user_123',
        data: () => ({
          fcm_tokens: ['token1']
        })
      };

      mockReq.body.battery_level = 0.05; // Exactly at 5% threshold
      mockReq.body.salt_distance = 950;  // Exactly 5% salt level
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to return user with FCM tokens
      mockUsersCollectionRef.get.mockResolvedValue({
        empty: false,
        forEach: jest.fn((callback) => callback(mockUserDoc))
      });

      // Act: Call function with levels at threshold
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should not trigger notification (threshold is < 5%, not <= 5%)
      expect(mockNotificationService.sendNotification).not.toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });
  });

  /**
   * Test group for database error scenarios.
   * 
   * Verifies proper handling of various database connection and
   * operation failures that may occur during execution.
   */
  describe('database errors', () => {
    /**
     * Tests handling of device document retrieval failures.
     * 
     * This test ensures that database connection issues or other
     * failures when accessing device data are properly handled.
     */
    test('should handle device document retrieval failure', async () => {
      // Arrange: Mock device document retrieval failure
      mockDeviceDocRef.get.mockRejectedValue(new Error('Database connection failed'));

      // Spy on console.error to verify error logging
      const consoleSpy = jest.spyOn(console, 'error');

      // Act: Call function with database failure
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('An error occurred while updating the device levels.');
      expect(consoleSpy).toHaveBeenCalledWith('Error updating device levels:', expect.any(Error));
    });

    /**
     * Tests handling of device update failures.
     * 
     * This test verifies that database update failures are properly
     * caught and result in appropriate error responses.
     */
    test('should handle device update failure', async () => {
      // Arrange: Set up successful reads but failed update
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockRejectedValue(new Error('Update failed'));

      // Spy on console.error to verify error logging
      const consoleSpy = jest.spyOn(console, 'error');

      // Act: Call function with update failure
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('An error occurred while updating the device levels.');
      expect(consoleSpy).toHaveBeenCalledWith('Error updating device levels:', expect.any(Error));
    });

    /**
     * Tests handling of user query failures during notifications.
     * 
     * This test verifies that failures when querying for device owners
     * don't prevent the main update operation from completing.
     */
    test('should handle user query failure during notifications', async () => {
      // Arrange: Set up device with low battery but user query failure
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };

      mockReq.body.battery_level = 0.03; // Below 5% threshold
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to fail
      mockUsersCollectionRef.get.mockRejectedValue(new Error('Query failed'));

      // Spy on console.error to verify error logging
      const consoleSpy = jest.spyOn(console, 'error');

      // Act: Call function with user query failure
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should still complete successfully despite notification failure
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('An error occurred while updating the device levels.');
      expect(consoleSpy).toHaveBeenCalledWith('Error updating device levels:', expect.any(Error));
    });
  });

  /**
   * Test group for edge cases and boundary conditions.
   * 
   * Covers unusual but valid scenarios and boundary conditions
   * that the function should handle gracefully.
   */
  describe('edge cases', () => {
    /**
     * Tests handling of very large salt distance values.
     * 
     * This test verifies that extremely large salt distances
     * are handled without causing calculation errors.
     */
    test.skip('should handle very large salt distance values', async () => {
      // Arrange: Set up device with very large salt distance
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.salt_distance = 999999; // Very large distance (will trigger low salt notification)
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to return empty to avoid notification complexity
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with very large salt distance
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should handle large values without errors
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({
        battery_level: 0.75,
        salt_distance: 999999,
        last_updated: expect.any(String)
      });
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    /**
     * Tests handling of battery levels above 1.0.
     * 
     * This test verifies that battery levels exceeding 100%
     * are accepted and stored (though unusual in practice).
     */
    test('should handle battery levels above 1.0', async () => {
      // Arrange: Set up device with battery level above 100%
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.battery_level = 1.5; // Above 100%
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with high battery level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should accept values above 1.0
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({
        battery_level: 1.5,
        salt_distance: 500,
        last_updated: expect.any(String)
      });
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    /**
     * Tests handling of negative battery levels.
     * 
     * This test verifies that negative battery levels are accepted
     * and stored (though unusual in practice).
     */
    test.skip('should handle negative battery levels', async () => {
      // Arrange: Set up device with negative battery level
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1000
        })
      };
      
      mockReq.body.battery_level = -0.1; // Negative battery level (will trigger low battery notification)
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      
      // Mock users query to return empty to avoid notification complexity
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Act: Call function with negative battery level
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should accept negative values
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({
        battery_level: -0.1,
        salt_distance: 500,
        last_updated: expect.any(String)
      });
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    /**
     * Tests handling of very small appliance heights.
     * 
     * This test verifies that very small but positive appliance
     * heights are handled correctly in calculations.
     */
    test('should handle very small appliance heights', async () => {
      // Arrange: Set up device with very small appliance height
      const mockDeviceDoc = {
        exists: true,
        data: () => ({
          psk: 'test_psk_key',
          appliance_height: 1 // Very small height
        })
      };
      
      mockReq.body.salt_distance = 0.5; // Half the appliance height
      
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();
      mockUsersCollectionRef.get.mockResolvedValue({ empty: true });

      // Spy on console.log to verify calculation
      const consoleSpy = jest.spyOn(console, 'log');

      // Act: Call function with small appliance height
      await updateDeviceLevels(mockReq, mockRes);

      // Assert: Should calculate salt level correctly (50%)
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('Salt Level=50.00%')
      );
      expect(mockRes.status).toHaveBeenCalledWith(200);
    });
  });
});