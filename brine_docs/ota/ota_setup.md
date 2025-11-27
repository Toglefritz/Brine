# OTA Cloud Functions Setup Guide

## Overview

This guide explains how to set up and manage the cloud infrastructure for Brine's OTA firmware update system.

## Prerequisites

- Firebase project configured
- Firebase CLI installed and authenticated
- Node.js and npm installed
- Firestore database enabled
- Firebase Storage enabled

## Cloud Function: checkFirmwareUpdate

### Endpoint Details

**Development (Emulator)**:
```
http://localhost:5001/brine-3b212/us-central1/checkFirmwareUpdate
```

**Production**:
```
https://checkfirmwareupdate-7wo3szegoq-uc.a.run.app
```

### Request Format

```bash
curl -X POST https://checkfirmwareupdate-7wo3szegoq-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "device-123",
    "current_version": "1.0.0"
  }'
```

### Response Format

**Update Available**:
```json
{
  "update_available": true,
  "latest_version": "1.1.0",
  "download_url": "https://firebasestorage.googleapis.com/...",
  "release_notes": "Bug fixes and improvements"
}
```

**No Update**:
```json
{
  "update_available": false,
  "message": "Current version is up to date.",
  "current_version": "1.0.0",
  "latest_version": "1.0.0"
}
```

## Firestore Setup

### Collection: firmware_versions

Create this collection in your Firestore database.

#### Document Structure

```javascript
{
  version: "1.1.0",              // String: Semantic version
  version_number: 110,           // Number: For sorting (major*100 + minor*10 + patch)
  download_url: "https://...",   // String: Firebase Storage URL
  release_notes: "...",          // String: Release notes (optional)
  active: true,                  // Boolean: Whether to offer this version
  created_at: "2025-11-27T...",  // String: ISO timestamp
  file_size: 1234567,            // Number: Size in bytes
  checksum: "sha256:..."         // String: Checksum (optional, for future use)
}
```

#### Indexes

Create a composite index for efficient queries:

**Collection**: `firmware_versions`
**Fields**:
- `version_number` (Descending)
- `active` (Ascending)

You can create this index by:
1. Running a query that requires it (Firebase will prompt you)
2. Or manually in Firebase Console: Firestore → Indexes → Create Index

### Collection: devices

The OTA system updates device documents with tracking information:

```javascript
{
  // ... existing device fields ...
  last_update_check: "2025-11-27T10:30:00Z",     // Last time device checked for updates
  available_firmware_version: "1.1.0",           // Latest version available to device
  current_firmware_version: "1.0.0"              // Currently running version (future)
}
```

## Deployment

### Deploy Cloud Functions

```bash
cd brine_cloud_functions
firebase deploy --only functions:checkFirmwareUpdate
```

### Deploy All Functions

```bash
firebase deploy --only functions
```

### Test Deployment

```bash
# Test the deployed function
curl -X POST https://checkfirmwareupdate-7wo3szegoq-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "test-device",
    "current_version": "1.0.0"
  }'
```

## Firebase Storage Setup

### Storage Structure

```
firmware/
├── brine-firmware-1.0.0.bin
├── brine-firmware-1.1.0.bin
└── brine-firmware-1.2.0.bin
```

### Upload Firmware

```bash
# Upload firmware binary
firebase storage:upload path/to/firmware.bin --path firmware/brine-firmware-1.1.0.bin

# Get download URL
firebase storage:get-url firmware/brine-firmware-1.1.0.bin
```

### Storage Rules

Update `storage.rules` to allow device access:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow public read access to firmware files
    match /firmware/{fileName} {
      allow read: if true;
    }
    
    // Restrict write access to authenticated users only
    match /firmware/{fileName} {
      allow write: if request.auth != null;
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only storage
```

## Managing Firmware Versions

### Adding a New Version

1. **Build firmware**:
```bash
cd brine_firmware
pio run -e seeed_xiao_esp32s3
```

2. **Upload to Storage**:
```bash
firebase storage:upload .pio/build/seeed_xiao_esp32s3/firmware.bin \
  --path firmware/brine-firmware-1.1.0.bin
```

3. **Get download URL**:
```bash
firebase storage:get-url firmware/brine-firmware-1.1.0.bin
```

4. **Add Firestore document**:

Using Firebase Console:
- Go to Firestore Database
- Navigate to `firmware_versions` collection
- Add document with the structure shown above

Using Firebase Admin SDK (Node.js):
```javascript
const admin = require('firebase-admin');
admin.initializeApp();

await admin.firestore().collection('firmware_versions').add({
  version: "1.1.0",
  version_number: 110,
  download_url: "https://firebasestorage.googleapis.com/...",
  release_notes: "Bug fixes and improvements",
  active: true,
  created_at: new Date().toISOString(),
  file_size: 987654
});
```

### Deactivating a Version

To prevent devices from updating to a specific version:

```javascript
await admin.firestore()
  .collection('firmware_versions')
  .doc('version-doc-id')
  .update({ active: false });
```

### Rollback Strategy

If a firmware version has issues:

1. Set problematic version to `active: false`
2. Ensure previous stable version has `active: true`
3. Devices will receive the stable version on next check

## Monitoring

### Cloud Function Logs

View logs in Firebase Console:
```
Firebase Console → Functions → checkFirmwareUpdate → Logs
```

Or using CLI:
```bash
firebase functions:log --only checkFirmwareUpdate
```

### Device Update Tracking

Query devices that checked for updates recently:

```javascript
const recentChecks = await admin.firestore()
  .collection('devices')
  .where('last_update_check', '>', new Date(Date.now() - 24*60*60*1000))
  .get();
```

Query devices with available updates:

```javascript
const devicesWithUpdates = await admin.firestore()
  .collection('devices')
  .where('available_firmware_version', '>', '1.0.0')
  .get();
```

## Testing

### Run Unit Tests

```bash
cd brine_cloud_functions/functions
npm test -- checkFirmwareUpdate.test.cjs
```

### Test with Emulator

1. **Start emulator**:
```bash
cd brine_cloud_functions
firebase emulators:start
```

2. **Add test data to Firestore emulator**:
```javascript
// Use Firebase Console UI at http://localhost:4000
// Or use Admin SDK pointing to emulator
```

3. **Test endpoint**:
```bash
curl -X POST http://localhost:5001/brine-3b212/us-central1/checkFirmwareUpdate \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "test-device",
    "current_version": "1.0.0"
  }'
```

## Security Considerations

### Current Implementation

- No authentication required (devices call directly)
- Public read access to firmware files in Storage
- Version comparison prevents downgrade attacks

### Recommended Enhancements

1. **Device Authentication**:
```javascript
// Add HMAC signature verification similar to updateDeviceLevels
const deviceId = req.headers['x-device-id'];
const providedHmac = req.headers['x-hmac-signature'];
// Verify HMAC...
```

2. **Rate Limiting**:
```javascript
// Implement rate limiting per device
// Prevent abuse of update checks
```

3. **Firmware Signing**:
```javascript
// Add digital signature to firmware_versions documents
// Verify signature on device before applying update
```

## Troubleshooting

### Function Returns No Firmware Versions

**Problem**: `firmware_versions` collection is empty

**Solution**: Add at least one firmware version document to Firestore

### Device Can't Download Firmware

**Problem**: Storage rules block access

**Solution**: Verify storage rules allow public read for `/firmware/*`

### Version Comparison Issues

**Problem**: Incorrect version format

**Solution**: Ensure versions follow semantic versioning (major.minor.patch)

### Function Timeout

**Problem**: Function takes too long to respond

**Solution**: 
- Check Firestore indexes are created
- Verify network connectivity
- Review function logs for errors

## Cost Optimization

### Storage Costs

- Firmware binaries are typically 500KB - 2MB
- Keep only recent versions (e.g., last 5 versions)
- Delete old firmware files from Storage

### Function Invocations

- Devices check for updates once per wake cycle (typically 24 hours)
- 1000 devices = ~30,000 invocations/month
- Well within Firebase free tier

### Firestore Reads

- Each update check = 1 read from `firmware_versions`
- Each update check = 1 write to `devices` (tracking)
- Optimize by caching latest version in memory (future enhancement)

## Future Enhancements

- [ ] Add device authentication to update endpoint
- [ ] Implement firmware signature verification
- [ ] Add support for device groups/channels (beta, stable, etc.)
- [ ] Create admin dashboard for firmware management
- [ ] Add automatic cleanup of old firmware files
- [ ] Implement update analytics and reporting
- [ ] Add support for forced updates
- [ ] Create webhook notifications for update events
- [ ] Add support for delta updates
- [ ] Implement A/B testing for firmware versions
