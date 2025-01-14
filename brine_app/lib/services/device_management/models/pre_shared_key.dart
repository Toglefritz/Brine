/// Represents a pre-shared key (PSK) to be sent to the Brine device during provisioning.
///
/// A pre-shared key (PSK) is a secret key generated during the provisioning process to authenticate and secure
/// communication between the Brine device and the backend. The PSK is used by the Brine device to sign requests using
/// an HMAC, ensuring that only devices with valid keys can interact with the backend.
///
/// In the Brine system, the app handles the PSK ephemerally—meaning it does not store or retain the PSK beyond the
/// duration of the provisioning process. Once the key is securely transferred to the Brine device via Bluetooth, the
/// app discards it.
///
/// This design ensures that sensitive keys are not persistently stored on the mobile device, enhancing the overall
/// security of the system by limiting key exposure.
class PreSharedKey {
  /// The pre-shared key (PSK) value.
  final String value;

  /// Creates a [PreSharedKey] instance.
  PreSharedKey(this.value);
}
