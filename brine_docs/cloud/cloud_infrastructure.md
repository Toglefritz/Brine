# Cloud Infrastructure

The Brine cloud backend runs on Firebase and is implemented as a set of HTTP Cloud Functions backed by Firestore. The source lives in the `brine_cloud_functions` directory. All functions are written in Node.js (CommonJS) and deployed through the Firebase CLI.

## Firebase Services

The backend relies on four Firebase services:

- Firebase Authentication, for verifying user identity on requests from the mobile app.
- Cloud Functions, for hosting the HTTP endpoints that the mobile app and the Brine device call.
- Firestore, for storing user accounts, device records, firmware metadata, push notification tokens, and sales leads.
- Firebase Cloud Messaging (FCM), for delivering push notifications to users when salt or battery levels are low.
- Firebase Storage, for hosting firmware binaries that devices download during OTA updates.

## Authentication

Most endpoints require a Firebase ID token in the `Authorization` header. An authentication middleware (`authMiddleware.cjs`) extracts and verifies this token before the request reaches the function handler. If the token includes a `userId` field, the middleware also confirms that it matches the UID encoded in the token.

Two authentication modes exist:

- `authenticate`: Verifies a standard Firebase Auth ID token. Used by all mobile app endpoints.
- `authenticateAnonymous`: Verifies a token from an anonymous Firebase Auth session. Used by the lead capture endpoint on the Brine website.

When running against the Firebase Emulator Suite, the middleware skips token verification and accepts a `x-user-id` header instead, allowing local testing without real credentials.

Two endpoints bypass Firebase Auth entirely and are open to unauthenticated callers:

- `updateDeviceLevels`: Called by the Brine hardware device. Authenticated via HMAC signature instead (see the [HMAC security documentation](../security/hmac_security.md)).
- `checkFirmwareUpdate`: Called by the Brine hardware device to check for OTA updates.

## Firestore Collections

### users

Each document is keyed by the user's Firebase Auth UID and contains:

- `uid`: The user's Firebase Auth UID.
- `devices`: An array of device IDs associated with the account.
- `fcm_tokens`: An array of FCM tokens registered for push notifications.

### devices

Each document is keyed by the device's unique identifier (e.g., `vast_teal_elephant`) and contains:

- `device_id`: The device identifier.
- `name`: A short human-readable name for the device.
- `battery_level`: The most recent battery reading (0 to 1 scale, or -1 if unknown).
- `salt_distance`: The most recent distance measurement from the sensor to the salt surface, in millimeters (-1 if unknown).
- `appliance_height`: The total interior height of the water softener, in millimeters (-1 if unknown).
- `last_updated`: ISO timestamp of the most recent level update.
- `psk`: The HMAC pre-shared key for this device.
- `psk_created_at`: ISO timestamp of when the PSK was generated.
- `psk_valid`: Whether the PSK is currently valid.
- `last_update_check`: ISO timestamp of the most recent OTA update check (written by `checkFirmwareUpdate`).
- `available_firmware_version`: The latest firmware version available at the time of the last update check.

### firmware_versions

Stores metadata for each published firmware release. Used by the `checkFirmwareUpdate` function. Each document contains:

- `version`: Semantic version string (e.g., `"1.1.0"`).
- `version_number`: Numeric representation for sorting (e.g., `110`).
- `download_url`: Firebase Storage URL for the firmware binary.
- `release_notes`: Optional description of changes.
- `active`: Boolean flag that controls whether devices are offered this version.
- `created_at`: ISO timestamp.
- `file_size`: Size of the binary in bytes.

### leads

Stores sales leads submitted through the Brine website. Each document contains a name, email, and timestamp.

## Cloud Functions

The table below lists each deployed function, who calls it, and what it does.

| Function | Caller | Auth | Purpose |
|---|---|---|---|
| `createUserDocument` | Mobile app | Firebase Auth | Creates a user document in Firestore after account creation. |
| `addDeviceToUser` | Mobile app | Firebase Auth | Links a device to the user's account and creates the device record if it does not exist. |
| `getUserDevices` | Mobile app | Firebase Auth | Returns the full device documents for all devices on the user's account. |
| `getDevice` | Mobile app | Firebase Auth | Returns a single device document after verifying the user has access to it. |
| `generatePSK` | Mobile app | Firebase Auth | Generates a random 32-byte pre-shared key, stores it on the device document, and returns it to the app for transfer to the hardware over BLE. |
| `updateApplianceHeight` | Mobile app | Firebase Auth | Updates the appliance height on a device document after verifying user access. |
| `removeDeviceFromUser` | Mobile app | Firebase Auth | Removes a device from the user's device list. Deletes the device record if no other users reference it. |
| `addFcmToken` | Mobile app | Firebase Auth | Registers an FCM push notification token on the user's document. |
| `deleteUser` | Mobile app | Firebase Auth | Deletes the user's Firestore document. |
| `updateDeviceLevels` | Brine device | HMAC | Accepts battery and salt distance readings from the hardware, updates the device document, and triggers a push notification if either level is critically low (below 5%). |
| `checkFirmwareUpdate` | Brine device | None | Compares the device's reported firmware version against the latest active version in Firestore and returns a download URL if an update is available. |
| `addLead` | Brine website | Anonymous Auth | Stores a sales lead (name and email) submitted through the website. |

## Push Notifications

When `updateDeviceLevels` receives a reading where the battery level is below 5% or the calculated salt level percentage is below 5%, it looks up the user who owns the device, retrieves their FCM tokens, and sends a push notification through Firebase Cloud Messaging. The notification message identifies which condition triggered the alert.

## Local Development

The project is configured to run against the Firebase Emulator Suite. The `firebase.json` file defines emulators for Auth (port 9099), Functions (port 5001), Firestore (port 8080), and Hosting (port 5000), all bound to `0.0.0.0` so they are accessible from other devices on the local network. A convenience script (`firebase_emulator_suite.command`) starts the emulator suite.
