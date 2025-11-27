const admin = require('../config/adminInit.cjs');

/**
 * @brief Checks if a firmware update is available for a Brine device.
 *
 * This function is called by the Brine device to check if a newer firmware version
 * is available. The device sends its current firmware version, and the function
 * compares it against the latest available version stored in Firestore.
 *
 * If an update is available, the function returns the latest version number and
 * a download URL pointing to the firmware binary stored in Firebase Storage.
 *
 * Request body:
 * - device_id (string): The unique identifier of the device.
 * - current_version (string): The current firmware version (e.g., "1.0.0").
 *
 * Response:
 * - update_available (boolean): Whether an update is available.
 * - latest_version (string): The latest firmware version (if available).
 * - download_url (string): The URL to download the firmware binary (if available).
 * - release_notes (string): Optional release notes for the update.
 */
async function checkFirmwareUpdate(req, res) {
    try {
        // Extract request body
        const { device_id: deviceId, current_version: currentVersion } = req.body;

        // Validate input
        if (!deviceId || !currentVersion) {
            res.status(400).send('Device ID and current version are required.');
            return;
        }

        console.log(`Checking firmware update for device ${deviceId}, current version: ${currentVersion}`);

        // Retrieve the latest firmware version from Firestore
        // The firmware metadata is stored in a 'firmware_versions' collection
        const firmwareQuery = await admin.firestore()
            .collection('firmware_versions')
            .orderBy('version_number', 'desc')
            .limit(1)
            .get();

        if (firmwareQuery.empty) {
            console.log('No firmware versions found in database.');
            res.status(200).json({
                update_available: false,
                message: 'No firmware versions available.'
            });
            return;
        }

        // Get the latest firmware document
        const latestFirmwareDoc = firmwareQuery.docs[0];
        const latestFirmware = latestFirmwareDoc.data();
        const latestVersion = latestFirmware.version;
        const downloadUrl = latestFirmware.download_url;
        const releaseNotes = latestFirmware.release_notes || '';
        const isActive = latestFirmware.active !== false; // Default to true if not specified

        // Check if the latest firmware is marked as active
        if (!isActive) {
            console.log(`Latest firmware ${latestVersion} is not active. No update available.`);
            res.status(200).json({
                update_available: false,
                message: 'Current version is up to date.'
            });
            return;
        }

        // Compare versions
        const updateAvailable = isNewerVersion(currentVersion, latestVersion);

        if (updateAvailable) {
            console.log(`Update available for device ${deviceId}: ${currentVersion} -> ${latestVersion}`);
            
            // Log the update check in the device document
            await admin.firestore().collection('devices').doc(deviceId).update({
                'last_update_check': new Date().toISOString(),
                'available_firmware_version': latestVersion
            });

            res.status(200).json({
                update_available: true,
                latest_version: latestVersion,
                download_url: downloadUrl,
                release_notes: releaseNotes
            });
        } else {
            console.log(`Device ${deviceId} is up to date. Current: ${currentVersion}, Latest: ${latestVersion}`);
            
            // Log the update check
            await admin.firestore().collection('devices').doc(deviceId).update({
                'last_update_check': new Date().toISOString()
            });

            res.status(200).json({
                update_available: false,
                message: 'Current version is up to date.',
                current_version: currentVersion,
                latest_version: latestVersion
            });
        }
    } catch (error) {
        console.error('Error checking firmware update:', error);
        res.status(500).send('An error occurred while checking for firmware updates.');
    }
}

/**
 * @brief Compares two semantic version strings.
 *
 * This function compares two version strings in the format "major.minor.patch"
 * and determines if the latest version is newer than the current version.
 *
 * @param {string} current - The current version (e.g., "1.0.0").
 * @param {string} latest - The latest version (e.g., "1.1.0").
 * @return {boolean} true if latest is newer than current, false otherwise.
 */
function isNewerVersion(current, latest) {
    const currentParts = current.split('.').map(Number);
    const latestParts = latest.split('.').map(Number);

    // Compare major version
    if (latestParts[0] > currentParts[0]) return true;
    if (latestParts[0] < currentParts[0]) return false;

    // Compare minor version
    if (latestParts[1] > currentParts[1]) return true;
    if (latestParts[1] < currentParts[1]) return false;

    // Compare patch version
    if (latestParts[2] > currentParts[2]) return true;

    return false;
}

// Export the function
module.exports = { checkFirmwareUpdate };
