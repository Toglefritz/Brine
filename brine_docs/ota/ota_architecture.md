# Brine OTA System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Brine OTA System                         │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  Brine Device    │         │  Cloud Backend   │         │   Mobile App     │
│   (ESP32 C++)    │         │   (Firebase)     │         │  (Flutter/Dart)  │
└──────────────────┘         └──────────────────┘         └──────────────────┘
        │                             │                             │
        │                             │                             │
        ▼                             ▼                             ▼
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   OTAService     │         │ Cloud Functions  │         │  Future: BLE OTA │
│   WiFiService    │         │   Firestore      │         │   (Not Yet)      │
│   DeepSleep      │         │   Storage        │         │                  │
└──────────────────┘         └──────────────────┘         └──────────────────┘
```

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Cloud Infrastructure                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────┐      ┌────────────────────────┐                │
│  │  Cloud Function        │      │  Firestore Database    │                │
│  │  checkFirmwareUpdate   │◄────►│  firmware_versions     │                │
│  │                        │      │  - version             │                │
│  │  - Check version       │      │  - version_number      │                │
│  │  - Return download URL │      │  - download_url        │                │
│  │  - Track checks        │      │  - active              │                │
│  └────────────────────────┘      │  - release_notes       │                │
│             │                     └────────────────────────┘                │
│             │                                                                │
│             │                     ┌────────────────────────┐                │
│             │                     │  Firebase Storage      │                │
│             └────────────────────►│  /firmware/            │                │
│                                   │  - brine-firmware-*.bin│                │
│                                   └────────────────────────┘                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Brine Device (ESP32)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────┐      ┌────────────────────────┐                │
│  │  main.cpp              │      │  OTAService            │                │
│  │                        │      │                        │                │
│  │  - Wake from sleep     │      │  - checkForUpdate()    │                │
│  │  - Connect WiFi        │─────►│  - performCloudUpdate()│                │
│  │  - Check for update    │      │  - Download firmware   │                │
│  │  - Take measurements   │      │  - Write to OTA        │                │
│  │  - Deep sleep          │      │  - Verify & reboot     │                │
│  └────────────────────────┘      └────────────────────────┘                │
│             │                                                                │
│             │                     ┌────────────────────────┐                │
│             │                     │  ESP32 Update Library  │                │
│             └────────────────────►│  - OTA partition       │                │
│                                   │  - Verification        │                │
│                                   │  - Boot management     │                │
│                                   └────────────────────────┘                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Update Flow Sequence

```
Device                  Cloud Function              Firestore               Storage
  │                           │                         │                      │
  │ Wake from sleep           │                         │                      │
  │ Connect WiFi              │                         │                      │
  │                           │                         │                      │
  │ POST /checkFirmwareUpdate │                         │                      │
  │ {device_id, version}      │                         │                      │
  ├──────────────────────────►│                         │                      │
  │                           │                         │                      │
  │                           │ Query latest firmware   │                      │
  │                           ├────────────────────────►│                      │
  │                           │                         │                      │
  │                           │◄────────────────────────┤                      │
  │                           │ {version, url, active}  │                      │
  │                           │                         │                      │
  │                           │ Compare versions        │                      │
  │                           │                         │                      │
  │◄──────────────────────────┤                         │                      │
  │ {update_available: true,  │                         │                      │
  │  download_url, version}   │                         │                      │
  │                           │                         │                      │
  │ GET download_url          │                         │                      │
  ├─────────────────────────────────────────────────────────────────────────►│
  │                           │                         │                      │
  │◄────────────────────────────────────────────────────────────────────────┤
  │ Firmware binary (streaming)                         │                      │
  │                           │                         │                      │
  │ Write to OTA partition    │                         │                      │
  │ Verify firmware           │                         │                      │
  │ Reboot                    │                         │                      │
  │                           │                         │                      │
  ▼                           │                         │                      │
Boot with new firmware        │                         │                      │
```

## State Machine

```
┌─────────────┐
│   STARTUP   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ WAKE_REASON │
└──────┬──────┘
       │
       ├─── Timer ────────────────┐
       │                          │
       └─── Button ───────────┐   │
                              │   │
                              ▼   ▼
                         ┌────────────┐
                         │ WIFI_CONNECT│
                         └──────┬─────┘
                                │
                                ▼
                         ┌────────────┐
                         │ CHECK_OTA  │
                         └──────┬─────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
              Update Available        No Update
                    │                       │
                    ▼                       ▼
            ┌──────────────┐        ┌──────────────┐
            │ DOWNLOAD_FW  │        │ NORMAL_OPS   │
            └──────┬───────┘        └──────┬───────┘
                   │                       │
                   ▼                       │
            ┌──────────────┐              │
            │  VERIFY_FW   │              │
            └──────┬───────┘              │
                   │                       │
                   ▼                       │
            ┌──────────────┐              │
            │   REBOOT     │              │
            └──────────────┘              │
                                          │
                                          ▼
                                   ┌──────────────┐
                                   │ TAKE_READING │
                                   └──────┬───────┘
                                          │
                                          ▼
                                   ┌──────────────┐
                                   │ UPLOAD_DATA  │
                                   └──────┬───────┘
                                          │
                                          ▼
                                   ┌──────────────┐
                                   │ DEEP_SLEEP   │
                                   └──────────────┘
```

## Data Flow

### Update Check Request
```
Device → Cloud Function
{
  "device_id": "brine-device-123",
  "current_version": "1.0.0"
}
```

### Update Check Response (Update Available)
```
Cloud Function → Device
{
  "update_available": true,
  "latest_version": "1.1.0",
  "download_url": "https://storage.googleapis.com/...",
  "release_notes": "Bug fixes and improvements"
}
```

### Update Check Response (No Update)
```
Cloud Function → Device
{
  "update_available": false,
  "message": "Current version is up to date.",
  "current_version": "1.0.0",
  "latest_version": "1.0.0"
}
```

### Firestore Document Structure
```
firmware_versions/{doc_id}
{
  "version": "1.1.0",
  "version_number": 110,
  "download_url": "https://storage.googleapis.com/...",
  "release_notes": "Bug fixes and improvements",
  "active": true,
  "created_at": "2025-11-27T10:00:00Z",
  "file_size": 987654,
  "checksum": "sha256:..." (optional)
}
```

### Device Tracking
```
devices/{device_id}
{
  // ... existing fields ...
  "last_update_check": "2025-11-27T10:30:00Z",
  "available_firmware_version": "1.1.0",
  "current_firmware_version": "1.0.0" (future)
}
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Device     │    │   Firebase   │    │   Mobile     │
│   (WiFi)     │    │   (Cloud)    │    │   App        │
└──────────────┘    └──────────────┘    └──────────────┘
        │                     │                     │
        │                     │                     │
        │    HTTPS/443        │                     │
        ├────────────────────►│                     │
        │                     │                     │
        │◄────────────────────┤                     │
        │                     │                     │
        │                     │    HTTPS/443        │
        │                     │◄────────────────────┤
        │                     │                     │
        │                     ├────────────────────►│
        │                     │                     │
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Security Layers                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Layer 1: Transport Security                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │  HTTPS/TLS for all cloud communications            │    │
│  │  - Encrypted data in transit                       │    │
│  │  - Certificate validation                          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Layer 2: Access Control                                    │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Firebase Storage Rules                            │    │
│  │  - Public read for /firmware/*                     │    │
│  │  - Authenticated write only                        │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Layer 3: Version Control                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Semantic versioning prevents downgrades           │    │
│  │  Active flag allows disabling versions             │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Layer 4: Verification (Future)                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Firmware signature verification                   │    │
│  │  Checksum validation                               │    │
│  │  Device authentication                             │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Development Environment                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │  Local Dev   │      │  Firebase    │                    │
│  │  Machine     │─────►│  Emulator    │                    │
│  │              │      │  Suite       │                    │
│  └──────────────┘      └──────────────┘                    │
│                                                              │
│  FLAVOR=1 (Dev)                                             │
│  Endpoint: http://192.168.86.39:5001/...                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Deploy
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Production Environment                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │  Firebase    │      │  Cloud       │                    │
│  │  Hosting     │      │  Functions   │                    │
│  │              │      │              │                    │
│  └──────────────┘      └──────────────┘                    │
│                                                              │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │  Firestore   │      │  Storage     │                    │
│  │  Database    │      │  Buckets     │                    │
│  │              │      │              │                    │
│  └──────────────┘      └──────────────┘                    │
│                                                              │
│  FLAVOR=2 (Prod)                                            │
│  Endpoint: https://checkfirmwareupdate-7wo3szegoq-uc...    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Future: Bluetooth OTA Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Bluetooth OTA (Future)                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Mobile App                          Brine Device           │
│  ┌──────────────┐                   ┌──────────────┐       │
│  │              │                   │              │       │
│  │  Download    │                   │  BLE Server  │       │
│  │  Firmware    │                   │              │       │
│  │  from Cloud  │                   │  OTA Service │       │
│  │              │                   │  UUID: 0x...  │       │
│  └──────┬───────┘                   └──────▲───────┘       │
│         │                                  │               │
│         │         BLE Connection           │               │
│         └──────────────────────────────────┘               │
│                                                              │
│  Characteristics:                                           │
│  - Control (Write): START, ABORT, FINALIZE                 │
│  - Data (Write): Firmware chunks (512 bytes)               │
│  - Status (Read/Notify): Progress updates                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Monitoring & Analytics                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │  Cloud Function Logs                             │      │
│  │  - Update check requests                         │      │
│  │  - Version comparisons                           │      │
│  │  - Errors and exceptions                         │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │  Firestore Tracking                              │      │
│  │  - last_update_check per device                  │      │
│  │  - available_firmware_version                    │      │
│  │  - Update success/failure rates                  │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │  Device Serial Logs                              │      │
│  │  - Update progress                               │      │
│  │  - Download status                               │      │
│  │  - Verification results                          │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │  Future: Analytics Dashboard                     │      │
│  │  - Fleet-wide update status                      │      │
│  │  - Version distribution                          │      │
│  │  - Update success metrics                        │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## File Structure

```
Brine/
├── brine_firmware/
│   ├── include/
│   │   └── OTAService.h              # OTA service interface
│   ├── lib/
│   │   └── OTAService/
│   │       └── OTAService.cpp        # OTA implementation
│   ├── src/
│   │   └── main.cpp                  # Main firmware (OTA integrated)
│   ├── OTA_IMPLEMENTATION.md         # Firmware OTA docs
│   ├── BLUETOOTH_OTA_DESIGN.md       # BLE OTA design
│   └── deploy_firmware.sh            # Deployment script
│
├── brine_cloud_functions/
│   ├── functions/
│   │   ├── src/
│   │   │   └── checkFirmwareUpdate.cjs  # Update check function
│   │   ├── test/
│   │   │   └── checkFirmwareUpdate.test.cjs  # Tests
│   │   └── index.cjs                 # Function exports
│   ├── manage_firmware.js            # Firestore management
│   └── OTA_SETUP.md                  # Cloud setup docs
│
├── OTA_QUICK_START.md                # Quick reference
├── OTA_IMPLEMENTATION_SUMMARY.md     # Implementation summary
├── OTA_DEPLOYMENT_CHECKLIST.md       # Deployment checklist
└── OTA_ARCHITECTURE.md               # This file
```

## Technology Stack

### Device (ESP32)
- **Language**: C++
- **Framework**: Arduino
- **Platform**: ESP32 (Seeed XIAO ESP32-S3)
- **Libraries**: 
  - ESP32 Update (OTA)
  - HTTPClient (Downloads)
  - ArduinoJson (Parsing)
  - WiFi (Connectivity)

### Cloud (Firebase)
- **Functions**: Node.js (CommonJS)
- **Database**: Firestore
- **Storage**: Firebase Storage
- **Hosting**: Cloud Run (auto-scaled)

### Tools
- **Build**: PlatformIO
- **Deploy**: Firebase CLI
- **Testing**: Jest
- **Management**: Node.js scripts

## Performance Characteristics

### Update Check
- **Frequency**: Once per wake cycle (24 hours)
- **Duration**: ~2-5 seconds
- **Data Transfer**: ~500 bytes (request + response)
- **Battery Impact**: Minimal

### Firmware Download
- **Size**: ~500KB - 1.5MB
- **Duration**: ~30-60 seconds (depends on WiFi)
- **Data Transfer**: Firmware size
- **Battery Impact**: Moderate (5-10% battery)

### Update Installation
- **Duration**: ~10-20 seconds
- **Verification**: ~5 seconds
- **Reboot**: ~5 seconds
- **Total**: ~1-2 minutes end-to-end

## Scalability

### Current Capacity
- **Devices**: Unlimited (Firebase scales automatically)
- **Concurrent Updates**: Limited by WiFi bandwidth
- **Storage**: Unlimited (pay per GB)
- **Function Invocations**: 2M free/month, then pay per use

### Optimization Strategies
- Stagger update checks (random delay)
- Cache firmware in CDN
- Compress firmware binaries
- Delta updates (future)
- Scheduled update windows (future)

## Reliability

### Failure Modes
1. **Network Failure**: Retry on next wake cycle
2. **Download Failure**: Abort, retry later
3. **Verification Failure**: Abort, stay on current version
4. **Installation Failure**: ESP32 boots to previous version
5. **Cloud Function Error**: Device continues normal operation

### Recovery Mechanisms
- Automatic retry on next wake
- Rollback via active flag
- ESP32 bootloader fallback
- Device continues operation on failure
- No bricking risk

## Cost Analysis

### Per Device Per Month
- **Function Invocations**: ~30 (1 per day)
- **Firestore Reads**: ~30
- **Firestore Writes**: ~30
- **Storage**: ~1MB (shared across fleet)
- **Bandwidth**: ~1MB (if update available)

### Fleet of 1000 Devices
- **Function Invocations**: ~30,000/month (free tier: 2M)
- **Firestore Operations**: ~60,000/month (free tier: 50K reads, 20K writes)
- **Storage**: ~5MB (last 5 versions)
- **Bandwidth**: Variable (depends on update frequency)

**Estimated Cost**: $0-5/month for 1000 devices (mostly free tier)
