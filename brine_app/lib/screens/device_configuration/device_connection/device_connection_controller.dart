import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic.dart';
import 'package:flutter_splendid_ble/central/models/ble_connection_state.dart';
import 'package:flutter_splendid_ble/central/models/ble_service.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import '../../../extensions/json.dart';
import '../../../models/brine_device.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/device_id_response.dart';
import '../../../services/ble/models/public_key_response.dart';
import '../../../services/ble/models/response.dart';
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

  /// The public key of the Brine device, in base-64 encoded format.
  late String _publicKey;

  @override
  void initState() {
    // Start the process of connecting to the provided BleDevice. This is done after the build method is complete
    // because the controller needs to have access to the context in order to navigate to the next route.
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectToDevice());

    super.initState();
  }

  /// Attempt to connect to the [BleDevice] that is targeted for provisioning.
  void _connectToDevice() {
    debugPrint('Connecting to device: ${widget.device.address}');

    try {
      _connectionStream = _ble.connect(deviceAddress: widget.device.address).listen(
            _onConnectionStateUpdate,
          );
    } catch (e) {
      debugPrint(
        'Failed to connect to device, ${widget.device.address}, with exception, $e',
      );

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
    debugPrint(
      'Connection state update for ${widget.device.name}: ${state.name}',
    );

    if (state == BleConnectionState.connected) {
      _discoverServices();
    }
  }

  /// Discovers services and characteristics from the Brine monitor.
  void _discoverServices() {
    debugPrint('Discovering services');

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

    // Create a BleCommunicationManager instance to handle communication with the Brine device.
    _createBleCommunicationManager(characteristic);
  }

  /// Subscribes to the single characteristic available from Brine devices.
  Future<void> _createBleCommunicationManager(BleCharacteristic characteristic) async {
    // Create a BleCommunicationManager instance to handle communication with the Brine device.
    _bleCommunicationManager = BleCommunicationService(characteristic: characteristic);

    // Register a callback for changes in the value of the characteristic.
    _bleCommunicationManager!.registerCallback(_onCharacteristicChanged);

    // Also get the public key.
    await _getPublicKey(characteristic);
  }

  /// Retrieves the public key for the Brine device.
  ///
  /// Each Brine device is equipped with a cryptographic coprocessor that holds a public-private key pair. The public
  /// key is used to establish secure communication between the Brine device and the app and between the Brine device
  /// and the Brine cloud. The public key is retrieved using a command that is sent to the Brine device.
  Future<void> _getPublicKey(BleCharacteristic characteristic) async {
    debugPrint('Requesting public key');

    // Get the command for requesting the device ID.
    final Command publicKeyCommand = Command(commandType: CommandType.getPublicKey);
    final String commandString = publicKeyCommand.toJsonString();

    try {
      // The encryption key is null because the public key is not yet known, this is, after all, the command used to
      // retrieve the public key.
      await _bleCommunicationManager!.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to request public key with exception, $e');

      // TODO(Toglefritz): Handle this error
    }
  }

  /// Retrieves a device ID for the Brine device.
  ///
  /// Each Brine device has a unique device ID of the form <adjective>_<adjective>_<noun>, for example,
  /// "vast_teal_elephant." The Bluetooth API used by Brine monitors include a command allowing the app to retrieve
  /// this device ID. This is necessary because the device ID is included in the account association process.
  Future<void> _getDeviceId(BleCharacteristic characteristic) async {
    debugPrint('Requesting device ID');

    // Get the command for requesting the device ID.
    final Command deviceIdCommand = Command(commandType: CommandType.getDeviceId);
    final String commandString = deviceIdCommand.toJsonString();

    try {
      await _bleCommunicationManager!.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to request device ID with exception, $e');

      // TODO(Toglefritz): Handle this error
    }
  }

  /// Handles changes in the value of a [BleCharacteristic].
  ///
  /// This controller obtains two pieces of information from the Brine monitor: the public key and the device ID. The
  /// controller requests the public key first. Then, once the public key is received, the controller requests the
  /// device ID.
  ///
  /// Finally, once both the public key and device ID are received, the controller continues to the next step.
  Future<void> _onCharacteristicChanged(JSON value) async {
    // Get a Response object from the characteristic value.
    final Response response = Response.fromJson(value);

    // Check that the characteristic value contains the public key.
    if (response is PublicKeyResponse) {
      debugPrint('Received public key: ${response.publicKey}');

      _publicKey = response.publicKey;

      // Once the public key is received, request the device ID.
      await _getDeviceId(_bleCommunicationManager!.characteristic);
    }
    // Check that the characteristic value contains the device ID.
    else if (response is DeviceIdResponse) {
      debugPrint('Received device ID: ${response.deviceId}');

      _deviceId = response.deviceId;

      // Once both the public key and device ID are received, continue to the next step in the provisioning process.
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
      publicKey: _publicKey,
      retrievalTimestamp: DateTime.now(),
    );

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AssociationRoute(
          bleCommunicationManager: _bleCommunicationManager!,
          device: device,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DeviceConnectionView(this);

  @override
  void dispose() {
    // Cancel the connection state stream.
    _connectionStream?.cancel();

    // Cancel the service discovery stream.
    _servicesDiscoveredStream?.cancel();

    // Unregister the callback for changes in the value of the characteristic.
    _bleCommunicationManager?.unregisterCallback(_onCharacteristicChanged);

    super.dispose();
  }
}
