/**
 * @fileoverview Test suite for updateApplianceHeight Firebase Function
 * 
 * This test suite covers all functionality and edge cases for the
 * updateApplianceHeight HTTP function, ensuring reliable behavior across
 * different scenarios and error conditions.
 * 
 * Test Categories:
 * * Authentication and authorization validation
 * * Device access control and ownership verification
 * * Input validation and sanitization
 * * Appliance height update workflow
 * * Error handling and recovery
 * * Firestore integration and data consistency
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations
 * * Express request/response objects - Mocked for HTTP handling
 * 
 * @requires jest
 * @requires ../src/updateApplianceHeight.cjs
 */

/**
 * Mock Firestore document reference for user operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for user documents, including get operations used during device
 * ownership verification.
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
 * for device documents, including get and update operations used
 * during appliance height updates.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for checking device existence
 * @property {jest.Mock} update - Mock function for updating device properties
 */
const mockDeviceDocRef = {
    get: jest.fn(),
    update: jest.fn()
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
 * the mocked Firestore instance for database operations.
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
const { updateApplianceHeight } = require('../src/updateApplianceHeight.cjs');

/**
 * Test suite for updateApplianceHeight function.
 * 
 * Covers the complete appliance height update workflow including validation,
 * authentication, device ownership verification, Firestore operations, and error handling.
 */
describe('updateApplianceHeight', () => {
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

    // Set up request mock with authenticated user
    mockReq = {
      user: {
        uid: 'test_user_123'
      },
      body: {
        deviceId: 'vast_teal_elephant',
        applianceHeight: 1000
      }
    };

    // Set up response mock with all necessary methods
    mockRes = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis()
    };

    // Reset mock functions
    mockUserDocRef.get.mockReset();
    mockDeviceDocRef.get.mockReset();
    mockDeviceDocRef.update.mockReset();
    mockFirestore.collection.mockReset();
    mockAdmin.firestore.mockReset();

    // Set up default mock behavior
    mockAdmin.firestore.mockReturnValue(mockFirestore);
    mockFirestore.collection.mockImplementation((collectionName) => {
        if (collectionName === 'users') {
            return { doc: jest.fn(() => mockUserDocRef) };
        }
        if (collectionName === 'devices') {
            return { doc: jest.fn(() => mockDeviceDocRef) };
        }
    });
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
   * Test group for authentication and authorization scenarios.
   * 
   * Verifies that the function properly validates user authentication
   * and handles various authentication failure modes.
   */
  describe('authentication and authorization', () => {
    /**
     * Verifies that requests without user authentication cause errors.
     * 
     * This test ensures that the function fails when no user context
     * is provided in the request, as it expects middleware to handle auth.
     * The function will throw a TypeError when trying to access req.user.uid.
     */
    test('should handle missing user authentication', async () => {
      // Arrange: Remove user from request
      mockReq.user = undefined;

      // Act & Assert: Function should throw TypeError due to undefined user
      await expect(updateApplianceHeight(mockReq, mockRes)).rejects.toThrow(TypeError);
      await expect(updateApplianceHeight(mockReq, mockRes)).rejects.toThrow("Cannot read properties of undefined (reading 'uid')");
    });

    /**
     * Verifies that users can only access devices they own.
     * 
     * This test ensures proper access control by verifying that users
     * cannot update appliance heights for devices not in their device list.
     */
    test('should reject access to devices not owned by user', async () => {
      // Arrange: Set up user document without the requested device
      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['other_device_123']) // User doesn't own requested device
      };
      
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);

      // Act: Attempt to update device not owned by user
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 403 Forbidden
      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.send).toHaveBeenCalledWith('User does not have access to the specified device');
    });

    /**
     * Verifies proper handling when user document doesn't exist.
     * 
     * This test ensures that requests from non-existent users are
     * properly rejected with appropriate error messages.
     */
    test('should handle non-existent user', async () => {
      // Arrange: Set up non-existent user document
      const mockUserDoc = {
        exists: false
      };
      
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);

      // Act: Call function with non-existent user
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 404 Not Found
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.send).toHaveBeenCalledWith('User not found');
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
     * Tests validation of required deviceId field.
     * 
     * This test ensures that requests without a device ID are rejected
     * with clear error messages indicating the missing requirement.
     */
    test('should require deviceId in request body', async () => {
      // Arrange: Remove deviceId from request body
      delete mockReq.body.deviceId;

      // Act: Call function without deviceId
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Device ID must be provided');
    });

    /**
     * Tests validation of required applianceHeight field.
     * 
     * This test ensures that requests without appliance height are rejected
     * with clear error messages indicating the missing requirement.
     */
    test('should require applianceHeight in request body', async () => {
      // Arrange: Remove applianceHeight from request body
      delete mockReq.body.applianceHeight;

      // Act: Call function without applianceHeight
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Appliance height must be provided');
    });

    /**
     * Tests handling of null deviceId values.
     * 
     * This test verifies that null device IDs are properly rejected
     * as invalid input with appropriate error responses.
     */
    test('should reject null deviceId', async () => {
      // Arrange: Set deviceId to null
      mockReq.body.deviceId = null;

      // Act: Call function with null deviceId
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Device ID must be provided');
    });

    /**
     * Tests handling of null applianceHeight values.
     * 
     * This test verifies that null appliance heights are properly rejected
     * as invalid input with appropriate error responses.
     */
    test('should reject null applianceHeight', async () => {
      // Arrange: Set applianceHeight to null
      mockReq.body.applianceHeight = null;

      // Act: Call function with null applianceHeight
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Appliance height must be provided');
    });
  });

  /**
   * Test group for successful appliance height update scenarios.
   * 
   * Covers the happy path and various valid input scenarios for
   * updating appliance heights in the system.
   */
  describe('successful updates', () => {
    /**
     * Tests successful appliance height update with valid input.
     * 
     * This test verifies the complete happy path workflow:
     * 1. User authentication is validated
     * 2. Device ownership is verified
     * 3. Device exists in the system
     * 4. Appliance height is updated in Firestore
     * 5. Success response is returned
     */
    test('should update appliance height successfully', async () => {
      // Arrange: Set up successful Firestore responses
      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant', 'other_device'])
      };
      
      const mockDeviceDoc = {
        exists: true
      };

      // Mock user document with device access
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      // Mock device document exists
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      // Mock successful update operation
      mockDeviceDocRef.update.mockResolvedValue();

      // Act: Call function with valid data
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Verify successful update and response
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.collection).toHaveBeenCalledWith('devices');
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({ appliance_height: 1000 });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith('Appliance height updated successfully');
    });

    /**
     * Tests appliance height update with string numeric input.
     * 
     * This test verifies that string representations of numbers
     * are properly converted to integers before storage.
     */
    test('should handle string numeric appliance height', async () => {
      // Arrange: Set appliance height as string
      mockReq.body.applianceHeight = '1500';

      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      const mockDeviceDoc = {
        exists: true
      };

      // Set up successful Firestore responses
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();

      // Act: Call function with string numeric input
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should convert to integer and update successfully
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({ appliance_height: 1500 });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith('Appliance height updated successfully');
    });

    /**
     * Tests appliance height update with zero value.
     * 
     * This test verifies that zero is rejected as invalid input due to
     * the function's falsy check (!applianceHeight), which treats 0 as missing.
     */
    test('should reject zero appliance height as missing', async () => {
      // Arrange: Set appliance height to zero
      mockReq.body.applianceHeight = 0;

      // Act: Call function with zero height
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should reject zero as missing value due to falsy check
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Appliance height must be provided');
    });

    /**
     * Tests appliance height update with large numeric values.
     * 
     * This test verifies that large appliance height values are
     * properly handled and stored without overflow issues.
     */
    test('should handle large appliance height values', async () => {
      // Arrange: Set large appliance height
      mockReq.body.applianceHeight = 999999;

      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      const mockDeviceDoc = {
        exists: true
      };

      // Set up successful Firestore responses
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();

      // Act: Call function with large height value
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should handle large values correctly
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({ appliance_height: 999999 });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith('Appliance height updated successfully');
    });
  });

  /**
   * Test group for device-related error scenarios.
   * 
   * Verifies proper handling of device-specific errors including
   * non-existent devices and database access issues.
   */
  describe('device errors', () => {
    /**
     * Tests handling of non-existent device requests.
     * 
     * This test ensures that requests for devices that don't exist
     * in the database are properly rejected with appropriate errors.
     */
    test('should handle non-existent device', async () => {
      // Arrange: Set up user with device access but device doesn't exist
      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      const mockDeviceDoc = {
        exists: false
      };

      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      // Mock device document doesn't exist
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Act: Call function with non-existent device
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 404 Not Found
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.send).toHaveBeenCalledWith('Device not found');
    });

    /**
     * Tests handling of device update failures.
     * 
     * This test verifies that database update failures are properly
     * caught and result in appropriate error responses.
     */
    test('should handle device update failure', async () => {
      // Arrange: Set up successful reads but failed update
      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      const mockDeviceDoc = {
        exists: true
      };

      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);

      // Mock update failure
      mockDeviceDocRef.update.mockRejectedValue(new Error('Update failed'));

      // Spy on console.error to verify error logging
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      // Act: Call function with update failure
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('Internal Server Errorr'); // Note: matches original typo
      expect(consoleSpy).toHaveBeenCalledWith('Error updating appliance height:', expect.any(Error));

      // Cleanup
      consoleSpy.mockRestore();
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
     * Tests handling of user document retrieval failures.
     * 
     * This test ensures that database connection issues or other
     * failures when accessing user data are properly handled.
     */
    test('should handle user document retrieval failure', async () => {
      // Arrange: Mock user document retrieval failure
      mockUserDocRef.get.mockRejectedValue(new Error('Database connection failed'));

      // Spy on console.error to verify error logging
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      // Act: Call function with database failure
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('Internal Server Error');
      expect(consoleSpy).toHaveBeenCalledWith('Error getting device levels:', expect.any(Error));

      // Cleanup
      consoleSpy.mockRestore();
    });

    /**
     * Tests handling of device document retrieval failures.
     * 
     * This test verifies that failures when accessing device documents
     * are caught in the outer try-catch and handled appropriately.
     */
    test('should handle device document retrieval failure', async () => {
      // Arrange: Set up successful user retrieval but failed device retrieval
      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      // Mock device document retrieval failure
      mockDeviceDocRef.get.mockRejectedValue(new Error('Device access failed'));

      // Spy on console.error to verify error logging
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      // Act: Call function with device retrieval failure
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 500 Internal Server Error
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.send).toHaveBeenCalledWith('Internal Server Error');
      expect(consoleSpy).toHaveBeenCalledWith('Error getting device levels:', expect.any(Error));

      // Cleanup
      consoleSpy.mockRestore();
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
     * Tests handling of non-numeric appliance height strings.
     * 
     * This test verifies that invalid string inputs are converted
     * using parseInt, which may result in NaN for invalid strings.
     */
    test('should handle non-numeric appliance height strings', async () => {
      // Arrange: Set non-numeric string as appliance height
      mockReq.body.applianceHeight = 'invalid_height';

      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      const mockDeviceDoc = {
        exists: true
      };

      // Set up successful Firestore responses
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();

      // Act: Call function with non-numeric string
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: parseInt will convert to NaN, which gets stored
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({ appliance_height: NaN });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith('Appliance height updated successfully');
    });

    /**
     * Tests handling of negative appliance height values.
     * 
     * This test verifies that negative values are accepted and stored,
     * as the function doesn't validate for positive-only values.
     */
    test('should handle negative appliance height', async () => {
      // Arrange: Set negative appliance height
      mockReq.body.applianceHeight = -100;

      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue(['vast_teal_elephant'])
      };
      
      const mockDeviceDoc = {
        exists: true
      };

      // Set up successful Firestore responses
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);
      mockDeviceDocRef.get.mockResolvedValueOnce(mockDeviceDoc);
      mockDeviceDocRef.update.mockResolvedValue();

      // Act: Call function with negative height
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should accept negative values
      expect(mockDeviceDocRef.update).toHaveBeenCalledWith({ appliance_height: -100 });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith('Appliance height updated successfully');
    });

    /**
     * Tests handling of empty string deviceId.
     * 
     * This test verifies that empty string device IDs are treated
     * as missing and properly rejected.
     */
    test('should handle empty string deviceId', async () => {
      // Arrange: Set empty string as deviceId
      mockReq.body.deviceId = '';

      // Act: Call function with empty deviceId
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 400 Bad Request
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.send).toHaveBeenCalledWith('Device ID must be provided');
    });

    /**
     * Tests handling of user with empty device list.
     * 
     * This test verifies that users with no devices are properly
     * handled when they attempt to access a device.
     */
    test('should handle user with empty device list', async () => {
      // Arrange: Set up user with empty device list
      const mockUserDoc = {
        exists: true,
        get: jest.fn().mockReturnValue([]) // Empty device list
      };
      
      mockUserDocRef.get.mockResolvedValueOnce(mockUserDoc);

      // Act: Call function with user having no devices
      await updateApplianceHeight(mockReq, mockRes);

      // Assert: Should return 403 Forbidden
      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.send).toHaveBeenCalledWith('User does not have access to the specified device');
    });
  });
});