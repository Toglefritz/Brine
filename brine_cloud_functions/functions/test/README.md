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
```

## Test Structure

- `addDeviceToUser.test.cjs` - Comprehensive tests for the addDeviceToUser function
- `setup.cjs` - Global Jest configuration and mocks

## Test Coverage

The tests cover:
- Input validation (missing/invalid parameters)
- User document handling (existence, retrieval errors)
- Device addition to user's device list
- Device document creation in devices collection
- Error handling for all Firestore operations
- Edge cases (null/undefined arrays, existing devices)

## Mocking Strategy

The tests use Jest mocks to:
- Mock Firebase Admin SDK and Firestore operations
- Mock console methods to reduce test output noise
- Mock Date objects for predictable timestamps
- Isolate the function under test from external dependencies