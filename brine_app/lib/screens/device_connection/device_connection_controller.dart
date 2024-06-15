import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic_value.dart';
import 'package:flutter_splendid_ble/central/models/ble_connection_state.dart';
import 'package:flutter_splendid_ble/central/models/ble_service.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import '../../services/ble_api/command.dart';
import '../../services/ble_api/command_type.dart';
import '../../services/ble_api/device_response.dart';
import '../../services/ble_api/response.dart';
import '../association/association_route.dart';
import 'device_connection_route.dart';
import 'device_connection_view.dart';

/// Controller for the [DeviceConnectionRoute].
class DeviceConnectionController extends State<DeviceConnectionRoute> {
  /// An instance of the [SplendidBle] service used for the Bluetooth scanning process.
  final SplendidBle _ble = SplendidBle();

  /// A [StreamSubscription] used to listen for changes in the connection status between the app and the [BleDevice].
  StreamSubscription<BleConnectionState>? _connectionStream;

  /// A [StreamSubscription] used to listen for discovered services.
  StreamSubscription<List<BleService>>? _servicesDiscoveredStream;

  /// A [StreamSubscription] used to listen for updates in the value of a characteristic.
  StreamSubscription<BleCharacteristicValue>? _characteristicValueListener;

  @override
  void initState() {
    // Start the process of connecting to the provided BleDevice.
    _connectToDevice();

    super.initState();
  }

  /// Attempt to connect to the [BleDevice] that is targeted for provisioning.
  void _connectToDevice() {
    try {
      _connectionStream = _ble.connect(deviceAddress: widget.device.address).listen(
            _onConnectionStateUpdate,
          );
    } catch (e) {
      debugPrint('Failed to connect to device, ${widget.device.address}, with exception, $e');

      _handleConnectionError(e);
    }
  }

  /// Handles errors resulting from an attempt to connect to a peripheral.
  void _handleConnectionError(Object error) {
    // Handle errors in connecting to a peripheral.
  }

  /// Called when the connection state is updated.
  ///
  /// The app waits for a connection to the Brine device to be established before moving on to performing service
  /// and characteristic discovery.
  // TODO(Toglefritz): add a timeout
  void _onConnectionStateUpdate(BleConnectionState state) {
    debugPrint('Connection state update for ${widget.device.name}: ${state.name}');

    if (state == BleConnectionState.connected) {
      _discoverServices();
    }
  }

  /// Discovers services and characteristics from the Brine monitor.
  void _discoverServices() {
    _servicesDiscoveredStream = _ble.discoverServices(widget.device.address).listen(
          _onServiceDiscovered,
        );
  }

  /// Called when a services are successfully discovered.
  void _onServiceDiscovered(List<BleService> services) {
    debugPrint('Discovered ${services.length} service(s): ${services.map((service) => service.serviceUuid)}');

    // Ensure that the expected single service containing a single characteristic were discovered.
    if (services.length != 1 || services.first.characteristics.length != 1) {
      debugPrint('Unexpected BLE device service configuration discovered.');

      // TODO(Toglefritz): Handle this error condition

      return;
    }

    // Get the single characteristic available from the Brine monitor.
    final BleCharacteristic characteristic = services.first.characteristics.first;

    // Subscribe to the single characteristic available from Brine devices so that the app can respond to value
    // updates after it sends write requests.
    _subscribeToCharacteristic(characteristic);
  }

  /// Subscribes to the single characteristic available from Brine devices.
  void _subscribeToCharacteristic(BleCharacteristic characteristic) {
    _characteristicValueListener = characteristic.subscribe().listen(
          _onCharacteristicChanged,
        );

    // After the characteristic subscription is established, get the Brine monitor's device ID.
    _getDeviceId(characteristic);
  }

  /// Retrieves a device ID for the Brine device.
  ///
  /// Each Brine device has a unique device ID of the form <adjective>_<adjective>_<noun>, for example,
  /// "vast_teal_elephant.' The Bluetooth API used by Brine monitors include a command allowing the app to retrieve
  /// this device ID. This is necessary because the device ID is included in the account association process.
  Future<void> _getDeviceId(BleCharacteristic characteristic) async {
    // Get the command for requesting the device ID.
    final Command deviceIdCommand = Command(commandType: CommandType.getDeviceId);
    final String commandString = deviceIdCommand.toJsonString();

    try {
      await characteristic.writeValue(value: commandString);
    } catch (e) {
      debugPrint('Failed to request device ID with exception, $e');

      // TODO(Toglefritz): Handle this error
    }
  }

  /// Handles changes in the value of a [BleCharacteristic].
  ///
  /// In this controller, the only command sent by the app is the one used to request the device ID. Therefore,
  /// the only value this callback expects to receive is the one containing the requested device ID value.
  void _onCharacteristicChanged(BleCharacteristicValue value) {
    // Obtain a Response object from the characteristic value.
    final dynamic characteristicValue = json.decode(value.valueString);

    // Verify that the response is a JSON object as expected.
    if (characteristicValue is! Map<String, dynamic>) {
      debugPrint('Received unexpected characteristic value: $characteristicValue');

      // TODO(Toglefritz): Handle this error condition
    }

    // Get a Response object from the characteristic value.
    final Response response = Response.fromJson(characteristicValue as Map<String, dynamic>);

    // Check that the characteristic value contains the device ID.
    if (response is DeviceIdResponse) {
      debugPrint('Received device ID: ${response.deviceId}');

      // Navigate to the AssociationRoute and provide the device ID.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AssociationRoute(
            deviceName: widget.device.name?.substring(6) ?? widget.device.address,
            deviceId: response.deviceId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => DeviceConnectionView(this);

  @override
  void dispose() {
    // Cancel the connection state stream.
    _connectionStream?.cancel();

    // Cancel the service discovery stream.
    _servicesDiscoveredStream?.cancel();

    // Cancel the characteristic subscription stream.
    _characteristicValueListener?.cancel();

    super.dispose();
  }
}
