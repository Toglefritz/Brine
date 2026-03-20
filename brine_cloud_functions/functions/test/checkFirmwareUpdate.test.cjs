const { checkFirmwareUpdate } = require('../src/checkFirmwareUpdate.cjs');
const admin = require('../config/adminInit.cjs');

// Mock Firestore
jest.mock('../config/adminInit.cjs', () => {
    const mockFirestore = {
        collection: jest.fn(),
    };
    return {
        firestore: jest.fn(() => mockFirestore),
    };
});

describe('checkFirmwareUpdate', () => {
    let req, res, mockCollection, mockOrderBy, mockLimit, mockGet, mockUpdate;

    beforeEach(() => {
        // Reset mocks
        jest.clearAllMocks();

        // Mock request and response objects
        req = {
            body: {
                device_id: 'test-device-123',
                current_version: '1.0.0',
            },
        };

        res = {
            status: jest.fn().mockReturnThis(),
            send: jest.fn(),
            json: jest.fn(),
        };

        // Mock Firestore chain
        mockUpdate = jest.fn().mockResolvedValue({});
        mockGet = jest.fn();
        mockLimit = jest.fn().mockReturnValue({ get: mockGet });
        mockOrderBy = jest.fn().mockReturnValue({ limit: mockLimit });
        mockCollection = jest.fn((collectionName) => {
            if (collectionName === 'firmware_versions') {
                return { orderBy: mockOrderBy };
            } else if (collectionName === 'devices') {
                return {
                    doc: jest.fn().mockReturnValue({
                        update: mockUpdate,
                    }),
                };
            }
        });

        admin.firestore().collection = mockCollection;
    });

    test('should return 400 if device_id is missing', async () => {
        req.body.device_id = undefined;

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.send).toHaveBeenCalledWith('Device ID and current version are required.');
    });

    test('should return 400 if current_version is missing', async () => {
        req.body.current_version = undefined;

        await checkFirmwareUpdate(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.send).toHaveBeenCalledWith('Device ID and current version are required.');
    });

    test('should return no update available if no firmware versions exist', async () => {
        mockGet.mockResolvedValue({ empty: true, docs: [] });

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

        mockGet.mockResolvedValue({
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

        expect(mockUpdate).toHaveBeenCalledWith({
            last_update_check: expect.any(String),
            available_firmware_version: '1.1.0',
        });
    });

    test('should return no update when current version is up to date', async () => {
        req.body.current_version = '1.1.0';

        const mockFirmwareDoc = {
            data: () => ({
                version: '1.1.0',
                download_url: 'https://example.com/firmware-1.1.0.bin',
                active: true,
            }),
        };

        mockGet.mockResolvedValue({
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

        expect(mockUpdate).toHaveBeenCalledWith({
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

        mockGet.mockResolvedValue({
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
        mockGet.mockRejectedValue(new Error('Database error'));

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
            req.body.current_version = testCase.current;

            const mockFirmwareDoc = {
                data: () => ({
                    version: testCase.latest,
                    download_url: 'https://example.com/firmware.bin',
                    active: true,
                }),
            };

            mockGet.mockResolvedValue({
                empty: false,
                docs: [mockFirmwareDoc],
            });

            await checkFirmwareUpdate(req, res);

            const lastCall = res.json.mock.calls[res.json.mock.calls.length - 1][0];
            expect(lastCall.update_available).toBe(testCase.expected);
        }
    });
});
