/// This script updates the device ID in the `device_config.h` file for the Brine IoT device firmware.
///
/// The `device_config.h` file contains configuration settings for the IoT device, including a unique
/// device ID that is assigned during the manufacturing process. This script automates the process
/// of updating the device ID, ensuring that each device receives a unique identifier in the format
/// `<adjective>_<adjective>_<noun>`.
///
/// The script works by reading the `device_config.h` file line by line, identifying the line that
/// defines the `DEVICE_ID` macro, and replacing its value with the new device ID provided as a
/// command-line argument. The modified file is then saved, effectively updating the device ID
/// for the firmware build.
///
/// ### How to Run the Script
///
/// 1. Ensure that the Dart SDK is installed on your system. You can download it from:
///    [https://dart.dev/get-dart](https://dart.dev/get-dart)
///
/// 2. Save this script as `update_device_id.dart` in your project directory.
///
/// 3. Open a terminal and navigate to the directory containing the script.
///
/// 4. Run the script using the Dart command-line tool, passing the new device ID as an argument:
///
///    ```sh
///    dart update_device_id.dart "new_device_id"
///    ```
///
///    Replace `"new_device_id"` with the actual device ID you want to set, for example:
///
///    ```sh
///    dart update_device_id.dart "amazing_blue_whale"
///    ```
///
/// 5. The script will update the `DEVICE_ID` definition in the `device_config.h` file and print
///    a confirmation message to the terminal.
///
/// ### Example Usage
///
/// ```sh
/// dart update_device_id.dart "amazing_blue_whale"
/// ```
///
/// This will update the `DEVICE_ID` in the `device_config.h` file to `"amazing_blue_whale"`.
///
/// @param arguments The list of command-line arguments passed to the script.
///                  This script expects a single argument: the new device ID.
import 'dart:io';

/// Updates the device ID in the `device_config.h` file.
///
/// This function reads the `device_config.h` file, identifies the line defining the `DEVICE_ID` macro,
/// and updates its value with the provided [newDeviceId]. The modified file is then saved.
///
/// @param newDeviceId The new device ID to be set in the `DeviceConfig.h` file.
void updateDeviceId(String newDeviceId) {
  const String configFile = 'include/DeviceConfig.h';

  // Read the lines of the file
  List<String> lines = File(configFile).readAsLinesSync();

  // Open the file for writing
  File file = File(configFile);
  IOSink sink = file.openWrite();

  // Update the DEVICE_ID line
  for (String line in lines) {
    if (line.startsWith('#define DEVICE_ID')) {
      sink.writeln('#define DEVICE_ID "$newDeviceId"');
    } else {
      sink.writeln(line);
    }
  }

  // Close the file
  sink.close();
}

/// The main function that runs the script.
///
/// This function checks if the correct number of command-line arguments are provided,
/// and then calls [updateDeviceId] with the new device ID. If the arguments are invalid,
/// it prints usage instructions and exits.
///
/// @param arguments The list of command-line arguments passed to the script.
///                  This script expects a single argument: the new device ID.
void main(List<String> arguments) {
  if (arguments.length != 1) {
    print('Usage: dart update_device_id.dart <new_device_id>');
    exit(1);
  }

  String newDeviceId = arguments[0];
  updateDeviceId(newDeviceId);
  print('Updated device ID to: $newDeviceId');
}