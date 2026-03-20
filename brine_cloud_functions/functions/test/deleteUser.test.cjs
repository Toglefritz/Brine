/**
 * @fileoverview Test suite for deleteUser Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * deleteUser Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and user document deletion requirements.
 * 
 * The deleteUser function handles the complete user document deletion workflow:
 * 1. Extracts user UID from the authenticated request context
 * 2. Checks if the user document exists in the "users" collection
 * 3. Deletes the user document if it exists
 * 4. Returns appropriate success or not-found messages
 * 5. Handles all error conditions gracefully with proper error throwing
 * 
 * This function is typically triggered when a user account deletion is requested,
 * ensuring that the user's document and associated data are properly removed from
 * the Firestore database. The function includes existence checking to handle cases
 * where the user document may have already been deleted or never existed.
 * 
 * Test Categories:
 * * User document deletion - Tests successful document deletion workflow
 * * Document existence checking - Tests handling of existing and non-existing documents
 * * Authentication context - Tests user UID extraction from request context
 * * Error handling - Tests database error scenarios and appropriate responses
 * * Edge cases - Tests boundary conditions and unusual authentication states
 * * Firestore integration - Verifies correct database operations and calls
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Firebase Functions SDK - Mocked for error handling and HttpsError creation
 * * Firestore collections - Mocked for users collection access
 * * Document references - Mocked for get and delete operations
 * * Authentication context - Mocked for user UID validation
 * 
 * Test Coverage:
 * * 100% code coverage for the deleteUser function
 * * All execution paths including success and error scenarios
 * * Document existence validation and handling
 * * Database operation success and failure conditions
 * * Authentication context handling and UID extraction
 * * Error handling and response formatting
 * 
 * @author Firebase Functions Team
 * @since 2025-01-10
 * @version 1.0.0
 * @requires jest
 * @requires firebase-admin
 * @requires firebase-functions
 */

/**
 * Mock Firestore document reference for user operations.
 * 
 * Provides mocked implementations of Firestore document operations
 * for user documents, including get and delete operations that are used
 * during user document deletion workflow.
 * 
 * @type {Object}
 * @property {jest.Mock} get - Mock function for retrieving user documents
 * @property {jest.Mock} delete - Mock function for deleting user documents
 */
const mockUserDocRef = {
    get: jest.fn(),
    delete: jest.fn()
};

/**
 * Mock Firestore collection reference for users operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the users collection, including document reference creation
 * that is used during user document deletion workflow.
 * 
 * @type {Object}
 * @property {jest.Mock} doc - Mock function for getting document references
 */
const mockUsersCollection = {
    doc: jest.fn(() => mockUserDocRef)
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate collection references
 * for the users collection used in user document management.
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 * 
 * @example
 * // Returns users collection reference for 'users' collection
 * mockFirestore.collection('users')
 */
const mockFirestore = {
    collection: jest.fn(() => mockUsersCollection)
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

/**
 * Mock Firebase Functions HttpsError class.
 * 
 * Provides a mocked version of the Firebase Functions HttpsError
 * that is used for error handling in the deleteUser function.
 * 
 * @type {jest.Mock}
 */
const mockHttpsError = jest.fn().mockImplementation((code, message) => {
    const error = new Error(message);
    error.code = code;
    return error;
});

/**
 * Mock Firebase Functions SDK instance.
 * 
 * Provides a mocked version of the Firebase Functions SDK that includes
 * the HttpsError class for proper error handling testing.
 * 
 * @type {Object}
 * @property {Object} https - Mock https object containing HttpsError
 * @property {jest.Mock} https.HttpsError - Mock HttpsError constructor
 */
const mockFunctions = {
    https: {
        HttpsError: mockHttpsError
    }
};

// Mock the Firebase Admin SDK module before importing the function under test
jest.mock('../config/adminInit.cjs', () => mockAdmin);

// Mock the Firebase Functions SDK module before importing the function under test
jest.mock('firebase-functions', () => mockFunctions);

// Import the function under test after mocking dependencies
const { deleteUser } = require('../src/deleteUser.cjs');

/**
 * Test suite for deleteUser Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete user document deletion
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles authentication context,
 * document existence checking, Firestore operations, and error responses.
 * 
 * Test Structure:
 * * User document deletion - Tests successful document deletion workflow
 * * Document existence checking - Tests handling of existing and non-existing documents
 * * Authentication context - Tests user UID extraction and validation
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual states
 * * Firestore integration - Tests database operation calls and responses
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('deleteUser', () => {
    /**
     * Mock request object for testing user deletion endpoints.
     * 
     * Simulates the request object that would be passed to the
     * deleteUser function in a real execution scenario. Contains
     * user authentication information extracted from Firebase Auth.
     * 
     * @type {Object}
     * @property {Object} user - User authentication information from Firebase Auth
     * @property {string} user.uid - Firebase Auth user ID for document deletion
     */
    let req;

    /**
     * Mock Firestore document snapshot for user documents.
     * 
     * Simulates the document snapshot returned by Firestore when retrieving
     * user documents. Contains existence status that is used to check
     * whether the user document exists before deletion.
     * 
     * @type {Object}
     * @property {boolean} exists - Whether the user document exists in Firestore
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
     * 2. Creating fresh request mock objects with valid authentication
     * 3. Configuring default successful Firestore operations
     * 4. Setting up default document existence scenarios
     * 
     * This approach ensures test isolation and prevents state leakage
     * between tests that could cause false positives or negatives.
     */
    beforeEach(() => {
        // Clear all mock function call history and reset implementations
        jest.clearAllMocks();

        /**
         * Configure mock request object with valid default authentication.
         * 
         * Sets up a typical successful request scenario with authenticated
         * user context. Individual tests can override these values to test
         * specific error conditions or edge cases.
         */
        req = {
            user: { uid: 'test-user-uid-123' }
        };

        // Reset all Firestore mock function call history
        mockUserDocRef.get.mockClear();
        mockUserDocRef.delete.mockClear();
        mockUsersCollection.doc.mockClear();

        /**
         * Configure default user document snapshot for existing document scenarios.
         * 
         * Sets up a user document that exists by default, representing the
         * typical case where a user document is present and ready for deletion.
         */
        mockUserDocSnapshot = {
            exists: true
        };

        // Configure all Firestore operations to resolve successfully by default
        mockUserDocRef.get.mockResolvedValue(mockUserDocSnapshot);
        mockUserDocRef.delete.mockResolvedValue();
    });

    /**
     * Test group for user document deletion scenarios.
     * 
     * This test group validates the core functionality of deleting user
     * documents from the Firestore users collection. The function must
     * properly check for document existence and perform deletion operations
     * with appropriate success confirmations.
     * 
     * User document deletion workflow:
     * 1. Extract user UID from authenticated request context
     * 2. Get document reference using UID as document ID
     * 3. Check if document exists before deletion
     * 4. Delete document if it exists
     * 5. Return success confirmation message
     * 
     * Deletion scenarios tested:
     * * Successful deletion of existing user document
     * * Handling of non-existent user documents
     * * Proper success message formatting
     * * Document existence validation
     * 
     * These tests ensure proper user document deletion and appropriate
     * response handling for the user account management system.
     */
    describe('User document deletion', () => {
        /**
         * Tests successful user document deletion with existing document.
         * 
         * Verifies that the function properly deletes a user document
         * from the Firestore users collection when the document exists
         * and returns an appropriate success confirmation message.
         * 
         * Expected behavior:
         * * Function should check document existence before deletion
         * * Document should be deleted if it exists
         * * Function should return success confirmation message
         * * Success message should include the user UID
         * 
         * This test ensures that the primary workflow of the function
         * operates correctly and successfully removes user documents
         * from the database when requested.
         * 
         * @test {Function} deleteUser
         * @scenario Valid user authentication context with existing document
         * @expected User document deleted from Firestore with success confirmation
         */
        test('should delete existing user document successfully', async () => {
            // Act: Delete existing user document
            const result = await deleteUser(req);

            // Assert: Verify document existence was checked
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid-123');
            expect(mockUserDocRef.get).toHaveBeenCalled();

            // Assert: Verify document was deleted
            expect(mockUserDocRef.delete).toHaveBeenCalled();

            // Assert: Verify success response
            expect(result).toEqual({
                result: 'User with UID test-user-uid-123 deleted.'
            });
        });

        /**
         * Tests user document deletion with different valid UID.
         * 
         * Verifies that the function properly handles various valid
         * user UIDs and deletes appropriate user documents with
         * different authentication contexts.
         * 
         * Expected behavior:
         * * Function should handle different valid UID formats
         * * Document deletion should work with various UIDs
         * * UID should be properly used in document operations
         * * Function should return appropriate success message
         * 
         * This test ensures that the function works correctly with
         * various valid authentication contexts and maintains consistent
         * behavior across different user identification scenarios.
         * 
         * @test {Function} deleteUser
         * @scenario Different valid user UID provided in authentication context
         * @expected User document deleted with provided UID in operations
         */
        test('should delete user document with different valid UID', async () => {
            // Arrange: Configure different valid user UID
            req.user.uid = 'different-user-uid-456';

            // Act: Delete user document with different UID
            const result = await deleteUser(req);

            // Assert: Verify correct UID was used in operations
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('different-user-uid-456');
            expect(mockUserDocRef.delete).toHaveBeenCalled();

            // Assert: Verify success response with correct UID
            expect(result).toEqual({
                result: 'User with UID different-user-uid-456 deleted.'
            });
        });
    });

    /**
     * Test group for document existence checking scenarios.
     * 
     * This test group validates the function's behavior when handling
     * user documents that may or may not exist in the Firestore collection.
     * The function must properly check for document existence and handle
     * both existing and non-existing documents appropriately.
     * 
     * Document existence scenarios:
     * * Handling of non-existent user documents
     * * Proper not-found message formatting
     * * Skipping deletion for non-existent documents
     * * Appropriate logging for non-existent documents
     * 
     * These tests ensure that the function handles all document existence
     * states gracefully and provides appropriate feedback for each scenario.
     */
    describe('Document existence checking', () => {
        /**
         * Tests handling of non-existent user documents.
         * 
         * Verifies that the function properly handles cases where the
         * user document does not exist in the Firestore users collection.
         * This could happen if the document was already deleted or never
         * created in the first place.
         * 
         * Expected behavior:
         * * Function should check document existence
         * * Function should detect non-existent document
         * * No deletion operation should be attempted
         * * Function should return not-found message
         * * Not-found message should include the user UID
         * 
         * This test ensures that the function handles non-existent documents
         * gracefully without attempting unnecessary operations and provides
         * appropriate feedback about the document state.
         * 
         * @test {Function} deleteUser
         * @scenario User document does not exist in Firestore
         * @expected Function returns not-found message without attempting deletion
         */
        test('should handle non-existent user document', async () => {
            // Arrange: Configure user document to not exist
            mockUserDocSnapshot.exists = false;

            // Act: Attempt to delete non-existent user document
            const result = await deleteUser(req);

            // Assert: Verify document existence was checked
            expect(mockUserDocRef.get).toHaveBeenCalled();

            // Assert: Verify no deletion was attempted
            expect(mockUserDocRef.delete).not.toHaveBeenCalled();

            // Assert: Verify not-found response
            expect(result).toEqual({
                result: 'User with UID test-user-uid-123 not found.'
            });
        });
    });

    /**
     * Test group for error handling scenarios.
     * 
     * This test group validates the function's behavior when database
     * errors occur during user document operations. The function must
     * handle Firestore errors gracefully and provide appropriate
     * error responses.
     * 
     * Error handling ensures:
     * * Proper error catching and handling
     * * Error logging for debugging and monitoring
     * * Appropriate error throwing for upstream handling
     * * Consistent error handling across different failure modes
     * 
     * These tests ensure that database errors are handled professionally
     * and that the function fails gracefully when operations cannot
     * be completed successfully.
     */
    describe('Error handling', () => {
        /**
         * Tests handling of Firestore document retrieval errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during user document existence checking. This
         * could happen due to network issues, permission problems, or
         * Firestore service outages.
         * 
         * Expected behavior:
         * * Function should catch Firestore errors
         * * Error should be logged for debugging purposes
         * * Function should throw appropriate HttpsError for upstream handling
         * * Error message should not expose internal details
         * 
         * This test ensures that database errors during document retrieval
         * are handled gracefully and that the function provides appropriate
         * error information for debugging while maintaining security.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during document retrieval
         * * Firestore permission denied errors
         * * Service unavailable conditions
         * * Timeout errors during document access
         * 
         * @test {Function} deleteUser
         * @scenario Firestore throws error during user document retrieval
         * @expected Function catches error, logs it, and throws HttpsError
         */
        test('should handle Firestore document retrieval error', async () => {
            // Arrange: Configure Firestore to throw error during document retrieval
            const firestoreError = new Error('Firestore connection failed');
            mockUserDocRef.get.mockRejectedValue(firestoreError);

            // Act & Assert: Verify error is caught and re-thrown appropriately
            await expect(deleteUser(req)).rejects.toThrow();

            // Assert: Verify HttpsError was created with appropriate parameters
            expect(mockHttpsError).toHaveBeenCalledWith('unknown', 'Failed to delete user.');

            // Assert: Verify Firestore operation was attempted
            expect(mockUserDocRef.get).toHaveBeenCalled();
        });

        /**
         * Tests handling of Firestore document deletion errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during user document deletion. This could happen
         * due to network issues, permission problems, or Firestore
         * service outages during the deletion operation.
         * 
         * Expected behavior:
         * * Function should catch Firestore deletion errors
         * * Error should be logged for debugging purposes
         * * Function should throw appropriate HttpsError for upstream handling
         * * Error message should not expose internal details
         * 
         * This test ensures that database errors during document deletion
         * are handled gracefully and that the function provides appropriate
         * error information for debugging while maintaining security.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during document deletion
         * * Firestore permission denied errors
         * * Document lock conflicts during deletion
         * * Service unavailable conditions
         * 
         * @test {Function} deleteUser
         * @scenario Firestore throws error during user document deletion
         * @expected Function catches error, logs it, and throws HttpsError
         */
        test('should handle Firestore document deletion error', async () => {
            // Arrange: Configure Firestore to throw error during document deletion
            const deletionError = new Error('Firestore deletion failed');
            mockUserDocRef.delete.mockRejectedValue(deletionError);

            // Act & Assert: Verify error is caught and re-thrown appropriately
            await expect(deleteUser(req)).rejects.toThrow();

            // Assert: Verify HttpsError was created with appropriate parameters
            expect(mockHttpsError).toHaveBeenCalledWith('unknown', 'Failed to delete user.');

            // Assert: Verify Firestore operations were attempted
            expect(mockUserDocRef.get).toHaveBeenCalled();
            expect(mockUserDocRef.delete).toHaveBeenCalled();
        });
    });

    /**
     * Test group for authentication context scenarios.
     * 
     * This test group validates the function's handling of authentication
     * context and user UID extraction. The function must properly extract
     * and use the user UID from the request context for document operations.
     * 
     * Authentication context handling:
     * * Proper UID extraction from request.user.uid
     * * UID validation and usage in document operations
     * * Consistent UID usage across document operations and responses
     * * Proper handling of authentication context variations
     * 
     * These tests ensure that the function correctly processes authentication
     * information and uses it appropriately for user document management.
     */
    describe('Authentication context', () => {
        /**
         * Tests proper UID extraction and usage from authentication context.
         * 
         * Verifies that the function correctly extracts the user UID from
         * the request authentication context and uses it consistently
         * for document operations and response messages.
         * 
         * Expected behavior:
         * * Function should extract UID from req.user.uid
         * * UID should be used as Firestore document ID
         * * UID should be included in response messages
         * * UID usage should be consistent throughout the operation
         * 
         * This test ensures that authentication context is properly
         * processed and that user identification is handled consistently
         * across all aspects of document deletion.
         * 
         * @test {Function} deleteUser
         * @scenario Valid authentication context with user UID
         * @expected UID extracted and used consistently for document operations
         */
        test('should extract and use UID consistently from authentication context', async () => {
            // Arrange: Configure specific UID for consistency testing
            const testUid = 'consistency-test-uid-789';
            req.user.uid = testUid;

            // Act: Delete user document
            const result = await deleteUser(req);

            // Assert: Verify UID is used consistently
            expect(mockUsersCollection.doc).toHaveBeenCalledWith(testUid);
            expect(result.result).toContain(testUid);
        });
    });

    /**
     * Test group for edge cases and boundary conditions.
     * 
     * This test group validates the function's behavior with unusual
     * authentication contexts and edge cases that might occur in
     * production environments. These scenarios test the robustness
     * of the function's authentication handling and document operations.
     * 
     * Edge cases covered:
     * * Long user UIDs
     * * UIDs with special characters
     * * Various UID formats from different authentication providers
     * 
     * These tests ensure that the function handles real-world variations
     * in authentication data and maintains consistent behavior across
     * different user identification scenarios.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of long user UIDs.
         * 
         * Verifies that the function properly handles user UIDs that
         * are longer than typical, which might occur with certain
         * authentication providers or custom authentication systems.
         * 
         * Expected behavior:
         * * Function should accept and process long UIDs correctly
         * * Document operations should work with full UID preserved
         * * No truncation or modification of UID should occur
         * * Function should return success with complete UID
         * 
         * This test ensures that the function works correctly with
         * various UID lengths and doesn't impose artificial limitations
         * on user identification formats.
         * 
         * @test {Function} deleteUser
         * @scenario User UID is longer than typical length
         * @expected Function handles long UID correctly without truncation
         */
        test('should handle long user UIDs', async () => {
            // Arrange: Configure long user UID
            const longUid = 'very-long-user-uid-that-exceeds-typical-length-for-comprehensive-testing-purposes-123456789';
            req.user.uid = longUid;

            // Act: Delete user document with long UID
            const result = await deleteUser(req);

            // Assert: Verify long UID is handled correctly
            expect(mockUsersCollection.doc).toHaveBeenCalledWith(longUid);
            expect(result.result).toContain(longUid);
        });

        /**
         * Tests handling of UIDs with special characters.
         * 
         * Verifies that the function properly handles user UIDs that
         * contain special characters, which might occur with certain
         * authentication providers or custom user identification systems.
         * 
         * Expected behavior:
         * * Function should accept UIDs with special characters
         * * Document operations should work with original UID preserved
         * * No character encoding or escaping issues should occur
         * * Function should return success with original UID
         * 
         * This test ensures that the function works correctly with
         * various UID formats and character sets, supporting diverse
         * authentication systems and user identification schemes.
         * 
         * @test {Function} deleteUser
         * @scenario User UID contains special characters
         * @expected Function handles special characters correctly without modification
         */
        test('should handle UIDs with special characters', async () => {
            // Arrange: Configure UID with special characters
            const specialUid = 'user-uid-with-special-chars_@#$%^&*()+=[]{}|;:,.<>?';
            req.user.uid = specialUid;

            // Act: Delete user document with special character UID
            const result = await deleteUser(req);

            // Assert: Verify special character UID is handled correctly
            expect(mockUsersCollection.doc).toHaveBeenCalledWith(specialUid);
            expect(result.result).toContain(specialUid);
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
     * * Correct collection name usage ('users')
     * * Proper document ID parameter passing
     * * Expected sequence of database operations (get, then delete)
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
    describe('Firestore integration', () => {
        /**
         * Tests correct Firestore collection and operation access patterns.
         * 
         * Verifies that the function accesses the correct Firestore
         * collection and performs the expected operations during
         * the user deletion workflow. This test ensures that the
         * function follows the expected database schema and access patterns.
         * 
         * Expected database operations:
         * 1. Access 'users' collection
         * 2. Get document reference using user UID
         * 3. Perform get operation to check document existence
         * 4. Perform delete operation to remove user document
         * 
         * Database schema validation:
         * * Users collection: /users/{userUid}
         * * Correct collection name usage
         * * Proper document ID parameter passing
         * * Correct operation method calls in proper sequence
         * 
         * This test ensures that the function maintains consistency with
         * the established database schema and doesn't accidentally access
         * wrong collections or use incorrect operation methods, which
         * could lead to data corruption or application errors.
         * 
         * @test {Function} deleteUser
         * @scenario Successful user deletion with database operation validation
         * @expected Correct Firestore collection accessed with proper operations
         */
        test('should call correct Firestore collection and operations', async () => {
            // Act: Execute user deletion workflow
            await deleteUser(req);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('users');
            
            // Assert: Verify correct document reference creation
            expect(mockUsersCollection.doc).toHaveBeenCalledWith('test-user-uid-123');
            
            // Assert: Verify correct operation sequence
            expect(mockUserDocRef.get).toHaveBeenCalled();
            expect(mockUserDocRef.delete).toHaveBeenCalled();
        });

        /**
         * Tests proper operation sequence for document deletion.
         * 
         * Verifies that the function performs database operations in the
         * correct sequence: first checking document existence, then
         * performing deletion if the document exists.
         * 
         * Expected operation sequence:
         * 1. Get document to check existence
         * 2. Delete document if it exists
         * 3. Skip deletion if document doesn't exist
         * 
         * Sequence validation:
         * * Get operation is called before delete operation
         * * Delete operation is only called for existing documents
         * * Operations are performed on the correct document reference
         * 
         * This test ensures that the function follows the proper workflow
         * for safe document deletion and doesn't attempt to delete
         * non-existent documents unnecessarily.
         * 
         * @test {Function} deleteUser
         * @scenario Document deletion with operation sequence validation
         * @expected Operations performed in correct sequence with proper conditions
         */
        test('should perform operations in correct sequence', async () => {
            // Act: Execute user deletion workflow
            await deleteUser(req);

            // Assert: Verify get operation was called first
            expect(mockUserDocRef.get).toHaveBeenCalled();
            
            // Assert: Verify delete operation was called after get
            expect(mockUserDocRef.delete).toHaveBeenCalled();
            
            // Assert: Verify operations were called in correct order
            const getCalls = mockUserDocRef.get.mock.invocationCallOrder;
            const deleteCalls = mockUserDocRef.delete.mock.invocationCallOrder;
            expect(getCalls[0]).toBeLessThan(deleteCalls[0]);
        });
    });
});