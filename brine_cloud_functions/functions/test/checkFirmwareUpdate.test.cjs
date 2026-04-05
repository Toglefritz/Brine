const { checkFirmwareUpdate } = require('../src/checkFirmwareUpdate.cjs');
const admin = require('../config/adminInit.cjs');
const crypto = require('crypto');

// Mock Firestore
jest.mock('../config/adminInit.cjs', () => {
    const mockFirestore = {
        collection: jest.fn(),
    };
    return {
        firestore: jest.fn(() => mockFirestore),
    };
});

// Test PSK used to generate valid HMAC signatures in tests
const TEST_PSK = 'test-psk-secret-key';

/**
 * Generates a valid HMAC signature for the given request body using the test PSK.
 * This mirrors the signing logic on the firmware and cloud function sides.
 */
function generateTestHmac(body) {
    const payload = JSON.stringify(body);
    return crypto.createHmac('sha256', TEST_PSK).update(payload).digest('hex');
}

describe('checkFirmwareUpdate', () => {
    let req, res, mockCollection, mockOrderBy, mockLimit, mockFirmwareGet;
    let mockDeviceUpdate, mockDeviceGet;

    beforeEach(() => {
        jest.clearAllMocks();

        const body = {
            device_id: 'test-device-123',
            current_version: '1.0.0',
        };

        req = {
            body,
            headers: {
                'x-device-id': 'test-device-123',
                'x-hmac-signature': generateTestHmac(body),
            },
        };

        res = {
            status: jest.fn().mockReturnThis(),
            send: jest.fn(),
            json: jest.fn(),
        };

        // Mock for firmware_versions query chain
        mockFirmwareGet = jest.fn();
        mockLimit = jest.fn().mockReturnValue({ get: mockFirmwareGet });
        mockOrderBy = jest.fn().mockReturnValue({ limit: mockLimit });

        // Mock for devices collection (PSK lookup and update check logging)
        mockDeviceUpdate = jest.fn().mockResolvedValue({});
        mockDeviceGet = jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({ psk: TEST_PSK }),
        });

        mockCollection = jest.fn((collectionName) => {
            if (collectionName === 'firmware_versions') {
                return { orderBy: mockOrderBy };
            } else if (collectionName === 'devices') {
                return {
                    doc: jest.fn().mockReturnValue({
                        get: mockDeviceGet,
                        update: mockDeviceUpdate,
                    }),
                };
            }
        });

        admin.firestore().collection = mockCollection;
    });

    test('should return 400 if device_id is missing from body', async () => {
        req.body.device_id = undefined;

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.send).toHaveBeenCalledWith('Device ID and current version are required.');
    });

    test('should return 400 if current_version is missing from body', async () => {
        req.body.current_version = undefined;

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.send).toHaveBeenCalledWith('Device ID and current version are required.');
    });

    test('should return 400 if HMAC headers are missing', async () => {
        req.headers = {};

        await checkFirmwareUpdate(req, res);

        // Body validation passes, then header check fails
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.send).toHaveBeenCalledWith('Missing X-Device-ID or X-HMAC-Signature headers.');
    });

    test('should return 404 if device does not exist in Firestore', async () => {
        mockDeviceGet.mockResolvedValue({ exists: false });

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(404);
        expect(res.send).toHaveBeenCalledWith('Device not found.');
    });

    test('should return 500 if device has no PSK', async () => {
        mockDeviceGet.mockResolvedValue({
            exists: true,
            data: () => ({ psk: null }),
        });

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.send).toHaveBeenCalledWith('PSK not found for the device.');
    });

    test('should return 403 if HMAC signature is invalid', async () => {
        req.headers['x-hmac-signature'] = 'invalid-hmac-value';

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(403);
        expect(res.send).toHaveBeenCalledWith('Invalid HMAC signature.');
    });

    test('should return no update available if no firmware versions exist', async () => {
        mockFirmwareGet.mockResolvedValue({ empty: true, docs: [] });

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({
            update_available: false,
            message: 'No firmware versions available.',
        });
    });

    test('should return update available when newer version exists', async () => {
        const mockFirmwareDoc = {
            data: () => ({
                version: '1.1.0',
                download_url: 'https://example.com/firmware-1.1.0.bin',
                release_notes: 'Bug fixes and improvements',
                active: true,
            }),
        };

        mockFirmwareGet.mockResolvedValue({
            empty: false,
            docs: [mockFirmwareDoc],
        });

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({
            update_available: true,
            latest_version: '1.1.0',
            download_url: 'https://example.com/firmware-1.1.0.bin',
            release_notes: 'Bug fixes and improvements',
        });

        expect(mockDeviceUpdate).toHaveBeenCalledWith({
            last_update_check: expect.any(String),
            available_firmware_version: '1.1.0',
        });
    });

    test('should return no update when current version is up to date', async () => {
        const body = {
            device_id: 'test-device-123',
            current_version: '1.1.0',
        };
        req.body = body;
        req.headers['x-hmac-signature'] = generateTestHmac(body);

        const mockFirmwareDoc = {
            data: () => ({
                version: '1.1.0',
                download_url: 'https://example.com/firmware-1.1.0.bin',
                active: true,
            }),
        };

        mockFirmwareGet.mockResolvedValue({
            empty: false,
            docs: [mockFirmwareDoc],
        });

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({
            update_available: false,
            message: 'Current version is up to date.',
            current_version: '1.1.0',
            latest_version: '1.1.0',
        });

        expect(mockDeviceUpdate).toHaveBeenCalledWith({
            last_update_check: expect.any(String),
        });
    });

    test('should return no update when latest firmware is not active', async () => {
        const mockFirmwareDoc = {
            data: () => ({
                version: '1.2.0',
                download_url: 'https://example.com/firmware-1.2.0.bin',
                active: false,
            }),
        };

        mockFirmwareGet.mockResolvedValue({
            empty: false,
            docs: [mockFirmwareDoc],
        });

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({
            update_available: false,
            message: 'Current version is up to date.',
        });
    });

    test('should handle errors gracefully', async () => {
        mockFirmwareGet.mockRejectedValue(new Error('Database error'));

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.send).toHaveBeenCalledWith('An error occurred while checking for firmware updates.');
    });

    test('should correctly compare semantic versions', async () => {
        const testCases = [
            { current: '1.0.0', latest: '2.0.0', expected: true },
            { current: '1.0.0', latest: '1.1.0', expected: true },
            { current: '1.0.0', latest: '1.0.1', expected: true },
            { current: '1.1.0', latest: '1.0.0', expected: false },
            { current: '2.0.0', latest: '1.9.9', expected: false },
        ];

        for (const testCase of testCases) {
            const body = {
                device_id: 'test-device-123',
                current_version: testCase.current,
            };
            req.body = body;
            req.headers['x-hmac-signature'] = generateTestHmac(body);

            const mockFirmwareDoc = {
                data: () => ({
                    version: testCase.latest,
                    download_url: 'https://example.com/firmware.bin',
                    active: true,
                }),
            };

            mockFirmwareGet.mockResolvedValue({
                empty: false,
                docs: [mockFirmwareDoc],
            });

            await checkFirmwareUpdate(req, res);

            const lastCall = res.json.mock.calls[res.json.mock.calls.length - 1][0];
            expect(lastCall.update_available).toBe(testCase.expected);
        }
    });
});
