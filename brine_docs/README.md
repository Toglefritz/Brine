# Brine

![Brine logo](assets/icons/brine.png)

Documentation for the Brine Monitor, an IoT device that monitors the amount of salt remaining
in a water softener.

## Hello :wave:

Do you ever forget to refill the salt in your water softener? Yes you do. It is probably a safe
bet to say that everybody who has a water softener in their home forgets to refill the salt from
time to time. That "time to time" might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener
and delivers alerts when the level is low. With this tool, you can keep your water softener filled
with salt and working properly, which, in turn, will keep your appliances free of mineral deposits,
your hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

## Table of Contents

1. [Power](power/)
    - [battery_monitoring](power/battery_monitoring.md): Describes the voltage divider circuit used to monitor the voltage of the AA batteries that power the Brine device, including resistor selection and safe input levels for the ESP32 analog pin.
    - [deep_sleep_handling](power/deep_sleep_handling.md): Explains how the Brine firmware uses the ESP32's deep sleep mode to conserve battery, including the 24-hour wake cycle, timer and GPIO wakeup sources, and the setup mode triggered by a physical button press.
2. [OTA](ota/)
    - [ota_architecture](ota/ota_architecture.md): Documents the architecture of the over-the-air firmware update system, covering the device, cloud, and mobile components, the update flow sequence, data formats, security layers, and deployment topology.
    - [ota_setup](ota/ota_setup.md): A setup guide for the OTA cloud infrastructure, including Firebase Cloud Function deployment, Firestore collection configuration, Storage rules, firmware version management, and testing procedures.
3. [Provisioning](provisioning/)
    - [provisioning_process](provisioning/provisioning_process.md): Walks through the full provisioning sequence for a new Brine device, from physical button activation and BLE pairing through device association, PSK transfer, WiFi credential exchange, hardware installation, and appliance height configuration.
4. [Security](security/)
    - [hmac_security](security/hmac_security.md): Explains the HMAC-based request signing mechanism used to authenticate data sent from Brine devices to the Firebase backend, including how PSKs are provisioned, how signatures are generated and verified, and how keys can be rotated or revoked.
5. [Cloud](cloud/)
    - [cloud_infrastructure](cloud/cloud_infrastructure.md): Describes the Firebase-based cloud backend, including the Firestore data model, the set of Cloud Functions exposed as HTTP endpoints, authentication and HMAC verification, push notifications, and local development with the Firebase Emulator Suite.