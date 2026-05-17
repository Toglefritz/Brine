part of 'device_connection_route.dart';

/// Controller for the [DeviceConnectionRoute].
class DeviceConnectionController extends State<DeviceConnectionRoute> {
  /// The [SplendidBleCentral] instance used for BLE operations. Uses the injected instance from the widget if
  /// provided, otherwise creates a new one.
  late final SplendidBleCentral _ble;

  /// A [StreamSubscription] used to listen for changes in the connection status between the app and the [BleDevice].
  StreamSubscription<BleConnectionState>? _connectionStream;

  /// A [StreamSubscription] used to listen for discovered services.
  StreamSubscription<List<BleService>>? _servicesDiscoveredStream;

  /// An instance of [BleCommunicationService] that will be created by this controller after a connection has been
  /// established with the Brine device and service discovery has been performed.
  BleCommunicationService? _bleCommunicationManager;

  /// The device ID of the Brine device.
  late String _deviceId;

  /// Timer for connection timeout.
  Timer? _connectionTimeout;

  /// Connection timeout duration in seconds.
  static const int _connectionTimeoutSeconds = 30;

  /// Maximum number of retries for device ID request (to handle pairing).
  static const int _maxDeviceIdRetries = 3;

  /// Current retry count for device ID request.
  int _deviceIdRetryCount = 0;

  /// Timer for device ID request timeout.
  Timer? _deviceIdTimeout;

  @override
  void initState() {
    Analytics.trackPageView('device_connection');

    // Use the injected BLE instance or create a new one.
    _ble = widget.ble ?? SplendidBleCentral();

    // Start the process of connecting to the provided BleDevice.
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
    _connectionTimeout = Timer(const Duration(seconds: _connectionTimeoutSeconds), () async {
      debugPrint('Connection timeout reached for device: ${widget.device.address}');
      await _onConnectionTimeout();
    });
  }

  /// Handles connection timeout by navigating to the error screen.
  Future<void> _onConnectionTimeout() async {
    // Cancel any ongoing streams
    await _connectionStream?.cancel();
    await _servicesDiscoveredStream?.cancel();

    // Navigate to error screen
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ErrorRoute(errorType: ErrorType.bluetoothConnection),
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
  Future<void> _onConnectionStateUpdate(BleConnectionState state) async {
    debugPrint('Connection state update for ${widget.device.name}: ${state.name}');

    if (state == BleConnectionState.connected) {
      // Cancel the connection timeout since we've successfully connected
      _connectionTimeout?.cancel();
      await _discoverServices();
    }
  }

  /// Discovers services and characteristics from the Brine monitor.
  Future<void> _discoverServices() async {
    debugPrint('Discovering services');

    final Stream<List<BleService>> servicesStream = await _ble.discoverServices(widget.device.address);
    _servicesDiscoveredStream = servicesStream.listen(_onServiceDiscovered);
  }

  /// Called when a services are successfully discovered.
  Future<void> _onServiceDiscovered(List<BleService> services) async {
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
    await _createBleCommunicationManager(characteristic);
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
  ///
  /// Note: If the device is not paired, the first write attempt will trigger the system pairing dialog and fail. This
  /// method implements a retry mechanism to handle this scenario.
  Future<void> _getDeviceId(BleCharacteristic characteristic) async {
    debugPrint('Requesting device ID (attempt ${_deviceIdRetryCount + 1}/$_maxDeviceIdRetries)');

    // Get the command for requesting the device ID.
    final Command deviceIdCommand = Command(commandType: CommandType.getDeviceId);
    final String commandString = deviceIdCommand.toJsonString();

    try {
      await _bleCommunicationManager!.writeValue(value: commandString);

      // Start a timeout to detect if we don't receive a response
      _startDeviceIdTimeout();
    } catch (e) {
      debugPrint('Failed to request device ID with exception, $e');

      // Check if this is likely a pairing-related error
      final String errorMessage = e.toString().toLowerCase();
      final bool isPairingError =
          errorMessage.contains('insufficient') ||
          errorMessage.contains('authentication') ||
          errorMessage.contains('encryption');

      if (isPairingError && _deviceIdRetryCount < _maxDeviceIdRetries) {
        _deviceIdRetryCount++;

        // Use exponential backoff: 2s, 4s, 8s
        final int delaySeconds = 2 << (_deviceIdRetryCount - 1);
        debugPrint('Pairing may be in progress. Retrying in $delaySeconds seconds...');

        await Future<void>.delayed(Duration(seconds: delaySeconds));
        await _getDeviceId(characteristic);
      } else {
        debugPrint('Failed to get device ID after $_deviceIdRetryCount retries');
        await _onDeviceIdError();
      }
    }
  }

  /// Starts a timeout for receiving the device ID response.
  void _startDeviceIdTimeout() {
    _deviceIdTimeout?.cancel();
    _deviceIdTimeout = Timer(const Duration(seconds: 5), () async {
      debugPrint('Device ID response timeout');

      if (_deviceIdRetryCount < _maxDeviceIdRetries) {
        _deviceIdRetryCount++;
        await _getDeviceId(_bleCommunicationManager!.characteristic);
      } else {
        await _onDeviceIdError();
      }
    });
  }

  /// Handles errors when unable to retrieve device ID.
  Future<void> _onDeviceIdError() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ErrorRoute(errorType: ErrorType.bluetoothConnection),
      ),
    );
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

      // Cancel the device ID timeout since we received a response
      _deviceIdTimeout?.cancel();

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
        builder: (context) => AssociationRoute(bleCommunicationManager: _bleCommunicationManager!, device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DeviceConnectionView(this);

  @override
  void dispose() {
    // Cancel the connection timeout timer.
    _connectionTimeout?.cancel();

    // Cancel the device ID timeout timer.
    _deviceIdTimeout?.cancel();

    // Cancel the connection state stream.
    unawaited(_connectionStream?.cancel());

    // Cancel the service discovery stream.
    unawaited(_servicesDiscoveredStream?.cancel());

    // Unregister the callback for changes in the value of the characteristic.
    _bleCommunicationManager?.unregisterCallback(_onCharacteristicChanged);

    super.dispose();
  }
}
