import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/scan_filter.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';
import 'package:flutter_splendid_ble/shared/models/bluetooth_permission_status.dart';
import 'package:flutter_splendid_ble/shared/models/bluetooth_status.dart';

import '../../../services/analytics/analytics.dart';
import '../../setup/setup_route.dart';
import '../device_confirmation/device_confirmation_route.dart';
import 'scan_route.dart';
import 'scan_view.dart';
import 'scan_view_none_found.dart';

/// Controller for the [ScanRoute].
class ScanController extends State<ScanRoute> {
  /// An instance of the [SplendidBle] service used for the Bluetooth scanning process.
  final SplendidBle _ble = SplendidBle();

  /// A [StreamSubscription] used to listen for changes in the state of the Bluetooth adapter.
  ///
  /// This subscription listens for updates on the current status of the Bluetooth adapter,
  /// such as whether it is turned on or off.
  StreamSubscription<BluetoothStatus>? _bluetoothStatusStream;

  /// The current status of the Bluetooth adapter, represented by the [BluetoothStatus] enum.
  BluetoothStatus? _bluetoothAdapterStatus;

  /// A [StreamSubscription] used to listen for changes in the state of the Bluetooth permissions on the host platform.
  StreamSubscription<BluetoothPermissionStatus>? _bluetoothPermissionStream;

  /// The current status of the Bluetooth permissions on the host platform, represented by the
  /// [BluetoothPermissionStatus] enum.
  BluetoothPermissionStatus? _bluetoothPermissionStatus;

  /// A [StreamSubscription] allowing the controller to listen for newly discovered BLE devices.
  StreamSubscription<BleDevice>? _discoveredDeviceSubscription;

  /// A [Timer] used to implement a timeout for the scanning process.
  late Timer _scanTimeout;

  /// Determines if the scan timeout was reached.
  bool _scanTimeoutReached = false;

  @override
  void initState() {
    // Initialize the Bluetooth permission status monitor.
    _initBluetoothPermissionStatusMonitor();

    super.initState();
  }

  /// Initializes Bluetooth permission status monitoring.
  ///
  /// This method sets up a listener to monitor the current status of the Bluetooth permissions on the host platform.
  void _initBluetoothPermissionStatusMonitor() {
    _bluetoothPermissionStream = _ble.emitCurrentPermissionStatus().listen(
      (status) {
        _bluetoothPermissionStatus = status;

        // If permissions are granted, start monitoring the Bluetooth adapter status.
        if (_bluetoothPermissionStatus == BluetoothPermissionStatus.granted) {
          _initBluetoothAdapterStatusMonitor();
        }
      },
      onError: (error) {
        // TODO(Toglefritz): go to a Bluetooth error screen
      },
    );

    // Request Bluetooth permissions. If they have already been granted, this method will do nothing.
    _ble.requestBluetoothPermissions();
  }

  /// Initializes Bluetooth status monitoring.
  ///
  /// This method sets up a listener to monitor the current status of the Bluetooth adapter. It is typically called
  /// during the initialization phase of the app or when Bluetooth monitoring is required.
  void _initBluetoothAdapterStatusMonitor() {
    try {
      _bluetoothStatusStream = _ble.emitCurrentBluetoothStatus().listen(
        (status) {
          _bluetoothAdapterStatus = status;

          // Start the scan if the Bluetooth adapter is available and if permissions have been granted.
          if (_bluetoothAdapterStatus == BluetoothStatus.enabled &&
              _bluetoothPermissionStatus == BluetoothPermissionStatus.granted) {
            _startScan();
          }
        },
        onError: (error) {
          // TODO(Toglefritz): go to a Bluetooth error screen
        },
      );
    } catch (e) {
      debugPrint('Unable to get Bluetooth status with exception, $e');

      setState(() {
        _bluetoothAdapterStatus = BluetoothStatus.notAvailable;
      });

      // TODO(Toglefritz): go to a Bluetooth error screen
    }
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
  // TODO(Toglefritz): implement ability to filter out devices (e.g. ones that are already on the account)
  // TODO(Toglefritz): implement a screen with instructions for starting advertisement on the Brine device
  Future<void> _startScan() async {
    debugPrint('Starting scan');

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
    _scanTimeout = Timer(
      const Duration(seconds: 8),
      () => _stopScan(scanTimeout: true),
    );
  }

  /// Receives [BleDevice] instances from the [SplendidBle] service that represent BLE devices discovered during
  /// the scan. Since the scan is filtered to only show devices with the Brine service UUID, this method will only be
  /// called when Brine devices are discovered.
  void _onDeviceDiscovered(BleDevice device) {
    debugPrint('Discovered Brine device, ${device.name}');

    // Check if the discovered device is among the excluded devices
    final bool isExcluded =
        widget.excludedDevices.where((excludedDevice) => excludedDevice.address == device.address).isNotEmpty;

    // Check that the discovered device is not excluded. If it is, ignore the device. If it is not excluded, double
    // check that the device has a name that contains Brine. This is not a robust security feature, just a simple tool
    // that avoids issues if another BLE device within range happened to use the same UUID as Brine devices.
    if (!isExcluded && (device.name?.isNotEmpty ?? false) && (device.name?.contains('Brine') ?? false)) {
      // Cancel the timeout timer.
      _scanTimeout.cancel();

      // Stop the scan.
      _stopScan();

      // Navigate to the next screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => DeviceConfirmationRoute(
            device: device,
            excludedDevices: widget.excludedDevices,
          ),
        ),
      );
    }
  }

  /// Handles taps on the "cancel" button used to stop the scan and return to the setup route so the account can be
  /// loaded again.
  void onCancelScan() {
    Analytics.trackEvent(eventName: 'scan_cancel_tap');

    _stopScan();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SetupRoute(),
      ),
    );
  }

  /// Handles taps on the "try again" button used to restart the scan.
  // TODO(Toglefritz): Go back to the instructions about how to start advertisement on the Brine device instead
  void onTryAgain() {
    Analytics.trackEvent(eventName: 'scan_try_again_tap');

    setState(() {
      _scanTimeoutReached = false;
    });

    _startScan();
  }

  /// Stops the scan for nearby BLE devices.
  void _stopScan({bool? scanTimeout}) {
    _ble.stopScan();
    _discoveredDeviceSubscription?.cancel();

    // If the scan was stopped due to a timeout, show a message to the user.
    if (scanTimeout ?? false) {
      debugPrint('Scan timed out');

      setState(() {
        _scanTimeoutReached = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _scanTimeoutReached ? ScanViewNoneFound(this) : ScanView(this);

  @override
  void dispose() {
    // Stop the scan.
    _stopScan();

    // Cancel the scan timeout timer.
    _scanTimeout.cancel();

    // Cancel the Bluetooth status stream.
    _bluetoothStatusStream?.cancel();

    // Cancel the Bluetooth permission stream.
    _bluetoothPermissionStream?.cancel();

    super.dispose();
  }
}
