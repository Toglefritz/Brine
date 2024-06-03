import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/ble_connection_state.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import 'device_connection_route.dart';
import 'device_connection_view.dart';

/// Controller for the [DeviceConnectionRoute].
class DeviceConnectionController extends State<DeviceConnectionRoute> {
  /// An instance of the [SplendidBle] service used for the Bluetooth scanning process.
  final SplendidBle _ble = SplendidBle();

  /// A [StreamSubscription] used to listen for changes in the connection status between the app and the [BleDevice].
  StreamSubscription<BleConnectionState>? _connectionStream;

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
  void _onConnectionStateUpdate(BleConnectionState state) {
    debugPrint('Connection state update for ${widget.device.name}: ${state.name}');

    if(state == BleConnectionState.connected) {
      // TODO(Toglefritz): pair to the device
    }
  }

  @override
  Widget build(BuildContext context) => DeviceConnectionView(this);

  @override
  void dispose() {
    // Cancel the connection state4 stream.
    _connectionStream?.cancel();

    super.dispose();
  }
}
