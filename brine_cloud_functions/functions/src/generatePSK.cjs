const admin = require('../config/adminInit.cjs');
const crypto = require("crypto");

/**
 * @brief Generates a new pre-shared key (PSK) for a Brine device and stores it in Firestore.
 * 
 * This function is called by the mobile app during the provisioning process. It generates a secure 
 * random PSK, stores it in the devices collection in Firestore along with a creation timestamp 
 * and validity status, and returns the PSK to the caller.
 * 
 * Request Parameters:
 * - deviceId (string): The unique ID of the device for which the PSK is being generated.
 * 
 * Response:
 * - 200: Returns the generated PSK.
 * - 400: Missing or invalid request parameters.
 * - 500: Internal server error.
 */
async function generatePSK(req, res) {
    // Validate request method
    if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
    }

    // Validate request body
    const { deviceId } = req.body;
    if (!deviceId) {
        res.status(400).send("Device ID must be provided");
        return;
    }

    try {
        // Generate a new random PSK (32 bytes, hex encoded)
        const newPSK = crypto.randomBytes(32).toString("hex");

        // Prepare the Firestore document data
        const pskData = {
            psk: newPSK,
            psk_created_at: new Date().toISOString(),
            psk_valid: true,
        };

        // Store the PSK in Firestore under the devices collection
        const deviceDocRef = admin.firestore().collection("devices").doc(deviceId);
        await deviceDocRef.set(pskData, { merge: true });

        // Return the generated PSK to the caller
        res.status(200).json({ psk: newPSK });
    } catch (error) {
        console.error("Error generating PSK:", error);
        res.status(500).send("Internal Server Error");
    }
};

// Export the function to make it available for import
module.exports = { generatePSK: generatePSK };