# Brine OTA (Over-The-Air) Firmware Update System

## Overview

The Brine device supports Over-The-Air (OTA) firmware updates through two methods:
1. **Cloud-based updates** (Primary method) - Firmware is downloaded from Firebase Storage via WiFi
2. **Bluetooth-based updates** (Backup method) - Firmware is transferred via BLE (future enhancement)

## Architecture

### Cloud Components

#### Firebase Cloud Function: `checkFirmwareUpdate`
- **Endpoint**: `/checkFirmwareUpdate`
- **Method**: POST
- **Purpose**: Checks if a newer firmware version is available for a device

**Request Body**:
```json
{
  "device_id": "device-123",
  "current_version": "1.0.0"
}
```

**Response (Update Available)**:
```json
{
  "update_available": true,
  "latest_version": "1.1.0",
  "download_url": "https://storage.googleapis.com/...",
  "release_notes": "Bug fixes and improvements"
}
```

**Response (No Update)**:
```json
{
  "update_available": false,
  "message": "Current version is up to date.",
  "current_version": "1.0.0",
  "latest_version": "1.0.0"
}
```

#### Firestore Collection: `firmware_versions`

Each firmware version document contains:
```javascript
{
  version: "1.1.0",              // Semantic version string
  version_number: 110,           // Numeric version for sorting (major*100 + minor*10 + patch)
  download_url: "https://...",   // Firebase Storage URL for firmware binary
  release_notes: "...",          // Optional release notes
  active: true,                  // Whether this version should be offered to devices
  created_at: "2025-11-27T...",  // Timestamp
  file_size: 1234567,            // Size in bytes
  checksum: "sha256:..."         // Optional checksum for verification
}
```

### Firmware Components

#### OTAService Class
Located in `lib/OTAService/`

**Key Methods**:
- `checkForUpdate(String &latestVersion, String &downloadUrl)` - Queries cloud for updates
- `performCloudUpdate(const String &downloadUrl)` - Downloads and applies firmware
- `beginBluetoothUpdate(size_t firmwareSize)` - Prepares for BLE update
- `writeBluetoothChunk(const uint8_t *data, size_t len)` - Writes BLE data chunk
- `endBluetoothUpdate()` - Finalizes BLE update
- `getCurrentVersion()` - Returns current firmware version
- `abortUpdate()` - Cancels an in-progress update

#### Firmware Version
Defined in `include/OTAService.h`:
```cpp
#define FIRMWARE_VERSION "1.0.0"
```

**Important**: Update this version string with each firmware release.

## Update Workflow

### Cloud Update Process

1. **Device Wake-Up**
   - Device wakes from deep sleep (timer or button press)
   - Connects to WiFi using saved credentials
   - Calls `_checkAndPerformOTAUpdate()`

2. **Update Check**
   - Device sends current version to `checkFirmwareUpdate` endpoint
   - Cloud function queries Firestore for latest active firmware
   - Compares versions using semantic versioning

3. **Update Download & Installation**
   - If update available, device downloads firmware binary
   - ESP32 Update library writes to OTA partition
   - Progress is logged every 10%
   - LED indicates update in progress

4. **Verification & Reboot**
   - Firmware is verified
   - Device reboots into new firmware
   - On next wake, device reports new version

### Update Trigger Points

The device checks for updates at two key moments:

1. **Periodic Wake-Up** (Primary)
   - Device wakes from deep sleep to take measurements
   - Checks for updates before uploading sensor data
   - Ensures devices stay updated during normal operation

2. **Provisioning Start** (Secondary)
   - When user presses button to enter provisioning mode
   - Checks for updates before starting BLE advertising
   - Allows updates even if device is not regularly waking

## Deploying Firmware Updates

### Step 1: Build New Firmware

```bash
cd brine_firmware
# Update FIRMWARE_VERSION in include/OTAService.h
pio run -e seeed_xiao_esp32s3
```

The compiled binary will be at:
`.pio/build/seeed_xiao_esp32s3/firmware.bin`

### Step 2: Upload to Firebase Storage

```bash
# Upload to Firebase Storage
firebase storage:upload .pio/build/seeed_xiao_esp32s3/firmware.bin \
  --path firmware/brine-firmware-1.1.0.bin

# Get the download URL
firebase storage:get-url firmware/brine-firmware-1.1.0.bin
```

### Step 3: Create Firestore Document

Add a document to the `firmware_versions` collection:

```javascript
{
  version: "1.1.0",
  version_number: 110,  // 1*100 + 1*10 + 0
  download_url: "https://firebasestorage.googleapis.com/...",
  release_notes: "Bug fixes and performance improvements",
  active: true,
  created_at: new Date().toISOString(),
  file_size: 987654
}
```

### Step 4: Monitor Rollout

- Check device documents for `last_update_check` and `available_firmware_version` fields
- Monitor Cloud Function logs for update requests
- Devices will update on their next wake cycle

### Step 5: Rollback (if needed)

To rollback a problematic update:
1. Set the problematic version's `active` field to `false`
2. Ensure the previous stable version has `active: true`
3. Devices will receive the stable version on next check

## Bluetooth OTA (Future Enhancement)

The OTAService class includes methods for Bluetooth-based updates, designed for scenarios where:
- Device cannot connect to WiFi
- User needs to update device manually
- Emergency updates are required

### Planned BLE Update Flow

1. User initiates update from mobile app
2. App transfers firmware binary in chunks via BLE
3. Device writes chunks to OTA partition
4. After complete transfer, device verifies and reboots

### Implementation Considerations

- **Chunk Size**: Recommend 512 bytes per BLE packet
- **Progress Tracking**: App should display progress to user
- **Error Handling**: Support resume/retry on connection loss
- **Security**: Consider encrypting firmware during transfer
- **BLE Characteristics**: 
  - Control characteristic for commands (start, abort, finalize)
  - Data characteristic for firmware chunks
  - Status characteristic for progress updates

## Security Considerations

### Current Implementation
- Firmware downloads use HTTPS in production
- Firebase Storage URLs include authentication tokens
- Version comparison prevents downgrade attacks

### Future Enhancements
- Add firmware signature verification
- Implement checksum validation
- Add device authentication to update endpoint
- Consider encrypted firmware binaries
- Add rollback protection

## Testing

### Local Testing with Emulator

1. Start Firebase emulator:
```bash
cd brine_cloud_functions
firebase emulators:start
```

2. Build firmware with dev configuration:
```bash
cd brine_firmware
pio run -e seeed_xiao_esp32s3 -t upload
```

3. Monitor serial output:
```bash
pio device monitor
```

### Testing Update Flow

1. Create test firmware version in Firestore emulator
2. Trigger device wake-up (button press or wait for timer)
3. Observe update check in serial monitor
4. Verify firmware download and installation

### Unit Tests

Cloud function tests are in:
`brine_cloud_functions/functions/test/checkFirmwareUpdate.test.cjs`

Run tests:
```bash
cd brine_cloud_functions/functions
npm test
```

## Troubleshooting

### Device Not Checking for Updates
- Verify WiFi connection is successful
- Check Firebase endpoint URL in OTAService.cpp
- Ensure FLAVOR is correctly set in platformio.ini

### Update Check Fails
- Verify `firmware_versions` collection exists
- Check Cloud Function logs for errors
- Ensure device can reach Firebase endpoints

### Update Download Fails
- Verify download URL is accessible
- Check device has sufficient free space
- Ensure stable WiFi connection during download

### Device Doesn't Reboot After Update
- Check serial logs for Update.end() errors
- Verify firmware binary is valid
- Ensure partition table supports OTA

## Configuration

### Development vs Production

Set in `platformio.ini`:
```ini
build_flags = 
    -D FLAVOR=1  # Development (emulator)
    # or
    -D FLAVOR=2  # Production (live Firebase)
```

### Endpoints

**Development**:
- `http://192.168.86.39:5001/brine-3b212/us-central1/checkFirmwareUpdate`

**Production**:
- `https://checkfirmwareupdate-7wo3szegoq-uc.a.run.app`

Update the IP address in `OTAService.cpp` if your emulator runs on a different machine.

## Monitoring & Analytics

### Device-Level Tracking

Each device document tracks:
- `last_update_check`: Timestamp of last update check
- `available_firmware_version`: Latest version available to device
- `current_firmware_version`: Currently running version (future)

### Recommended Metrics

- Update check frequency
- Update success/failure rates
- Time to update across fleet
- Version distribution across devices
- Update-related errors

## Best Practices

1. **Version Numbering**: Use semantic versioning (major.minor.patch)
2. **Testing**: Test updates thoroughly before marking as active
3. **Gradual Rollout**: Consider phased rollouts for major updates
4. **Rollback Plan**: Always have a stable version ready to rollback to
5. **Release Notes**: Document changes for debugging and support
6. **Size Optimization**: Keep firmware size minimal to reduce download time
7. **Battery Awareness**: Updates consume significant power; ensure adequate battery

## Future Improvements

- [ ] Implement Bluetooth OTA updates
- [ ] Add firmware signature verification
- [ ] Support delta updates (only changed portions)
- [ ] Add update scheduling (specific time windows)
- [ ] Implement A/B partition updates for safer rollback
- [ ] Add update progress reporting to cloud
- [ ] Support forced updates for critical security patches
- [ ] Add update analytics dashboard
- [ ] Implement device grouping for staged rollouts
- [ ] Add automatic rollback on boot failure
