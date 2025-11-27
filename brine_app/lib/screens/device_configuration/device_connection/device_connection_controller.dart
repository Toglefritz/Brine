import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic.dart';
import 'package:flutter_splendid_ble/central/models/ble_connection_state.dart';
import 'package:flutter_splendid_ble/central/models/ble_service.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import '../../../extensions/json.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/device_id_response.dart';
import '../../../services/ble/models/response.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../errors/error_route.dart';
import '../../errors/models/error_type.dart';
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

  /// An instance of [BleCommunicationService] that will be created by this controller after a connection has been
  /// established with the Brine device and service discovery has been performed. This instance will be passed to
  /// subsequent steps in the provisioning process so they can use the centrally-established characteristic
  /// subscription.
  late BleCommunicationService? _bleCommunicationManager;

  /// The device ID of the Brine device.
  late String _deviceId;

  /// Timer for connection timeout.
  Timer? _connectionTimeout;

  /// Connection timeout duration in seconds.
  static const int _connectionTimeoutSeconds = 30;

  @override
  void initState() {
    Analytics.trackPageView('device_connection');

    // Start the process of connecting to the provided BleDevice. This is done after the build method is complete
    // because the controller needs to have access to the context in order to navigate to the next route.
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectToDevice());

    super.initState();
  }

  /// Attempt to connect to the [BleDevice] that is targeted for provisioning.
  Future<void> _connectToDevice() async {
    debugPrint('Connecting to device: ${widget.device.address}');

    // Start connection timeout timer
    _startConnectionTimeout();

    try {
      _connectionStream = (await _ble.connect(deviceAddress: widget.device.address)).listen(_onConnectionStateUpdate);
    } catch (e) {
      debugPrint('Failed to connect to device, ${widget.device.address}, with exception, $e');

      _onConnectionError(e);
    }
  }

  /// Starts the connection timeout timer.
  void _startConnectionTimeout() {
    _connectionTimeout = Timer(const Duration(seconds: _connectionTimeoutSeconds), () {
      debugPrint('Connection timeout reached for device: ${widget.device.address}');
      _onConnectionTimeout();
    });
  }

  /// Handles connection timeout by navigating to the error screen.
  void _onConnectionTimeout() {
    // Cancel any ongoing streams
    _connectionStream?.cancel();
    _servicesDiscoveredStream?.cancel();

    // Navigate to error screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ErrorRoute(errorType: ErrorType.bluetoothConnection),
      ),
    );
  }

  /// Handles errors resulting from an attempt to connect to a peripheral.
  void _onConnectionError(Object error) {
    // Handle errors in connecting to a peripheral.
  }

  /// Called when the connection state is updated.
  ///
  /// The app waits for a connection to the Brine device to be established before moving on to performing service and
  /// characteristic discovery.
  void _onConnectionStateUpdate(BleConnectionState state) {
    debugPrint('Connection state update for ${widget.device.name}: ${state.name}');

    if (state == BleConnectionState.connected) {
      // Cancel the connection timeout since we've successfully connected
      _connectionTimeout?.cancel();
      _discoverServices();
    }
  }

  /// Discovers services and characteristics from the Brine monitor.
  Future<void> _discoverServices() async {
    debugPrint('Discovering services');

    final Stream<List<BleService>> servicesStream = await _ble.discoverServices(widget.device.address);
    _servicesDiscoveredStream = servicesStream.listen(_onServiceDiscovered);
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

    // Create a BleCommunicationManager instance to handle communication with the Brine device.
    _createBleCommunicationManager(characteristic);
  }

  /// Subscribes to the single characteristic available from Brine devices.
  Future<void> _createBleCommunicationManager(BleCharacteristic characteristic) async {
    // Create a BleCommunicationManager instance to handle communication with the Brine device.
    _bleCommunicationManager = BleCommunicationService(characteristic: characteristic);

    // Register a callback for changes in the value of the characteristic.
    _bleCommunicationManager!.registerCallback(_onCharacteristicChanged);

    // With the subscription established, request the device ID.
    await _getDeviceId(_bleCommunicationManager!.characteristic);
  }

  /// Retrieves a device ID for the Brine device.
  ///
  /// Each Brine device has a unique device ID of the form `<adjective>_<adjective>_<noun>`, for example,
  /// "vast_teal_elephant." The Bluetooth API used by Brine monitors include a command allowing the app to retrieve this
  /// device ID. This is necessary because the device ID is included in the account association process.
  Future<void> _getDeviceId(BleCharacteristic characteristic) async {
    debugPrint('Requesting device ID');

    // Get the command for requesting the device ID.
    final Command deviceIdCommand = Command(commandType: CommandType.getDeviceId);
    final String commandString = deviceIdCommand.toJsonString();

    try {
      await _bleCommunicationManager!.writeValue(value: commandString);
    } catch (e) {
      debugPrint('Failed to request device ID with exception, $e');

      // TODO(Toglefritz): Handle this error
    }
  }

  /// Handles changes in the value of a [BleCharacteristic].
  ///
  /// This controller requests the device ID from the Brine monitor. Once the device ID is obtained, it continues to the
  /// next step.
  Future<void> _onCharacteristicChanged(JSON value) async {
    // Get a Response object from the characteristic value.
    final Response response = Response.fromJson(value);

    // Check that the characteristic value contains the device ID.
    if (response is DeviceIdResponse) {
      debugPrint('Received device ID: ${response.deviceId}');

      _deviceId = response.deviceId;

      // Continue to the next step in the provisioning process.
      await _continueToNextStep();
    } else {
      debugPrint('Unexpected response type: $response');
    }
  }

  /// Continues to the next step in the provisioning process.
  Future<void> _continueToNextStep() async {
    // Create a BrineDevice instance from the information obtained from the Brine monitor.
    final BrineDevice device = BrineDevice(
      deviceId: _deviceId,
      name: widget.device.name?.substring(6) ?? widget.device.address,
      // A value of -1 indicates that the salt distance is unknown.
      saltDistance: -1,
      // A value of -1 indicates that the appliance height is unknown.
      applianceHeight: -1,
      // A value of -1 indicates that the salt level is unknown.
      saltLevel: -1,
      // A value of -1 indicates that the battery level is unknown.
      batteryLevel: -1,
      lastUpdatedTimestamp: DateTime.now(),
      retrievalTimestamp: DateTime.now(),
    );

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            AssociationRoute(bleCommunicationManager: _bleCommunicationManager!, device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DeviceConnectionView(this);

  @override
  void dispose() {
    // Cancel the connection timeout timer.
    _connectionTimeout?.cancel();

    // Cancel the connection state stream.
    _connectionStream?.cancel();

    // Cancel the service discovery stream.
    _servicesDiscoveredStream?.cancel();

    // Unregister the callback for changes in the value of the characteristic.
    _bleCommunicationManager?.unregisterCallback(_onCharacteristicChanged);

    super.dispose();
  }
}
