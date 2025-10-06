# Documentation Standards

## Philosophy

Documentation is not optional—it is a critical component of code quality and project sustainability. Every piece of code written for this Firebase Functions project must be thoroughly documented with the assumption that another developer will need to understand, maintain, and extend the work.

**Core Principle**: Code without proper documentation is incomplete code.

## Universal Documentation Requirements

### Mandatory Documentation for ALL Code Entities

Every single code entity across the entire project must include documentation:

- **Functions and Methods**: Parameters, return values, side effects, and examples
- **Objects and Classes**: Purpose, usage patterns, and relationships
- **Constants and Variables**: Purpose, expected values, and constraints
- **Configuration Objects**: All properties and their effects
- **Firebase Functions**: Request/response formats, triggers, and behavior
- **Middleware**: Purpose, request/response modifications, and usage
- **Error Classes**: Error types, causes, and recovery strategies
- **Environment Variables**: Purpose and expected values

## JavaScript/Node.js Documentation Standards

### JSDoc Format for All JavaScript Code

Use JSDoc format for all JavaScript code in this Firebase Functions project:

```javascript
/**
 * Firebase Cloud Function for adding a device to a user's account.
 * 
 * This function handles the complete workflow of device registration:
 * - Validates user authentication and device data
 * - Generates unique device identifiers and security keys
 * - Updates Firestore with device information
 * - Sends confirmation notifications
 * 
 * @param {Object} data - The request data from the client
 * @param {string} data.deviceId - Unique identifier for the device
 * @param {string} data.deviceName - Human-readable name for the device
 * @param {string} data.deviceType - Type of device (sensor, controller, etc.)
 * @param {Object} context - Firebase Functions context object
 * @param {Object} context.auth - Authentication information
 * @param {string} context.auth.uid - User ID from Firebase Auth
 * 
 * @returns {Promise<Object>} Response object with device registration status
 * @returns {boolean} returns.success - Whether the operation succeeded
 * @returns {string} returns.deviceId - The registered device ID
 * @returns {string} returns.psk - Pre-shared key for device authentication
 * 
 * @throws {functions.https.HttpsError} When validation fails or operation errors occur
 * 
 * @example
 * // Client-side call
 * const addDevice = firebase.functions().httpsCallable('addDeviceToUser');
 * const result = await addDevice({
 *   deviceId: 'sensor_001',
 *   deviceName: 'Living Room Temperature Sensor',
 *   deviceType: 'temperature_sensor'
 * });
 */
const addDeviceToUser = functions.https.onCall(async (data, context) => {
  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to add devices'
    );
  }

  const userId = context.auth.uid;
  
  /**
   * Device configuration object with validation and defaults.
   * 
   * Contains all necessary information for device registration
   * including security credentials and metadata.
   */
  const deviceConfig = {
    deviceId: data.deviceId,
    deviceName: data.deviceName || 'Unnamed Device',
    deviceType: data.deviceType || 'generic',
    userId: userId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isActive: true,
    lastSeen: null
  };

  // Implementation continues...
});

/**
 * Utility function for generating secure pre-shared keys.
 * 
 * Creates cryptographically secure random keys for device authentication.
 * Uses Node.js crypto module to ensure sufficient entropy and security.
 * 
 * @param {number} [length=32] - Length of the generated key in bytes
 * @returns {string} Hexadecimal string representation of the generated key
 * 
 * @example
 * const deviceKey = generateSecureKey(16); // Returns 32-character hex string
 */
function generateSecureKey(length = 32) {
  const crypto = require('crypto');
  return crypto.randomBytes(length).toString('hex');
}

/**
 * Configuration object for device validation rules.
 * 
 * Defines the validation constraints and business rules for device
 * registration, including allowed types, naming conventions, and limits.
 */
const DEVICE_CONFIG = {
  /**
   * Maximum number of devices allowed per user account.
   * 
   * Prevents abuse and ensures system performance by limiting
   * the number of devices a single user can register.
   * 
   * @type {number}
   */
  MAX_DEVICES_PER_USER: 50,

  /**
   * Allowed device types for registration.
   * 
   * Whitelist of valid device types that can be registered.
   * Used for validation and UI categorization.
   * 
   * @type {string[]}
   */
  ALLOWED_DEVICE_TYPES: [
    'temperature_sensor',
    'humidity_sensor',
    'motion_detector',
    'door_sensor',
    'smart_switch',
    'camera',
    'controller'
  ],

  /**
   * Regular expression for valid device names.
   * 
   * Ensures device names contain only safe characters and
   * are within reasonable length limits for display purposes.
   * 
   * @type {RegExp}
   */
  DEVICE_NAME_PATTERN: /^[a-zA-Z0-9\s\-_]{1,50}$/
};

module.exports = { addDeviceToUser, generateSecureKey, DEVICE_CONFIG };
```

## Documentation Structure Requirements

### File-Level Documentation

Every source file must begin with a comprehensive header:

```javascript
/**
 * @fileoverview Device Management Firebase Functions
 * 
 * This module contains Firebase Cloud Functions for managing IoT devices
 * within the household automation system. It handles the complete device
 * lifecycle from registration through monitoring and removal.
 * 
 * Key Functions:
 * * addDeviceToUser - Registers new devices to user accounts
 * * removeDeviceFromUser - Safely removes devices and cleans up data
 * * updateDeviceLevels - Updates sensor readings and device status
 * * getDevice - Retrieves device information and current status
 * 
 * Dependencies:
 * * Firebase Admin SDK - For Firestore and Auth operations
 * * Firebase Functions SDK - For HTTP callable functions
 * * Node.js crypto - For secure key generation
 * 
 * @author Your Team Name
 * @since 2025-01-10
 * @version 1.0.0
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
```

### Complex Algorithm Documentation

For any non-trivial logic, provide detailed explanations:

```javascript
/**
 * Calculates optimal device polling intervals based on usage patterns.
 * 
 * This algorithm balances several competing factors:
 * 1. Battery life preservation for wireless devices
 * 2. Real-time responsiveness for critical sensors
 * 3. Network bandwidth conservation
 * 4. User activity patterns and preferences
 * 
 * The calculation works as follows:
 * 1. Analyze historical usage data to identify patterns
 * 2. Apply device-type specific base intervals
 * 3. Adjust for current battery level and power source
 * 4. Factor in user presence and activity levels
 * 5. Apply network congestion and rate limiting constraints
 * 
 * Performance: O(log n) where n is the number of historical data points
 * 
 * @param {Object} deviceData - Current device information and status
 * @param {string} deviceData.deviceId - Unique device identifier
 * @param {string} deviceData.deviceType - Type of device (sensor, controller, etc.)
 * @param {number} deviceData.batteryLevel - Current battery percentage (0-100)
 * @param {boolean} deviceData.isPluggedIn - Whether device has external power
 * @param {Object[]} usageHistory - Array of historical usage data points
 * @param {number} usageHistory[].timestamp - Unix timestamp of data point
 * @param {number} usageHistory[].activity - Activity level (0-1)
 * @param {Object} userPreferences - User's polling preferences
 * @param {number} userPreferences.responsiveness - Desired responsiveness (1-5)
 * @param {boolean} userPreferences.batteryOptimization - Prioritize battery life
 * 
 * @returns {number} Optimal polling interval in milliseconds
 * 
 * @example
 * const interval = calculatePollingInterval(
 *   {
 *     deviceId: 'sensor_001',
 *     deviceType: 'temperature_sensor',
 *     batteryLevel: 75,
 *     isPluggedIn: false
 *   },
 *   usageHistoryArray,
 *   { responsiveness: 3, batteryOptimization: true }
 * );
 */
function calculatePollingInterval(deviceData, usageHistory, userPreferences) {
  // Step 1: Get base interval for device type
  const BASE_INTERVALS = {
    temperature_sensor: 300000,    // 5 minutes
    motion_detector: 30000,        // 30 seconds
    door_sensor: 10000,           // 10 seconds
    smart_switch: 60000,          // 1 minute
    camera: 120000                // 2 minutes
  };
  
  let baseInterval = BASE_INTERVALS[deviceData.deviceType] || 180000; // 3 min default
  
  // Step 2: Analyze usage patterns from historical data
  // Sort by timestamp and get recent activity levels
  const recentHistory = usageHistory
    .sort((a, b) => b.timestamp - a.timestamp)
    .slice(0, 100); // Last 100 data points
  
  const avgActivity = recentHistory.reduce((sum, point) => sum + point.activity, 0) / recentHistory.length;
  
  // Step 3: Apply battery level adjustments
  let batteryMultiplier = 1.0;
  if (!deviceData.isPluggedIn) {
    // Increase interval as battery decreases to preserve power
    if (deviceData.batteryLevel < 20) {
      batteryMultiplier = 3.0;      // Very conservative when low battery
    } else if (deviceData.batteryLevel < 50) {
      batteryMultiplier = 2.0;      // Moderate conservation
    } else {
      batteryMultiplier = 1.5;      // Slight conservation
    }
  }
  
  // Step 4: Apply user preference adjustments
  const responsivenessMultiplier = Math.pow(0.7, userPreferences.responsiveness - 3);
  const batteryOptMultiplier = userPreferences.batteryOptimization ? 1.5 : 1.0;
  
  // Step 5: Apply activity-based adjustments
  // Higher activity = shorter intervals for better responsiveness
  const activityMultiplier = Math.max(0.3, 1.0 - (avgActivity * 0.7));
  
  // Step 6: Calculate final interval with all factors
  const finalInterval = Math.round(
    baseInterval * 
    batteryMultiplier * 
    responsivenessMultiplier * 
    batteryOptMultiplier * 
    activityMultiplier
  );
  
  // Step 7: Apply reasonable bounds (min 10 seconds, max 1 hour)
  return Math.max(10000, Math.min(3600000, finalInterval));
}
```

## Firebase Functions Documentation Standards

### Cloud Function Documentation

```javascript
/**
 * Firebase Cloud Function for updating device sensor levels and status.
 * 
 * This function processes incoming sensor data from IoT devices and updates
 * the Firestore database with current readings. It also triggers notifications
 * for threshold violations and maintains device activity logs.
 * 
 * @function updateDeviceLevels
 * @type {functions.https.HttpsCallableFunction}
 * @access Private - Requires valid user authentication
 * @rateLimit 100 requests per minute per device
 * 
 * @param {Object} data - The sensor data from the client/device
 * @param {string} data.deviceId - Unique identifier for the reporting device
 * @param {Object} data.levels - Sensor readings object
 * @param {number} [data.levels.temperature] - Temperature in Celsius
 * @param {number} [data.levels.humidity] - Humidity percentage (0-100)
 * @param {number} [data.levels.batteryLevel] - Battery percentage (0-100)
 * @param {boolean} [data.levels.motionDetected] - Motion sensor status
 * @param {number} data.timestamp - Unix timestamp of the reading
 * @param {Object} context - Firebase Functions context object
 * @param {Object} context.auth - Authentication information
 * @param {string} context.auth.uid - User ID from Firebase Auth
 * 
 * @returns {Promise<Object>} Response object with update status
 * @returns {boolean} returns.success - Whether the update succeeded
 * @returns {string} returns.deviceId - The updated device ID
 * @returns {Object} returns.updatedLevels - The processed sensor levels
 * @returns {string[]} [returns.triggeredAlerts] - Array of alert IDs triggered
 * 
 * @throws {functions.https.HttpsError} unauthenticated - User not authenticated
 * @throws {functions.https.HttpsError} permission-denied - Device not owned by user
 * @throws {functions.https.HttpsError} invalid-argument - Invalid sensor data
 * @throws {functions.https.HttpsError} not-found - Device not found in database
 * @throws {functions.https.HttpsError} internal - Database or processing error
 * 
 * @example
 * // Client-side call from IoT device
 * const updateLevels = firebase.functions().httpsCallable('updateDeviceLevels');
 * const result = await updateLevels({
 *   deviceId: 'sensor_001',
 *   levels: {
 *     temperature: 22.5,
 *     humidity: 45,
 *     batteryLevel: 87
 *   },
 *   timestamp: Date.now()
 * });
 * 
 * @example
 * // Response format
 * {
 *   success: true,
 *   deviceId: 'sensor_001',
 *   updatedLevels: {
 *     temperature: 22.5,
 *     humidity: 45,
 *     batteryLevel: 87,
 *     lastUpdated: '2025-01-10T14:30:00Z'
 *   },
 *   triggeredAlerts: ['temp_high_alert_001']
 * }
 */
const updateDeviceLevels = functions.https.onCall(async (data, context) => {
  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to update device levels'
    );
  }

  // Implementation continues...
});

/**
 * HTTP trigger function for device webhook notifications.
 * 
 * Handles incoming HTTP POST requests from IoT devices that cannot
 * use the Firebase SDK directly. Validates device authentication
 * using pre-shared keys and forwards data to internal processing.
 * 
 * @function deviceWebhook
 * @type {functions.https.HttpsFunction}
 * @access Public - Uses PSK authentication
 * @rateLimit 1000 requests per minute globally
 * 
 * @param {functions.https.Request} req - Express request object
 * @param {Object} req.body - JSON payload from device
 * @param {string} req.body.deviceId - Device identifier
 * @param {string} req.body.psk - Pre-shared key for authentication
 * @param {Object} req.body.data - Sensor data payload
 * @param {functions.https.Response} res - Express response object
 * 
 * @returns {void} Sends HTTP response directly
 * 
 * @example
 * // HTTP POST to webhook endpoint
 * POST /deviceWebhook
 * Content-Type: application/json
 * 
 * {
 *   "deviceId": "sensor_001",
 *   "psk": "abc123def456...",
 *   "data": {
 *     "temperature": 22.5,
 *     "humidity": 45,
 *     "timestamp": 1641825600000
 *   }
 * }
 */
const deviceWebhook = functions.https.onRequest(async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Implementation continues...
});

module.exports = { updateDeviceLevels, deviceWebhook };
```

## Firestore Schema Documentation

```javascript
/**
 * @fileoverview Firestore Database Schema Documentation
 * 
 * This file documents the Firestore collections and document structures
 * used by the Firebase Functions in this project. All data access should
 * follow these schemas to ensure consistency and proper validation.
 */

/**
 * Users Collection Schema
 * 
 * Stores user account information and preferences for the household
 * automation system. Each document represents a single user account.
 * 
 * Collection Path: /users/{userId}
 * 
 * @typedef {Object} UserDocument
 * @property {string} userId - Firebase Auth UID, matches document ID
 * @property {string} email - User's email address from Firebase Auth
 * @property {string} displayName - User's display name for UI
 * @property {Object} preferences - User preference settings
 * @property {number} preferences.pollingInterval - Default device polling interval (ms)
 * @property {boolean} preferences.batteryOptimization - Prioritize battery life
 * @property {string[]} preferences.notificationTypes - Enabled notification types
 * @property {Object} deviceLimits - Account limits and quotas
 * @property {number} deviceLimits.maxDevices - Maximum devices allowed
 * @property {number} deviceLimits.currentDevices - Current device count
 * @property {Timestamp} createdAt - Account creation timestamp
 * @property {Timestamp} lastLoginAt - Last login timestamp
 * @property {boolean} isActive - Whether account is active
 * 
 * @example
 * // Example user document
 * {
 *   userId: "abc123def456",
 *   email: "user@example.com",
 *   displayName: "John Smith",
 *   preferences: {
 *     pollingInterval: 300000,
 *     batteryOptimization: true,
 *     notificationTypes: ["device_offline", "battery_low", "sensor_alert"]
 *   },
 *   deviceLimits: {
 *     maxDevices: 50,
 *     currentDevices: 12
 *   },
 *   createdAt: Timestamp,
 *   lastLoginAt: Timestamp,
 *   isActive: true
 * }
 */

/**
 * Devices Collection Schema
 * 
 * Stores information about IoT devices registered to user accounts.
 * Each device has its own document with current status and configuration.
 * 
 * Collection Path: /users/{userId}/devices/{deviceId}
 * 
 * @typedef {Object} DeviceDocument
 * @property {string} deviceId - Unique device identifier
 * @property {string} deviceName - Human-readable device name
 * @property {string} deviceType - Device category (sensor, controller, etc.)
 * @property {string} userId - Owner's user ID (redundant for security)
 * @property {string} psk - Pre-shared key for device authentication (encrypted)
 * @property {Object} currentLevels - Latest sensor readings
 * @property {number} [currentLevels.temperature] - Temperature in Celsius
 * @property {number} [currentLevels.humidity] - Humidity percentage (0-100)
 * @property {number} [currentLevels.batteryLevel] - Battery percentage (0-100)
 * @property {boolean} [currentLevels.motionDetected] - Motion sensor status
 * @property {Timestamp} currentLevels.lastUpdated - Timestamp of last reading
 * @property {Object} configuration - Device-specific settings
 * @property {number} configuration.pollingInterval - Custom polling interval (ms)
 * @property {Object} configuration.thresholds - Alert threshold values
 * @property {number} [configuration.thresholds.tempMin] - Minimum temperature alert
 * @property {number} [configuration.thresholds.tempMax] - Maximum temperature alert
 * @property {number} [configuration.thresholds.batteryLow] - Low battery threshold
 * @property {Object} status - Device operational status
 * @property {boolean} status.isOnline - Whether device is currently reachable
 * @property {boolean} status.isActive - Whether device is enabled
 * @property {Timestamp} status.lastSeen - Last communication timestamp
 * @property {string} status.firmwareVersion - Current firmware version
 * @property {Timestamp} createdAt - Device registration timestamp
 * @property {Timestamp} updatedAt - Last modification timestamp
 * 
 * @example
 * // Example device document
 * {
 *   deviceId: "sensor_001",
 *   deviceName: "Living Room Temperature Sensor",
 *   deviceType: "temperature_sensor",
 *   userId: "abc123def456",
 *   psk: "encrypted_psk_value",
 *   currentLevels: {
 *     temperature: 22.5,
 *     humidity: 45,
 *     batteryLevel: 87,
 *     lastUpdated: Timestamp
 *   },
 *   configuration: {
 *     pollingInterval: 300000,
 *     thresholds: {
 *       tempMin: 18,
 *       tempMax: 26,
 *       batteryLow: 20
 *     }
 *   },
 *   status: {
 *     isOnline: true,
 *     isActive: true,
 *     lastSeen: Timestamp,
 *     firmwareVersion: "1.2.3"
 *   },
 *   createdAt: Timestamp,
 *   updatedAt: Timestamp
 * }
 */

/**
 * Device History Subcollection Schema
 * 
 * Stores historical sensor readings for trend analysis and reporting.
 * Organized as a subcollection under each device document.
 * 
 * Collection Path: /users/{userId}/devices/{deviceId}/history/{timestamp}
 * 
 * @typedef {Object} DeviceHistoryDocument
 * @property {Timestamp} timestamp - Reading timestamp (also document ID)
 * @property {Object} levels - Sensor readings at this timestamp
 * @property {number} [levels.temperature] - Temperature reading
 * @property {number} [levels.humidity] - Humidity reading
 * @property {number} [levels.batteryLevel] - Battery level at time of reading
 * @property {boolean} [levels.motionDetected] - Motion detection status
 * @property {Object} metadata - Additional context information
 * @property {string} metadata.source - How reading was obtained (polling, webhook, etc.)
 * @property {number} metadata.signalStrength - Network signal strength (0-100)
 * @property {boolean} metadata.isEstimated - Whether reading is interpolated
 * 
 * @example
 * // Example history document
 * {
 *   timestamp: Timestamp,
 *   levels: {
 *     temperature: 22.5,
 *     humidity: 45,
 *     batteryLevel: 87
 *   },
 *   metadata: {
 *     source: "polling",
 *     signalStrength: 85,
 *     isEstimated: false
 *   }
 * }
 */

/**
 * Firestore Security Rules Reference
 * 
 * These rules should be applied in the Firebase Console to ensure
 * proper data access control and validation.
 * 
 * @example
 * // firestore.rules
 * rules_version = '2';
 * service cloud.firestore {
 *   match /databases/{database}/documents {
 *     // Users can only access their own data
 *     match /users/{userId} {
 *       allow read, write: if request.auth != null && request.auth.uid == userId;
 *       
 *       // Devices subcollection
 *       match /devices/{deviceId} {
 *         allow read, write: if request.auth != null && request.auth.uid == userId;
 *         
 *         // Device history subcollection
 *         match /history/{timestamp} {
 *           allow read, write: if request.auth != null && request.auth.uid == userId;
 *         }
 *       }
 *     }
 *   }
 * }
 */
```

## Error Documentation Standards

All error types and error handling must be thoroughly documented:

```javascript
/**
 * @fileoverview Custom Error Classes for Firebase Functions
 * 
 * This module defines custom error classes that extend Firebase Functions
 * HttpsError to provide structured error handling with consistent error
 * codes, user-friendly messages, and debugging information.
 */

const functions = require('firebase-functions');

/**
 * Base class for all device-related errors in the system.
 * 
 * This class provides structured error handling with consistent error
 * codes, user-friendly messages, and debugging information. All errors
 * include context for logging and user feedback.
 * 
 * @class DeviceError
 * @extends {functions.https.HttpsError}
 */
class DeviceError extends functions.https.HttpsError {
  /**
   * Creates a new device error with required information.
   * 
   * @param {string} code - Firebase Functions error code (invalid-argument, etc.)
   * @param {string} message - User-friendly error description
   * @param {Object} [details] - Additional error details and context
   * @param {string} [details.deviceId] - ID of the device that caused the error
   * @param {string} [details.userId] - ID of the user associated with the error
   * @param {string} [details.operation] - Operation that was being performed
   * @param {string} [details.errorCode] - Internal error code for tracking
   * @param {Object} [details.originalError] - Original error that was caught
   * 
   * @example
   * throw new DeviceError(
   *   'not-found',
   *   'The specified device could not be found',
   *   {
   *     deviceId: 'sensor_001',
   *     userId: 'user_123',
   *     operation: 'updateLevels',
   *     errorCode: 'DEVICE_NOT_FOUND'
   *   }
   * );
   */
  constructor(code, message, details = {}) {
    super(code, message, details);
    this.name = 'DeviceError';
    
    // Add timestamp for debugging
    this.details = {
      ...details,
      timestamp: new Date().toISOString(),
      errorType: 'DeviceError'
    };
  }
}

/**
 * Error thrown when device input fails validation requirements.
 * 
 * This error indicates that device data cannot be processed due to
 * missing, invalid, or malformed input. The error message should guide
 * users or devices toward providing correct input.
 * 
 * Common scenarios:
 * * Missing required fields in device registration
 * * Invalid sensor readings (out of range, wrong type)
 * * Malformed device identifiers or authentication keys
 * * Data that violates business rules or constraints
 * 
 * Recovery: Device or user should correct the input and retry the operation.
 * 
 * @class ValidationError
 * @extends {DeviceError}
 */
class ValidationError extends DeviceError {
  /**
   * Creates a validation error for specific field and value.
   * 
   * @param {string} message - User-friendly description of validation failure
   * @param {Object} details - Validation error details
   * @param {string} [details.field] - Name of the field that failed validation
   * @param {*} [details.invalidValue] - The value that was rejected
   * @param {string} [details.expectedFormat] - Description of expected format
   * @param {string} [details.deviceId] - Device ID associated with error
   * 
   * @example
   * throw new ValidationError(
   *   'Device name must be between 1 and 50 characters',
   *   {
   *     field: 'deviceName',
   *     invalidValue: '',
   *     expectedFormat: 'non-empty string, max 50 chars',
   *     deviceId: 'sensor_001'
   *   }
   * );
   */
  constructor(message, details = {}) {
    super('invalid-argument', message, {
      ...details,
      errorCode: 'VALIDATION_FAILED',
      errorType: 'ValidationError'
    });
    this.name = 'ValidationError';
  }

  /**
   * Creates a validation error for a missing required field.
   * 
   * @param {string} field - Name of the missing field
   * @param {string} [deviceId] - Device ID associated with error
   * @returns {ValidationError} Configured validation error
   * 
   * @example
   * throw ValidationError.missingField('deviceName', 'sensor_001');
   */
  static missingField(field, deviceId = null) {
    return new ValidationError(
      `The ${field} field is required but was not provided.`,
      {
        field: field,
        deviceId: deviceId,
        errorCode: 'MISSING_REQUIRED_FIELD'
      }
    );
  }

  /**
   * Creates a validation error for an invalid field format.
   * 
   * @param {string} field - Name of the field with invalid format
   * @param {string} expectedFormat - Description of expected format
   * @param {*} actualValue - The invalid value that was provided
   * @param {string} [deviceId] - Device ID associated with error
   * @returns {ValidationError} Configured validation error
   * 
   * @example
   * throw ValidationError.invalidFormat(
   *   'batteryLevel',
   *   'number between 0 and 100',
   *   -5,
   *   'sensor_001'
   * );
   */
  static invalidFormat(field, expectedFormat, actualValue, deviceId = null) {
    return new ValidationError(
      `The ${field} field must be in ${expectedFormat} format.`,
      {
        field: field,
        expectedFormat: expectedFormat,
        invalidValue: actualValue,
        deviceId: deviceId,
        errorCode: 'INVALID_FIELD_FORMAT'
      }
    );
  }
}

/**
 * Error thrown when device authentication fails.
 * 
 * This error indicates that a device could not be authenticated using
 * the provided credentials (PSK, device ID, etc.). This is a security-
 * sensitive error that should be logged but not expose detailed information.
 * 
 * @class AuthenticationError
 * @extends {DeviceError}
 */
class AuthenticationError extends DeviceError {
  /**
   * Creates an authentication error.
   * 
   * @param {string} message - User-friendly error message
   * @param {Object} details - Authentication error details
   * @param {string} [details.deviceId] - Device ID that failed authentication
   * @param {string} [details.authMethod] - Authentication method used
   * @param {string} [details.clientIP] - IP address of the client
   * 
   * @example
   * throw new AuthenticationError(
   *   'Device authentication failed',
   *   {
   *     deviceId: 'sensor_001',
   *     authMethod: 'psk',
   *     clientIP: '192.168.1.100'
   *   }
   * );
   */
  constructor(message, details = {}) {
    super('unauthenticated', message, {
      ...details,
      errorCode: 'DEVICE_AUTH_FAILED',
      errorType: 'AuthenticationError'
    });
    this.name = 'AuthenticationError';
  }
}

/**
 * Utility function for handling and logging errors consistently.
 * 
 * This function provides centralized error handling that logs errors
 * appropriately and converts them to Firebase Functions HttpsError
 * format for consistent client responses.
 * 
 * @param {Error} error - The error to handle
 * @param {string} operation - The operation that was being performed
 * @param {Object} [context] - Additional context for logging
 * @param {string} [context.userId] - User ID associated with operation
 * @param {string} [context.deviceId] - Device ID associated with operation
 * @throws {functions.https.HttpsError} Properly formatted error for client
 * 
 * @example
 * try {
 *   await updateDeviceInFirestore(deviceData);
 * } catch (error) {
 *   handleError(error, 'updateDeviceLevels', {
 *     userId: context.auth.uid,
 *     deviceId: data.deviceId
 *   });
 * }
 */
function handleError(error, operation, context = {}) {
  // Log error with context for debugging
  console.error(`Error in ${operation}:`, {
    error: error.message,
    stack: error.stack,
    context: context,
    timestamp: new Date().toISOString()
  });

  // If it's already a Firebase Functions error, re-throw it
  if (error instanceof functions.https.HttpsError) {
    throw error;
  }

  // Convert common error types to appropriate Firebase errors
  if (error.code === 'permission-denied') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'You do not have permission to perform this operation',
      { operation, ...context }
    );
  }

  if (error.code === 'not-found') {
    throw new functions.https.HttpsError(
      'not-found',
      'The requested resource was not found',
      { operation, ...context }
    );
  }

  // Default to internal error for unexpected errors
  throw new functions.https.HttpsError(
    'internal',
    'An unexpected error occurred. Please try again later.',
    { operation, ...context }
  );
}

module.exports = {
  DeviceError,
  ValidationError,
  AuthenticationError,
  handleError
};
```

## Testing Documentation Standards

All tests must include comprehensive documentation:

```javascript
/**
 * @fileoverview Test suite for addDeviceToUser Firebase Function
 * 
 * This test suite covers all functionality and edge cases for the
 * addDeviceToUser Cloud Function, ensuring reliable behavior across
 * different scenarios and error conditions.
 * 
 * Test Categories:
 * * Authentication and authorization validation
 * * Device registration workflow
 * * Input validation and sanitization
 * * Error handling and recovery
 * * Firestore integration and data consistency
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations
 * * Firebase Functions SDK - Mocked for context and errors
 * * Crypto module - Mocked for predictable key generation
 * 
 * @requires jest
 * @requires firebase-functions-test
 */

const test = require('firebase-functions-test')();
const admin = require('firebase-admin');
const { addDeviceToUser } = require('../src/addDeviceToUser');

// Mock Firebase Admin SDK
jest.mock('firebase-admin', () => ({
  firestore: jest.fn(() => ({
    collection: jest.fn(),
    doc: jest.fn(),
    batch: jest.fn()
  })),
  auth: jest.fn(() => ({
    getUser: jest.fn()
  }))
}));

/**
 * Test suite for addDeviceToUser function.
 * 
 * Covers the complete device registration workflow including validation,
 * authentication, Firestore operations, and error handling scenarios.
 */
describe('addDeviceToUser', () => {
  let mockFirestore;
  let mockAuth;
  let mockContext;

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

    // Set up Firestore mocks
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      get: jest.fn(),
      set: jest.fn(),
      update: jest.fn(),
      batch: jest.fn(() => ({
        set: jest.fn(),
        update: jest.fn(),
        commit: jest.fn()
      }))
    };

    // Set up Auth mocks
    mockAuth = {
      getUser: jest.fn()
    };

    // Configure admin SDK mocks
    admin.firestore.mockReturnValue(mockFirestore);
    admin.auth.mockReturnValue(mockAuth);

    // Set up default context with authenticated user
    mockContext = {
      auth: {
        uid: 'test_user_123',
        token: {
          email: 'test@example.com'
        }
      }
    };
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
  describe('authentication', () => {
    /**
     * Verifies that unauthenticated requests are properly rejected.
     * 
     * This test ensures that the function fails fast with clear error
     * messages when no authentication context is provided, preventing
     * unauthorized device registrations.
     */
    test('should reject unauthenticated requests', async () => {
      // Arrange: Remove authentication from context
      const unauthenticatedContext = { auth: null };
      const deviceData = {
        deviceId: 'sensor_001',
        deviceName: 'Test Sensor',
        deviceType: 'temperature_sensor'
      };

      // Act & Assert: Expect authentication error
      await expect(
        addDeviceToUser(deviceData, unauthenticatedContext)
      ).rejects.toThrow('unauthenticated');
    });

    /**
     * Verifies that requests with invalid authentication tokens are rejected.
     * 
     * This test ensures that malformed or expired authentication tokens
     * are properly detected and rejected with appropriate error messages.
     */
    test('should reject requests with invalid auth tokens', async () => {
      // Arrange: Set up context with malformed auth
      const invalidContext = {
        auth: {
          uid: null, // Invalid UID
          token: {}
        }
      };
      const deviceData = {
        deviceId: 'sensor_001',
        deviceName: 'Test Sensor',
        deviceType: 'temperature_sensor'
      };

      // Act & Assert: Expect authentication error
      await expect(
        addDeviceToUser(deviceData, invalidContext)
      ).rejects.toThrow('unauthenticated');
    });
  });

  /**
   * Test group for device registration workflow scenarios.
   * 
   * Covers the happy path and various edge cases in the device
   * registration process, including data validation and storage.
   */
  describe('device registration', () => {
    /**
     * Tests successful device registration with valid input data.
     * 
     * This test verifies the complete happy path workflow:
     * 1. User authentication is validated
     * 2. Device data is validated and sanitized
     * 3. Unique device ID and PSK are generated
     * 4. Device is stored in Firestore with proper structure
     * 5. User device count is updated
     * 6. Success response is returned with device information
     */
    test('should register device successfully with valid data', async () => {
      // Arrange: Set up successful Firestore responses
      const deviceData = {
        deviceId: 'sensor_001',
        deviceName: 'Living Room Temperature Sensor',
        deviceType: 'temperature_sensor'
      };

      // Mock user document exists and has space for more devices
      mockFirestore.get.mockResolvedValueOnce({
        exists: true,
        data: () => ({
          deviceLimits: {
            maxDevices: 50,
            currentDevices: 5
          }
        })
      });

      // Mock device doesn't already exist
      mockFirestore.get.mockResolvedValueOnce({
        exists: false
      });

      // Mock successful Firestore operations
      mockFirestore.set.mockResolvedValue();
      mockFirestore.update.mockResolvedValue();

      // Act: Call function with valid data
      const result = await addDeviceToUser(deviceData, mockContext);

      // Assert: Verify successful registration and response structure
      expect(result).toEqual({
        success: true,
        deviceId: 'sensor_001',
        psk: expect.any(String),
        message: 'Device registered successfully'
      });

      // Verify Firestore operations were called correctly
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('test_user_123');
      expect(mockFirestore.set).toHaveBeenCalled();
      expect(mockFirestore.update).toHaveBeenCalled();
    });

    /**
     * Tests device registration failure when user has reached device limit.
     * 
     * This test ensures that the system properly enforces device limits
     * and provides clear error messages when users attempt to exceed
     * their allowed device quota.
     */
    test('should reject registration when device limit exceeded', async () => {
      // Arrange: Set up user at device limit
      const deviceData = {
        deviceId: 'sensor_001',
        deviceName: 'Test Sensor',
        deviceType: 'temperature_sensor'
      };

      mockFirestore.get.mockResolvedValueOnce({
        exists: true,
        data: () => ({
          deviceLimits: {
            maxDevices: 50,
            currentDevices: 50 // At limit
          }
        })
      });

      // Act & Assert: Expect quota exceeded error
      await expect(
        addDeviceToUser(deviceData, mockContext)
      ).rejects.toThrow('permission-denied');
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
     * Tests validation of required fields in device data.
     * 
     * This test ensures that all required fields are validated and
     * that missing fields result in clear, actionable error messages.
     */
    test('should validate required fields', async () => {
      // Test missing deviceId
      await expect(
        addDeviceToUser({
          deviceName: 'Test Sensor',
          deviceType: 'temperature_sensor'
        }, mockContext)
      ).rejects.toThrow('invalid-argument');

      // Test missing deviceName
      await expect(
        addDeviceToUser({
          deviceId: 'sensor_001',
          deviceType: 'temperature_sensor'
        }, mockContext)
      ).rejects.toThrow('invalid-argument');

      // Test missing deviceType
      await expect(
        addDeviceToUser({
          deviceId: 'sensor_001',
          deviceName: 'Test Sensor'
        }, mockContext)
      ).rejects.toThrow('invalid-argument');
    });

    /**
     * Tests validation of device name format and constraints.
     * 
     * This test verifies that device names are properly validated
     * for length, character restrictions, and other business rules.
     */
    test('should validate device name format', async () => {
      const baseDeviceData = {
        deviceId: 'sensor_001',
        deviceType: 'temperature_sensor'
      };

      // Test empty device name
      await expect(
        addDeviceToUser({
          ...baseDeviceData,
          deviceName: ''
        }, mockContext)
      ).rejects.toThrow('invalid-argument');

      // Test device name too long
      await expect(
        addDeviceToUser({
          ...baseDeviceData,
          deviceName: 'A'.repeat(51) // Exceeds 50 character limit
        }, mockContext)
      ).rejects.toThrow('invalid-argument');

      // Test device name with invalid characters
      await expect(
        addDeviceToUser({
          ...baseDeviceData,
          deviceName: 'Test<script>alert("xss")</script>'
        }, mockContext)
      ).rejects.toThrow('invalid-argument');
    });
  });
});
```

## Enforcement and Quality Assurance

### Documentation Review Checklist

Before any code is considered complete, verify:

- [ ] Every class has a comprehensive doc comment with purpose and usage
- [ ] Every public method has parameter and return value documentation
- [ ] Every field/property has a clear description of its purpose
- [ ] Complex algorithms include step-by-step explanations
- [ ] Error conditions and exceptions are documented
- [ ] Examples are provided for non-trivial usage patterns
- [ ] Dependencies and relationships are clearly explained
- [ ] Performance characteristics are noted where relevant
- [ ] Thread safety and concurrency considerations are documented
- [ ] Deprecation notices include migration guidance

### Documentation Quality Standards

Documentation must be:

1. **Accurate**: Reflects the actual behavior of the code
2. **Complete**: Covers all public interfaces and important private methods
3. **Clear**: Written in plain language accessible to other developers
4. **Consistent**: Follows established patterns and terminology
5. **Maintainable**: Updated whenever code changes
6. **Actionable**: Provides concrete guidance for usage and troubleshooting

### Automated Documentation Validation

All documentation should be validated through:

- Linting tools that enforce documentation coverage
- Automated checks for outdated documentation
- Integration with CI/CD pipelines to prevent undocumented code
- Regular documentation audits and quality reviews

Remember: **Undocumented code is incomplete code.** Every line of code written for this project must include appropriate documentation that enables future developers to understand, maintain, and extend the system effectively.