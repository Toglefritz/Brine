# Brine

![Brine logo](brine_logos/Brine_256.png)

Brine is an IoT water softener monitor. It tracks the amount of salt remaining in a water softener
and delivers alerts when the level is low, keeping your appliances free of mineral deposits, your
hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

The project spans hardware, firmware, a mobile companion app, cloud backend services, and a
marketing website.

## How It Works

A Brine device mounts inside the lid of a water softener, facing down toward the salt. It uses a
VL53L1X distance sensor to measure the distance from the top of the softener to the salt surface,
then calculates an approximate percentage of salt remaining. The device wakes from deep sleep once
every 24 hours to take a measurement, report it to the cloud, and go back to sleep.

Users set up a Brine device through the companion mobile app using Bluetooth Low Energy. The app
walks through pairing, WiFi provisioning, and account association. Once provisioned, the app
displays a dashboard with salt level, battery level, and device information, and delivers push
notifications when levels are low.

## Repository Structure

| Directory | Description |
|---|---|
| [`brine_app`](brine_app/) | Flutter companion app for iOS, Android, and macOS. Handles device provisioning via BLE and displays device status on a dashboard. |
| [`brine_firmware`](brine_firmware/) | ESP32 firmware built with PlatformIO and the Arduino framework. Manages the distance sensor, battery monitoring, BLE communication, and deep sleep. |
| [`brine_cloud_functions`](brine_cloud_functions/) | Firebase Cloud Functions that form the backend infrastructure. Handles device registration, data ingestion, and push notifications. |
| [`brine_website`](brine_website/) | Flutter web marketing site for the Brine product. |
| [`brine_docs`](brine_docs/) | Project documentation covering OTA updates, power management, provisioning, and security. |
| [`brine_electronics`](brine_electronics/) | PCB designs, Gerber files, prototypes, and reference materials for the Brine hardware. |
| [`brine_cad`](brine_cad/) | 3D models and drawings for the device enclosure (Plasticity, STEP, and STL formats). |
| [`brine_logos`](brine_logos/) | Brand assets and logo files in various formats. |
| [`brine_store_listings`](brine_store_listings/) | App store listing assets including screenshots and feature graphics. |
| [`brine_dev_tui`](brine_dev_tui/) | Terminal UI launcher for starting development tools (firmware flashing, emulator, serial monitor, Flutter app, Firebase emulator). |

## Development Launcher

The project includes a terminal UI for launching the various tools needed during local development.
Instead of remembering individual commands across multiple directories, the launcher provides a
single interface to start everything from one place.

Double-click `brine_dev_tui/Brine Launcher.command` in Finder to build and run it, or from the
terminal:

```sh
cd brine_dev_tui
go build -o brine-launcher .
./brine-launcher
```

See [`brine_dev_tui/README.md`](brine_dev_tui/README.md) for controls and architecture details.

## Technology Overview

- **Firmware**: C++ on ESP32 via PlatformIO / Arduino framework
- **Mobile App**: Flutter (Dart), targeting iOS, Android, and macOS
- **Backend**: Firebase (Cloud Functions, Firestore, Authentication, Cloud Messaging)
- **Website**: Flutter Web, hosted on Firebase Hosting
- **Hardware**: Custom PCB with ESP32 and VL53L1X distance sensor, powered by rechargeable LiPo battery
- **CAD**: Plasticity for enclosure design
