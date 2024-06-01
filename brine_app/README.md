# Brine

![Brine logo](assets/icons/brine.png)

The companion app for the Brine Monitor, an IoT device that monitors the amount of salt remaining
in a water softener.

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

# Hello :wave:

Do you ever forget to refill the salt in your water softener? Yes you do. It is probably a safe
bet to say that everybody who has a water softener in their home forgets to refill the salt from
time to time. That "time to time" might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener
and delivers alerts when the level is low. With this tool, you can keep your water softener filled
with salt and working properly, which, in turn, will keep your appliances free of mineral deposits,
your hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

# Application Flow

The application has two main workflows. First, the app implements a provisioning process used to 
add a Brine device to the user's account. This process consists of communicating with a target 
Brine device via Bluetooth Low Energy, connecting that device to a WiFi network, and performing an 
API call necessary to associate the Brine device to the user's account. 

Second, the app displays information about one or more Brine devices on a user's account on a 
"dashboard" screen, which includes the most recently reported salt and battery level for the 
device, as well as information about the device itself. The app will facilitate the delivery 
of push notifications when the battery and/or salt level on one of the Brine devices for a user
are low.

## Provisioning Flow (draft)

The diagram below shows the provisioning flow for a Brine device.

> Some details in this flow are still being implemented and may change over time.

```mermaid
sequenceDiagram
    participant User
    participant MobileApp
    participant BrineDevice
    participant Backend

    User ->> BrineDevice: Press button to initiate device activation
    BrineDevice ->> MobileApp: Start BLE advertising
    MobileApp ->> MobileApp: Scan for BLE devices
    MobileApp ->> BrineDevice: Discover Brine device
    MobileApp ->> BrineDevice: Perform BLE pairing and bonding
    MobileApp ->> BrineDevice: Retrieve device ID
    MobileApp ->> Backend: Send device ID and user ID
    Backend ->> Backend: Associate device with user account
    User ->> MobileApp: Provide WiFi credentials
    MobileApp ->> BrineDevice: Send WiFi credentials over BLE
    BrineDevice ->> BrineDevice: Connect to WiFi network
    BrineDevice ->> MobileApp: Report WiFi connection success
    BrineDevice ->> Backend: Send public key to cloud
    Backend ->> Backend: Verify device identity
    Backend ->> Backend: Store device public key
    MobileApp ->> User: Notify provisioning completion
```

# Firebase Local Emulator Notes

Development can be done against the Firebase local emulator rather than the live Firebase 
environment in order to prevent interference with the production environment and to provide a 
safe environment for development without billing.

Start the Firebase emulator with the command, `firebase emulators:start`.


