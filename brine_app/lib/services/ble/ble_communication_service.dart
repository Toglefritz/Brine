import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic_value.dart';

import '../../extensions/json.dart';

/// This class acts as a central manager for all BLE communication between the app and a Brine BLE peripheral for
/// which a connection has been established and service discovery has been performed.
///
/// When this app connects to a Brine BLE device, it will first discover the services and characteristics of the
/// device. Brine devices are expected to have a single service with a single characteristic. That single characteristic
/// is provided to this class during initialization. This service will first subscribe to this characteristic so it
/// can receive updates from the device in the form of changes in the value of the characteristic. Then, the app can
/// send write requests to the characteristic to send commands to the Brine device. When the Brine device processes
/// those commands, whether it does so successfully or not, it will send a response back to the app in the form of a
/// change in the value of the characteristic. The app can then listen for these changes and respond accordingly.
///
/// So, this class will hold a reference to the characteristic subscription, in the form of a [StreamSubscription] and
/// listen for changes in the value of the characteristic. This class will also maintain a list of callbacks that other
/// parts of the app can register to be notified when the value of the characteristic changes. When the value of the
/// characteristic changes, this class will notify all registered callbacks.
///
/// Also, the Brine device is limited in the total length of the data it can send in a single write request. Therefore,
/// the Brine device will split characteristic values into chunks of 512 bytes or less. The final chunk in each
/// sequence will be terminated by a 0x0A character. Therefore, when it receives a characteristic value, this class
/// will add it to a cache of received chunks. When it receives a chunk that ends with a 0x0A character, it will
/// concatenate all the chunks in the cache and notify the registered callbacks with the concatenated value. This
/// ensures that the app will receive the full response from the Brine device, even if it is split into multiple
/// chunks.
///
/// This class also exposes methods to send read and write requests to the characteristic. With the write requests
/// in particular, by listening for changes in the value of the characteristic before sending the request, the app
/// will be able to listen for the response from the Brine device and respond accordingly. This is preferable to
/// requiring manual read requests to be sent after each write request to check the status of the Brine device, because
/// race conditions in which the app will not know when the Brine device has finished processing a command can be
/// avoided.
class BleCommunicationService {
  /// Creates an instance of [BleCommunicationService] and subscribes to the characteristic of the Brine device.
  BleCommunicationService({required this.characteristic}) {
    // Subscribe to the characteristic so that the app can receive updates from the Brine device.
    _subscribeToCharacteristic();
  }

  /// The [BleCharacteristic] with which this service will interact.
  final BleCharacteristic characteristic;

  /// A [StreamSubscription] used to listen for changes in the value of the characteristic.
  StreamSubscription<BleCharacteristicValue>? _characteristicValueListener;

  /// A list of callbacks that will be notified when the value of the characteristic changes.
  ///
  /// This class will handle converting the [BleCharacteristicValue] into JSON format to be returned to the
  /// callbacks.
  final List<void Function(JSON)> _callbacks = [];

  /// Registers a callback to be notified when the value of the characteristic changes.
  void registerCallback(void Function(JSON) callback) {
    _callbacks.add(callback);
  }

  /// Unregisters a callback so that it will no longer be notified when the value of the characteristic changes.
  void unregisterCallback(void Function(JSON) callback) {
    _callbacks.remove(callback);
  }

  /// Subscribe to the [characteristic] and listen for changes in its value. When the value changes, notify all
  /// registered callbacks.
  ///
  /// The Brine device will divide characteristic values into chunks of 512 bytes or less. The final chunk in each
  /// sequence will be terminated by a 0x0A character. This method will concatenate all the chunks in the cache and
  /// notify the registered callbacks with the concatenated value.
  void _subscribeToCharacteristic() {
    // The full value of the characteristic will be built up from the chunks received from the Brine device.
    String characteristicValue = '';

    // Listen for changes in the value of the characteristic.
    _characteristicValueListener = characteristic.subscribe().listen(
          (value) {
        // Add the new chunk to the cache.
        characteristicValue += value.valueString;

        // If the chunk ends with a 0x0A character, it is the final chunk in the sequence.
        if (value.value.last == 0x0A) {
          // Notify all registered callbacks when the value of the characteristic changes.
          for (final void Function(JSON) callback in _callbacks) {
            // Convert the full value of the characteristic to a JSON object and pass it to the callback.
            final JSON characteristicValueJson = json.decode(characteristicValue) as JSON;

            callback(characteristicValueJson);
          }

          // Clear the cache for the next sequence of chunks.
          characteristicValue = '';
        }
      },
    );
  }

  /// Sends a write request to the characteristic with the given [value].
  ///
  /// If errors occur during the write operation, they will be caught and rethrown.
  // TODO(Toglefritz): Encrypt the write value before sending the command.
  Future<void> writeValue({required String value}) async {
    try {
      await characteristic.writeValue(value: value);
    } catch (e) {
      debugPrint('Failed to write value with exception, $e');

      rethrow;
    }
  }

  /// When the characteristic subscription is no longer needed, this method should be called to dispose of the
  /// subscription in order to avoid memory leaks.
  void dispose() {
    _characteristicValueListener?.cancel();
  }
}
