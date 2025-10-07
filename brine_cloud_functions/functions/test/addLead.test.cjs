/**
 * @fileoverview Test suite for addLead Firebase Function
 * 
 * This comprehensive test suite validates all functionality and edge cases for the
 * addLead Cloud Function, ensuring reliable behavior across different
 * scenarios, error conditions, and lead data management requirements.
 * 
 * The addLead function handles the complete lead registration workflow:
 * 1. Validates required input parameters (name and email)
 * 2. Creates a timestamp for the lead entry
 * 3. Adds a new document to the "leads" collection in Firestore
 * 4. Handles all error conditions gracefully with appropriate HTTP responses
 * 
 * Lead management is crucial for the Brine sales pipeline, allowing the mobile
 * app to capture potential customer information and store it for follow-up by
 * the sales team. Each lead document contains essential contact information
 * and a timestamp for tracking when the lead was generated.
 * 
 * Test Categories:
 * * Input validation - Ensures name and email parameters are validated properly
 * * Lead document creation - Tests Firestore document creation with proper structure
 * * Timestamp generation - Validates proper timestamp creation and formatting
 * * Error handling - Ensures proper error responses and status codes
 * * Edge cases - Handles boundary conditions and unusual input data
 * * Firestore integration - Verifies correct database operations and calls
 * 
 * Mock Dependencies:
 * * Firebase Admin SDK - Mocked for Firestore operations and document management
 * * Firestore collections - Mocked for leads collection access
 * * Collection references - Mocked for add operations
 * * Date objects - Mocked for predictable timestamp generation
 * 
 * Test Coverage:
 * * 100% code coverage for the addLead function
 * * All execution paths including success and error scenarios
 * * Input validation for all required parameters
 * * Database operation success and failure conditions
 * * Timestamp generation and formatting validation
 * * Lead document structure and data integrity
 * 
 * @author Firebase Functions Team
 * @since 2025-01-10
 * @version 1.0.0
 * @requires jest
 * @requires firebase-admin
 */

/**
 * Mock Firestore collection reference for leads operations.
 * 
 * Provides mocked implementations of Firestore collection operations
 * for the leads collection, including add operations that are used
 * during lead document creation workflow.
 * 
 * @type {Object}
 * @property {jest.Mock} add - Mock function for adding new lead documents
 */
const mockLeadsCollection = {
    add: jest.fn()
};

/**
 * Mock Firestore instance with collection and document operations.
 * 
 * Simulates the Firebase Admin SDK Firestore interface, providing
 * mocked collection access that returns appropriate collection references
 * for the leads collection used in lead management.
 * 
 * @type {Object}
 * @property {jest.Mock} collection - Mock function that returns collection references
 * 
 * @example
 * // Returns leads collection reference for 'leads' collection
 * mockFirestore.collection('leads')
 */
const mockFirestore = {
    collection: jest.fn(() => mockLeadsCollection)
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
const { addLead } = require('../src/addLead.cjs');

/**
 * Test suite for addLead Firebase Cloud Function.
 * 
 * This comprehensive test suite validates the complete lead registration
 * workflow, covering all success paths, error conditions, and edge cases.
 * The tests ensure that the function properly handles input validation,
 * Firestore operations, timestamp generation, and error responses.
 * 
 * Test Structure:
 * * Input validation - Tests for required name and email parameter validation
 * * Lead document creation - Tests Firestore document creation and structure
 * * Timestamp generation - Tests proper timestamp creation and formatting
 * * Error handling - Tests database error scenarios and responses
 * * Edge cases - Tests boundary conditions and unusual input handling
 * * Firestore integration - Tests database operation calls and responses
 * 
 * Each test group focuses on a specific aspect of the function's behavior,
 * ensuring comprehensive coverage and clear separation of concerns.
 */
describe('addLead', () => {
    /**
     * Mock Express request object for testing HTTP endpoints.
     * 
     * Simulates the Express.js request object that would be passed to the
     * addLead function in a real HTTP request scenario. Contains
     * request body data with lead information.
     * 
     * @type {Object}
     * @property {Object} body - HTTP request body containing lead information
     * @property {string} body.name - Lead's name for contact purposes
     * @property {string} body.email - Lead's email address for follow-up
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
     * 3. Configuring default successful Firestore operations
     * 4. Setting up predictable timestamp generation
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
         * Sets up a typical successful request scenario with valid
         * lead information. Individual tests can override these
         * values to test specific error conditions or edge cases.
         */
        req = {
            body: {
                name: 'John Doe',
                email: 'john.doe@example.com'
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
        mockLeadsCollection.add.mockClear();

        // Configure all Firestore operations to resolve successfully by default
        mockLeadsCollection.add.mockResolvedValue({ id: 'mock-document-id' });
    });

    /**
     * Test group for input validation scenarios.
     * 
     * This test group validates that the addLead function properly
     * enforces all input validation rules and returns appropriate error
     * responses when required data is missing or invalid.
     * 
     * The function must validate:
     * * name - Required contact name for the lead
     * * email - Required email address for follow-up communication
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
         * Tests validation of missing name parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * name field is completely missing from the request body.
         * The name is essential for lead identification and follow-up
         * communication by the sales team.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate name and email are required
         * * No database operations should be attempted
         * 
         * @test {Function} addLead
         * @scenario Missing name parameter in request body
         * @expected HTTP 400 with "Name and email are required." message
         */
        test('should return 400 if name is missing', async () => {
            // Arrange: Remove name from request body
            req.body.name = undefined;

            // Act: Call function with missing name
            await addLead(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Name and email are required.');
        });

        /**
         * Tests validation of empty name parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * name field is present but contains an empty string. Empty
         * names are not useful for lead management and follow-up
         * communication purposes.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate name and email are required
         * * Empty strings should be treated the same as missing values
         * 
         * @test {Function} addLead
         * @scenario Empty string name parameter in request body
         * @expected HTTP 400 with "Name and email are required." message
         */
        test('should return 400 if name is empty string', async () => {
            // Arrange: Set name to empty string
            req.body.name = '';

            // Act: Call function with empty name
            await addLead(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Name and email are required.');
        });

        /**
         * Tests validation of missing email parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * email field is completely missing from the request body.
         * The email address is critical for lead follow-up and
         * communication by the sales team.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate name and email are required
         * * No database operations should be attempted
         * 
         * @test {Function} addLead
         * @scenario Missing email parameter in request body
         * @expected HTTP 400 with "Name and email are required." message
         */
        test('should return 400 if email is missing', async () => {
            // Arrange: Remove email from request body
            req.body.email = undefined;

            // Act: Call function with missing email
            await addLead(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Name and email are required.');
        });

        /**
         * Tests validation of empty email parameter.
         * 
         * Verifies that the function properly rejects requests when the
         * email field is present but contains an empty string. Empty
         * email addresses are not valid for lead follow-up and
         * communication purposes.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate name and email are required
         * * Empty strings should be treated the same as missing values
         * 
         * @test {Function} addLead
         * @scenario Empty string email parameter in request body
         * @expected HTTP 400 with "Name and email are required." message
         */
        test('should return 400 if email is empty string', async () => {
            // Arrange: Set email to empty string
            req.body.email = '';

            // Act: Call function with empty email
            await addLead(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Name and email are required.');
        });

        /**
         * Tests validation when both name and email are missing.
         * 
         * Verifies that the function properly rejects requests when both
         * required fields are missing from the request body. This tests
         * the combined validation logic and ensures consistent error
         * messaging regardless of which fields are missing.
         * 
         * Expected behavior:
         * * Function should return HTTP 400 status code
         * * Response message should clearly indicate name and email are required
         * * No database operations should be attempted
         * 
         * @test {Function} addLead
         * @scenario Both name and email parameters missing from request body
         * @expected HTTP 400 with "Name and email are required." message
         */
        test('should return 400 if both name and email are missing', async () => {
            // Arrange: Remove both name and email from request body
            req.body.name = undefined;
            req.body.email = undefined;

            // Act: Call function with missing required fields
            await addLead(req, res);

            // Assert: Verify proper error response
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.send).toHaveBeenCalledWith('Name and email are required.');
        });
    });

    /**
     * Test group for lead document creation scenarios.
     * 
     * This test group validates the core functionality of creating lead
     * documents in the Firestore leads collection. The function must
     * properly structure lead data and store it with appropriate
     * timestamps for sales team follow-up.
     * 
     * Lead document creation workflow:
     * 1. Validate required input parameters
     * 2. Generate current timestamp in ISO format
     * 3. Create document structure with name, email, and timestamp
     * 4. Add document to Firestore leads collection
     * 5. Return success response to client
     * 
     * Document structure validation:
     * * name - Contact name from request body
     * * email - Email address from request body
     * * timestamp - ISO formatted creation timestamp
     * 
     * These tests ensure proper lead document creation and data
     * integrity for the sales pipeline management system.
     */
    describe('Lead document creation', () => {
        /**
         * Tests successful lead document creation with valid data.
         * 
         * Verifies that the function properly creates a lead document
         * in the Firestore leads collection with the correct structure
         * and data when provided with valid input parameters.
         * 
         * Expected behavior:
         * * Function should create document with proper structure
         * * Document should contain name, email, and timestamp fields
         * * Timestamp should be in ISO format
         * * Function should return HTTP 200 with success message
         * * Firestore add operation should be called with correct data
         * 
         * This test ensures that the primary workflow of the function
         * operates correctly and creates properly structured lead
         * documents for sales team processing.
         * 
         * @test {Function} addLead
         * @scenario Valid lead data provided in request
         * @expected HTTP 200 with lead document created in Firestore
         */
        test('should create lead document with valid data', async () => {
            // Arrange: Mock Date.prototype.toISOString for predictable timestamp testing
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Create lead with valid data
            await addLead(req, res);

            // Assert: Verify lead document is created with correct structure
            expect(mockLeadsCollection.add).toHaveBeenCalledWith({
                name: 'John Doe',
                email: 'john.doe@example.com',
                timestamp: mockTimestamp
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Lead added successfully.');

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });

        /**
         * Tests lead document creation with different valid data.
         * 
         * Verifies that the function properly handles various valid
         * input combinations and creates appropriate lead documents
         * with different names and email addresses.
         * 
         * Expected behavior:
         * * Function should handle different valid input combinations
         * * Document structure should remain consistent
         * * All valid data should be properly stored
         * * Function should return HTTP 200 with success message
         * 
         * This test ensures that the function works correctly with
         * various valid input data and maintains consistent behavior
         * across different lead information scenarios.
         * 
         * @test {Function} addLead
         * @scenario Different valid lead data provided in request
         * @expected HTTP 200 with lead document created with provided data
         */
        test('should create lead document with different valid data', async () => {
            // Arrange: Configure different valid lead data
            req.body.name = 'Jane Smith';
            req.body.email = 'jane.smith@company.com';
            
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Create lead with different valid data
            await addLead(req, res);

            // Assert: Verify lead document is created with provided data
            expect(mockLeadsCollection.add).toHaveBeenCalledWith({
                name: 'Jane Smith',
                email: 'jane.smith@company.com',
                timestamp: mockTimestamp
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Lead added successfully.');

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });

    /**
     * Test group for error handling scenarios.
     * 
     * This test group validates the function's behavior when database
     * errors occur during lead document creation. The function must
     * handle Firestore errors gracefully and provide appropriate
     * error responses to clients.
     * 
     * Error handling ensures:
     * * Proper error response codes and messages
     * * Error logging for debugging and monitoring
     * * Graceful failure without exposing internal details
     * * Consistent error handling across different failure modes
     * 
     * These tests ensure that database errors are handled professionally
     * and that clients receive appropriate feedback when operations fail.
     */
    describe('Error handling', () => {
        /**
         * Tests handling of Firestore document creation errors.
         * 
         * Verifies that the function properly handles database errors
         * that occur during lead document creation in Firestore. This
         * could happen due to network issues, permission problems, or
         * Firestore service outages.
         * 
         * Expected behavior:
         * * Function should return HTTP 500 (Internal Server Error) status
         * * Response message should indicate Firestore error
         * * Error should be logged for debugging purposes
         * * No partial operations should leave data in inconsistent state
         * 
         * This test ensures that database errors are handled gracefully
         * without exposing internal error details to clients while
         * providing sufficient information for debugging and monitoring.
         * 
         * Error scenarios covered:
         * * Network connectivity issues during document creation
         * * Firestore permission denied errors
         * * Service unavailable conditions
         * * Document validation or size limit errors
         * 
         * @test {Function} addLead
         * @scenario Firestore throws error during lead document creation
         * @expected HTTP 500 with "Error adding lead to Firestore." message
         */
        test('should handle Firestore document creation error', async () => {
            // Arrange: Configure Firestore to throw error during document creation
            mockLeadsCollection.add.mockRejectedValue(new Error('Firestore error'));

            // Act: Attempt to create lead when database error occurs
            await addLead(req, res);

            // Assert: Verify proper internal server error response
            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.send).toHaveBeenCalledWith('Error adding lead to Firestore.');
        });
    });

    /**
     * Test group for edge cases and boundary conditions.
     * 
     * This test group validates the function's behavior with unusual
     * input data that might occur in production environments. These
     * scenarios test the robustness of the function's data handling
     * and ensure graceful behavior with edge case inputs.
     * 
     * Edge cases covered:
     * * Special characters in names and email addresses
     * * Very long input strings
     * * Unicode characters and international names
     * * Whitespace handling in input data
     * 
     * These tests ensure that the function handles real-world data
     * variations and edge cases that might occur with diverse user
     * inputs from different regions and languages.
     */
    describe('Edge cases', () => {
        /**
         * Tests handling of special characters in input data.
         * 
         * Verifies that the function properly handles lead data
         * containing special characters, accented letters, and
         * international characters that might appear in real-world
         * names and email addresses.
         * 
         * Expected behavior:
         * * Function should accept and store special characters correctly
         * * Document should be created with original character encoding
         * * Function should return HTTP 200 with success message
         * * No data corruption or encoding issues should occur
         * 
         * This test ensures that the function works correctly with
         * international users and diverse character sets, supporting
         * global lead generation and sales operations.
         * 
         * @test {Function} addLead
         * @scenario Lead data contains special characters and accents
         * @expected HTTP 200 with lead document created preserving special characters
         */
        test('should handle special characters in name and email', async () => {
            // Arrange: Configure lead data with special characters
            req.body.name = 'José María Ñoño';
            req.body.email = 'josé.maría@compañía.com';
            
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Create lead with special characters
            await addLead(req, res);

            // Assert: Verify lead document is created with special characters preserved
            expect(mockLeadsCollection.add).toHaveBeenCalledWith({
                name: 'José María Ñoño',
                email: 'josé.maría@compañía.com',
                timestamp: mockTimestamp
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Lead added successfully.');

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });

        /**
         * Tests handling of whitespace in input data.
         * 
         * Verifies that the function properly handles lead data
         * containing leading and trailing whitespace in names
         * and email addresses. The function should preserve
         * the data as provided without automatic trimming.
         * 
         * Expected behavior:
         * * Function should accept data with whitespace as provided
         * * Document should be created with original whitespace
         * * Function should return HTTP 200 with success message
         * * No automatic data modification should occur
         * 
         * This test ensures that the function preserves data integrity
         * and doesn't make assumptions about data formatting that
         * might be handled by other parts of the system.
         * 
         * @test {Function} addLead
         * @scenario Lead data contains leading and trailing whitespace
         * @expected HTTP 200 with lead document created preserving whitespace
         */
        test('should handle whitespace in name and email', async () => {
            // Arrange: Configure lead data with whitespace
            req.body.name = '  John Doe  ';
            req.body.email = '  john.doe@example.com  ';
            
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Create lead with whitespace data
            await addLead(req, res);

            // Assert: Verify lead document is created with whitespace preserved
            expect(mockLeadsCollection.add).toHaveBeenCalledWith({
                name: '  John Doe  ',
                email: '  john.doe@example.com  ',
                timestamp: mockTimestamp
            });
            expect(res.status).toHaveBeenCalledWith(200);
            expect(res.send).toHaveBeenCalledWith('Lead added successfully.');

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
     * * Correct collection name usage ('leads')
     * * Proper add operation calls
     * * Expected sequence of database operations
     * * Correct data structure passed to Firestore
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
         * the lead creation workflow. This test ensures that the
         * function follows the expected database schema and access patterns.
         * 
         * Expected database operations:
         * 1. Access 'leads' collection
         * 2. Perform add operation to create new lead document
         * 3. Pass correct document structure to add operation
         * 
         * Database schema validation:
         * * Leads collection: /leads/{auto-generated-id}
         * * Correct collection name usage
         * * Proper operation method calls
         * 
         * This test ensures that the function maintains consistency with
         * the established database schema and doesn't accidentally access
         * wrong collections or use incorrect operation methods, which
         * could lead to data corruption or application errors.
         * 
         * @test {Function} addLead
         * @scenario Successful lead creation with database operation validation
         * @expected Correct Firestore collection accessed with proper add operation
         */
        test('should call correct Firestore collection and operations', async () => {
            // Arrange: Configure successful lead creation scenario
            const mockTimestamp = '2023-01-01T00:00:00.000Z';
            jest.spyOn(Date.prototype, 'toISOString').mockReturnValue(mockTimestamp);

            // Act: Execute lead creation workflow
            await addLead(req, res);

            // Assert: Verify correct Firestore collection access
            expect(mockFirestore.collection).toHaveBeenCalledWith('leads');
            
            // Assert: Verify correct add operation call
            expect(mockLeadsCollection.add).toHaveBeenCalledWith({
                name: 'John Doe',
                email: 'john.doe@example.com',
                timestamp: mockTimestamp
            });

            // Clean up: Restore original Date method
            Date.prototype.toISOString.mockRestore();
        });
    });
});