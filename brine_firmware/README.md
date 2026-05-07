# Brine Device Firmware

This repository contains the firmware for Brine, an IoT device that monitors the amount of salt remaining in a water softener.

# Hello :wave:

Do you ever forget to refill the salt in your water softener? Yes you do. It is probably a safe bet to say that everybody who has a water softener in their home forgets to refill the salt from time to time. That "time to time" might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener and delivers alerts when the level is low. With this tool, you can keep your water softener filled with salt and working properly, which, in turn, will keep your appliances free of mineral deposits, your hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

## Hardware

The Brine device is built around the ESP32, a powerful, versatile microcontroller that provides the WiFi connectivity necessary for the IoT functionality of the device and BLE connectivity necessary for its setup process. The ESP32 was chosen for its combination of processing power, connectivity options, and power efficiency, which is crucial for a battery-powered device.

The primary sensor used by the Brine device is the VL53L1X distance sensor. This sensor measures the distance from the top of the water softener to the level of the salt within the appliance. By comparing this measurement to the known distance when the water softener is empty, the device can calculate an approximate percentage of salt remaining.

For user feedback, the device includes an LED. This LED can display different patterns to indicate the device's status. This system is mainly used during the provisioning process and the LED generally remains off during normal operation so its use does not affect the battery life of the device.

The device is powered by a rechargeable lithium polymer battery. To maximize battery life, the device spends most of its time in a deep sleep state. It wakes up once every 24 hours to measure the salt level, send the data to the backend services, and then returns to the deep sleep state. This power management strategy allows the device to operate for extended periods without requiring a battery change.

The device is designed to be mounted inside the lid of a water softener, facing down towards the salt. This positioning allows the distance sensor to accurately measure the salt level.

## Firmware

The firmware for the Brine device is written using PlatformIO, an open-source ecosystem for IoT development, in conjunction with Visual Studio Code, a powerful and versatile code editor. The Arduino framework is used due to its simplicity, robustness, and the vast amount of resources and libraries available.

The firmware follows a service-oriented architecture, encapsulating different pieces of functionality into their own modules. This design allows for a high degree of modularity and reusability, making the firmware easier to understand, maintain, and extend.

Each service in the firmware is responsible for a specific piece of functionality. For example, there might be a service for managing the distance sensor, another for handling communication with the backend services, and yet another for controlling the RGB LED.

The firmware also includes power management functionality to ensure the device spends most of its time in a deep sleep state, waking up only to perform measurements and communicate with the backend services. This approach maximizes battery life and ensures the device can operate for extended periods without requiring a battery change.

```mermaid
graph LR
    A[main.cpp] --> B[Button Service]
    A --> C[LED Service]
    A --> D[Distance Sensor Service]
    A --> F[Battery Monitor Service]
    B --> G[Button Hardware]
    C --> H[LED Hardware]
    D --> I[Distance Sensor Hardware]
    F --> K[Battery Monitor Hardware]
```

## Getting Started

To start working with the Brine device firmware, follow these steps:

### Setting Up the Development Environment
1. Install [Visual Studio Code](https://code.visualstudio.com/download).
2. Open Visual Studio Code and navigate to the Extensions view (View -> Extensions).
3. Search for and install the PlatformIO IDE extension.

### Adding Libraries
The Brine device firmware uses several libraries. To add them to your project:
1. Open the PlatformIO home page in Visual Studio Code (View -> PlatformIO).
2. Navigate to Libraries.
3. Search for and install the following libraries: (List the libraries used by the project)

### Connecting the Device
1. Connect the Brine device to your development machine using a USB cable.
2. In Visual Studio Code, open the PlatformIO home page.
3. Navigate to Devices to verify that the Brine device is recognized.

### Flashing Firmware
1. Open the Brine device firmware project in Visual Studio Code.
2. Build the project by clicking the checkmark icon in the PlatformIO toolbar.
3. Upload the firmware to the device by clicking the right arrow icon in the PlatformIO toolbar.

After following these steps, your Brine device should be running the latest firmware and ready for use.

## Commenting and Documentation

Doxygen-style comments are used throughout this project for code documentation. This allows for the automatic generation of documentation and ensures that the codebase is easy to understand and maintain.

The following guidelines regarding documentation should be followed while working on this project:

1.  Always document code as it is written. It is much easier to write comments while the code is fresh in your mind and you still have the context in which it was written.
2. Use Doxygen-style comments (`/** ... */` for multi-line comments, `///` for single-line comments).
3.  Document all public APIs. Include a brief description, detailed description, parameters, and return values.
4.  Use `@brief` for a brief description, `@details` for a detailed description, `@param` for parameters, and `@return` for return values.
5.  For classes and structures, document what they represent and how they should be used.
6.  For functions, document what they do, what the parameters are, what value they return, if any, and the purpose for which they were created.

Here is a generic Doxygen comment template for a function:

```
/**
 * @brief Brief description of the function
 * @details Detailed description of the function
 * 
 * @param paramName Description of the parameter
 * @return Description of the return value
 */
void functionName(Type paramName) {
    // function body
}
```

And for a class:

```
/**
 * @brief Brief description of the class
 * @details Detailed description of the class
 */
class ClassName {
    // class body
}
```

## Bluetooth Communication

Brine devices utilize Bluetooth communication for the provisioning process. This technology allows for seamless and efficient communication between client devices, such as the companion Brine mobile app, and Brine IoT devices.

All Brine devices use the same UUID (Universally Unique Identifier) for their primary services. This UUID is a unique string of characters that identifies the services provided by the Brine device. It can be used as a filter by client devices when performing a scan for nearby Brine devices. The UUID for Brine devices is as follows:

> 6272696E-6573-616C-746D-6F6E69746F72

In addition to the primary service UUID, Brine devices also use the same UUID values for their BLE (Bluetooth Low Energy) characteristics. These characteristics are attributes that define the behavior of the Brine device. The UUIDs for these characteristics allow client devices to identify and interact with the correct characteristics on the Brine device.

### Bluetooth API Overview

The Bluetooth API implemented in the IoT device firmware allows for communication with a central device (such as a Flutter app) using a JSON-based protocol. This section provides an overview of the structure of the API, including the format for commands and responses, and details how the firmware processes these communications.

### Command Structure

Commands are received from the central device and are represented as JSON objects. Each command must include a command field specifying the type of command being issued.

**Example Command**

To request the device ID from the IoT device, the following JSON command is sent:

```json
{
    "command": "get_device_id"
}
```

### Response Structure

Responses are sent from the IoT device to the central device in reply to commands. Each response is represented as a JSON object and includes a response field specifying the type of response.

**Success Responses**

A successful response to the get_device_id command will include the device ID:

```json
{
    "response": "device_id",
    "device_id": "vast_teal_elephant"
}
```

**Error Responses**

If an error occurs or an unknown command is received, an error response is sent:

```json
{
    "response": "error",
    "message": "Unknown command"
}
```

## PlatformIO CLI Commands

### Flashing Firmware

Build and upload firmware to the connected device:

```bash
pio run -e seeed_xiao_esp32c3 --target upload
```

Build without uploading (compile check only):

```bash
pio run -e seeed_xiao_esp32c3
```

### Running Tests

Run a specific test suite on hardware:

```bash
pio test -e seeed_xiao_esp32c3 --filter <test_name>
```

For example, to run the GPIO button test:

```bash
pio test -e seeed_xiao_esp32c3 --filter test_GPIOButton
```

Run all tests:

```bash
pio test -e seeed_xiao_esp32c3
```

### Serial Monitor

Open the serial monitor to view debug output:

```bash
pio device monitor
```

### Clean Build

Remove all build artifacts and force a full rebuild:

```bash
pio run -e seeed_xiao_esp32c3 --target clean
```
