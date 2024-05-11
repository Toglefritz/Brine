import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/flutter_splendid_ble.dart';
import 'package:flutter_splendid_ble/models/ble_device.dart';
import 'package:flutter_splendid_ble/models/scan_filter.dart';

import 'scan_route.dart';
import 'scan_view.dart';

/// Controller for the [ScanRoute].
class ScanController extends State<ScanRoute> {
  /// An instance of the [FlutterSplendidBle] service used for the Bluetooth scanning process.
  final FlutterSplendidBle _ble = FlutterSplendidBle();

  /// A [StreamSubscription] allowing the controller to listen for newly discovered BLE devices.
  late StreamSubscription<BleDevice> _discoveredDeviceSubscription;

  /// A [Timer] used to implement a timeout for the scanning process.
  late Timer _scanTimeout;

  @override
  void initState() {
    _startScan();

    super.initState();
  }

  /// Starts the scan for nearby BLE devices.
  ///
  /// This method will start the scan for nearby BLE devices, filtered to show only devices with the specified service
  /// UUID. This UUID is used by all Brine devices so filtering the scan to only show devices with this service UUID
  /// will prevent the app from showing other BLE devices. The scan will run until a Brine device is found, the user
  /// cancels the scan, or a timeout occurs.
  ///
  /// Speaking of the timeout, the scan will run for a maximum of 8 seconds. If a Brine device is not found within this
  /// time period, the scan will be stopped and the user will be notified that no devices were found.
  // TODO(Toglefritz): implement ability to filter out devices
  // TODO(Toglefritz): implement a screen with instructions for starting advertisement on the Brine device
  Future<void> _startScan() async {
    // Start the scan
    _discoveredDeviceSubscription = _ble.startScan(
      filters: <ScanFilter>[
        ScanFilter(
          serviceUuids: ['6272696e-6573-616c-746d-6f6e69746f72'],
        ),
      ],
    ).listen(_onDeviceDiscovered);

    // Start a timer to create a timeout for the scan. If a Brine device is not found within the timeout period, the
    // timer will be cancelled.
    _scanTimeout = Timer(const Duration(seconds: 8), _stopScan);
  }

  /// Receives [BleDevice] instances from the [FlutterSplendidBle] service that represent BLE devices discovered during
  /// the scan. Since the scan is filtered to only show devices with the Brine service UUID, this method will only be
  /// called when Brine devices are discovered.
  void _onDeviceDiscovered(BleDevice device) {
    // Cancel the timeout timer.
    _scanTimeout.cancel();

    // Stop the scan.
    _stopScan();

    // Navigate to the next screen.
    // TODO(Toglefritz): implement
  }

  /// Stops the scan for nearby BLE devices.
  void _stopScan() {
    _ble.stopScan();
    _discoveredDeviceSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => ScanView(this);
}
