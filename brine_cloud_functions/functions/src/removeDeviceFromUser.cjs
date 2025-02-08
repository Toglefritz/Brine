const admin = require('../config/adminInit.cjs');

/**
 * @brief Removes a device from the user's list of devices and deletes its record if no users are using it.
 * 
 * This function ensures that the device is unlinked from the user and, if no other users are using the device,
 * it removes the device record from the "devices" collection.
 *
 * Example usage:
 * 
 * DELETE /removeDeviceFromUser
 * {
 *  "deviceId": "vast_teal_elephant"
 * }
 */
async function removeDeviceFromUser(req, res) {
    // Get the user ID from the request (attached by authentication middleware)
    const userUid = req.user.uid;

    // Extract the device ID from query parameters
    const deviceId = req.query.deviceId;

    console.log('Removing device from user', userUid, ':', deviceId);

    // Validate inputs
    if (!deviceId) {
        console.error('Device ID is required');
        res.status(400).send('Device ID is required');
        return;
    }

    if (!userUid || typeof userUid !== 'string') {
        console.error('The user UID is missing or invalid.');
        res.status(400).send('The user UID is missing or invalid.');
        return;
    }

    try {
        // Step 1: Remove the device from the user's list of devices
        const userDocRef = admin.firestore().collection('users').doc(userUid);
        const userDocSnapshot = await userDocRef.get();

        if (!userDocSnapshot.exists) {
            console.error('User not found');
            res.status(404).send('User not found');
            return;
        }

        // Get the current devices array
        let devices = userDocSnapshot.get('devices') || [];

        // If the device is not in the user's list, return success
        if (!devices.includes(deviceId)) {
            console.log('Device not linked to user');
            res.status(200).send('Device was not linked to user');
            return;
        }

        // Remove the device from the list
        devices = devices.filter(id => id !== deviceId);
        await userDocRef.update({ devices });

        console.log('Device removed from user');

        // Step 2: Check if any other users are still linked to this device
        const usersWithDeviceQuery = await admin.firestore()
            .collection('users')
            .where('devices', 'array-contains', deviceId)
            .get();

        // If no other users are linked to this device, delete its record from the "devices" collection
        if (usersWithDeviceQuery.empty) {
            const deviceDocRef = admin.firestore().collection('devices').doc(deviceId);
            await deviceDocRef.delete();
            console.log('Device record deleted from devices collection');
        }

        res.status(200).send('Device removed successfully');
    } catch (error) {
        console.error('Error removing device:', error);
        res.status(500).send('Internal Server Error');
    }
}

// Export the function
module.exports = { removeDeviceFromUser };