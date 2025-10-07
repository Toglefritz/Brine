# Testing Guide

## Running Tests

To run the tests for the Firebase Functions:

```bash
# Install dependencies (if not already installed)
npm install

# Run all tests
npm test

# Run tests in watch mode (re-runs tests when files change)
npm run test:watch

# Run tests with coverage report
npm test -- --coverage

# Run specific test suites
npm run test:addDevice      # Run addDeviceToUser tests only
npm run test:addFcmToken    # Run addFcmToken tests only
npm run test:addLead        # Run addLead tests only
npm run test:createUser     # Run createUser tests only
npm run test:deleteUser     # Run deleteUser tests only
npm run test:generatePSK    # Run generatePSK tests only
npm run test:getDevice      # Run getDevice tests only
npm run test:getUserDevices # Run getUserDevices tests only
```

## Test Structure

- `addDeviceToUser.test.cjs` - Comprehensive tests for the addDeviceToUser function
- `addFcmToken.test.cjs` - Comprehensive tests for the addFcmToken function
- `addLead.test.cjs` - Comprehensive tests for the addLead function
- `createUser.test.cjs` - Comprehensive tests for the createUser function
- `deleteUser.test.cjs` - Comprehensive tests for the deleteUser function
- `generatePSK.test.cjs` - Comprehensive tests for the generatePSK function
- `getDevice.test.cjs` - Comprehensive tests for the getDevice function
- `getUserDevices.test.cjs` - Comprehensive tests for the getUserDevices function
- `setup.cjs` - Global Jest configuration and mocks

## Test Coverage

### addDeviceToUser Tests
The tests cover:
- Input validation (missing/invalid parameters)
- User document handling (existence, retrieval errors)
- Device addition to user's device list
- Device document creation in devices collection
- Error handling for all Firestore operations
- Edge cases (null/undefined arrays, existing devices)

### addFcmToken Tests
The tests cover:
- Input validation (missing/invalid FCM tokens)
- User document handling (existence, retrieval errors)
- FCM token array management and updates
- Duplicate token prevention
- Error handling for all Firestore operations
- Edge cases (null/undefined token arrays)

### addLead Tests
The tests cover:
- Input validation (missing/invalid name and email parameters)
- Lead document creation with proper structure and timestamps
- Error handling for Firestore document creation failures
- Edge cases (special characters, whitespace handling)
- Firestore integration and collection access validation

### createUser Tests
The tests cover:
- User document creation with proper structure and field initialization
- Authentication context handling and UID extraction
- Error handling for Firestore document creation failures
- Edge cases (long UIDs, special characters in UIDs)
- Firestore integration and database operation validation
- Document structure validation and field type verification

### deleteUser Tests
The tests cover:
- User document deletion with existence checking
- Document existence validation and handling of non-existent documents
- Authentication context handling and UID extraction
- Error handling for Firestore document retrieval and deletion failures
- Edge cases (long UIDs, special characters in UIDs)
- Firestore integration and database operation sequence validation

### generatePSK Tests
The tests cover:
- HTTP method validation (POST only acceptance)
- Input validation (deviceId parameter validation)
- Cryptographically secure PSK generation using crypto.randomBytes
- Firestore storage with proper document structure and metadata
- Error handling for database storage failures
- Edge cases (long device IDs, special characters in device IDs)
- Security validation (proper key length, encoding, and format)
- Response formatting and JSON structure validation

### getDevice Tests
The tests cover:
- Input validation (deviceId query parameter validation)
- User authentication and document existence validation
- Device document retrieval from Firestore
- Access control and authorization (user must own device)
- Error handling for database retrieval failures
- Edge cases (null/undefined device arrays, long device IDs)
- Response formatting and JSON structure validation
- Firestore integration and operation sequence validation

### getUserDevices Tests
The tests cover:
- User authentication and document existence validation
- Device list retrieval and processing from user's device array
- Device detail fetching with filtering of non-existent devices
- Error handling for database retrieval failures
- Edge cases (null/undefined device arrays, large device lists)
- Response formatting and JSON structure validation
- Firestore integration and operation sequence validation
- Performance scenarios with multiple device retrievals

## Mocking Strategy

The tests use Jest mocks to:
- Mock Firebase Admin SDK and Firestore operations
- Mock console methods to reduce test output noise
- Mock Date objects for predictable timestamps (where needed)
- Isolate the functions under test from external dependencies
- Provide comprehensive coverage of all code paths and error scenarios

## Documentation Standards

All test files follow comprehensive documentation standards including:
- Detailed JSDoc comments for all test functions and mock objects
- Clear explanations of test scenarios and expected behaviors
- Comprehensive coverage of edge cases and error conditions
- Integration testing validation for database operations