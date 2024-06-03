# Provisioning Process for Brine IoT Devices

## Introduction

This document outlines the provisioning process for Brine IoT devices. The process involves interaction between the physical Brine device, a mobile app, and a Firebase backend service.

## Process Overview

1. **Device Activation**: The user initiates the process by pressing a button on the physical Brine device.
2. **BLE Advertising**: The Brine device begins advertising information over Bluetooth Low Energy (BLE).
3. **Device Discovery**: The mobile app scans for Brine devices over BLE and finds the advertising Brine device.
4. **BLE Pairing and Bonding**: The mobile app performs BLE pairing and bonding with the selected Brine device.
5. **Device Information Retrieval**: The mobile app obtains the Brine device's unique device ID.
6. **Backend Communication**: The mobile app sends the device ID, along with the authenticated user's ID, to a Firebase backend service via a REST API endpoint that associates the Brine device to the user's account.
7. **Device Association**: The Firebase backend service associates the Brine device with the user's account.
8. **WiFi Credentials Transfer**: The mobile app collects WiFi credentials from the user and sends them to the Brine device over BLE.
9. **WiFi Connection**: The Brine device attempts to connect to the WiFi network using the provided credentials and reports the success of this operation back to the mobile app over BLE.
10. **Sending Public Key to Cloud**: Once the Brine device is successfully connect to the WiFi network, it sends a public key to the backend service via a REST API endpoint that is part of a public-private key pair the device generates.
11. **Device Identify Verification**: The cloud backend verifies the authenticity of the Brine device using manufacturing records. If the verification process passes, the public key sent by the Brine device is stored in the backend service.
10. **Provisioning Completion**: Once the Brine device is successfully connected to the WiFi network, and it has successfully provided its public key to the backend system, the provisioning process is complete.

```mermaid
sequenceDiagram
    participant User
    participant MobileApp
    participant BrineDevice
    participant Backend

    User ->> BrineDevice: Press button to initiate device activation
    BrineDevice ->> MobileApp: Start BLE advertising
    MobileApp ->> MobileApp: Scan for BLE devices
    MobileApp ->> BrineDevice: Discover Brine device
    MobileApp ->> BrineDevice: Perform BLE pairing and bonding
    MobileApp ->> BrineDevice: Retrieve device ID
    MobileApp ->> Backend: Send device ID and user ID
    Backend ->> Backend: Associate device with user account
    User ->> MobileApp: Provide WiFi credentials
    MobileApp ->> BrineDevice: Send WiFi credentials over BLE
    BrineDevice ->> BrineDevice: Connect to WiFi network
    BrineDevice ->> MobileApp: Report WiFi connection success
    BrineDevice ->> Backend: Send public key to cloud
    Backend ->> Backend: Verify device identity
    Backend ->> Backend: Store device public key
    MobileApp ->> User: Notify provisioning completion
```

## Detailed Steps

### Device Activation

The device activation step is the first step in the provisioning process. It involves the user pressing a button on the physical Brine device to initiate the process. This button press serves as a proof of possession check, ensuring that the user attempting to provision the Brine device has physical access to it.

Once the button is pressed, the Brine device starts advertising information over Bluetooth Low Energy (BLE). This enables the mobile app to discover and connect to the Brine device. The device will continue to advertise and accept incoming connections for a period of three minutes after the button is pressed.

During this time, the mobile app scans for Brine devices over BLE.

### Device Discovery

The device discovery step involves the mobile app scanning for nearby Brine devices over Bluetooth Low Energy (BLE). This is done by performing a BLE scan and filtering the results based on the primary service UUID used by all Brine devices.

### Device Selection

In most cases, only a single Brine device is expected to be discovered over Bluetooth Low Energy (BLE). In this scenario, the mobile app will automatically continue to the next step without user intervention.

However, there may be situations where multiple Brine devices are detected during the scan. In such cases, the mobile app will present a list of available devices to the user. The user can then choose the specific Brine device they wish to provision from the list.

This user selection ensures that the provisioning process is performed on the intended Brine device and avoids any potential confusion or errors that may arise from provisioning the wrong device.

Once the user selects the desired Brine device, the mobile app proceeds to the next step in the provisioning process.

### BLE Pairing and Bonding

The BLE pairing and bonding step is crucial for ensuring a secure provisioning process. During this step, the mobile app establishes a secure connection with the selected Brine device by performing BLE pairing and bonding.

One important aspect of this step is the use of encrypted BLE characteristics for sharing sensitive information, such as WiFi credentials. As mentioned earlier, WiFi credentials are shared between the mobile app and the Brine device during the provisioning process. These credentials contain sensitive information that, if intercepted, could compromise the security of the WiFi network.

By using encrypted BLE characteristics, the risk of interception and compromise of WiFi credentials is minimized. Encrypted characteristics ensure that the messages exchanged between the mobile app and the Brine device are protected and cannot be easily deciphered by unauthorized parties.

To achieve this, both the mobile app and the Brine device must support the necessary encryption algorithms and key exchange protocols. The mobile app initiates the pairing process by sending a pairing request to the Brine device. The Brine device responds with a pairing response, and both devices exchange encryption keys to establish a secure connection.

Once the secure connection is established, the mobile app can safely share the WiFi credentials with the Brine device over the encrypted BLE characteristics. This ensures that even if the messages are intercepted, they cannot be easily decrypted without the encryption keys.

Using encrypted BLE characteristics for sharing WiFi credentials adds an extra layer of security to the provisioning process, protecting sensitive information from unauthorized access. It is important to ensure that both the mobile app and the Brine device are properly configured to support encryption and that the encryption keys are securely exchanged during the pairing and bonding process.

### Device Association

The device association step is where information about the Brine device and the authenticated user is linked in backend resources. This association enables the mobile app to retrieve a list of Brine devices associated with the user and display relevant information from those devices.

To perform the device association, the mobile app sends the retrieved device ID, along with the authenticated user's ID, to a Firebase backend service via a REST API endpoint.

The Firebase backend service receives the device information and user ID and associates the Brine device with the user's account. This association is typically stored in a database or other backend resource, allowing the mobile app to query and retrieve the associated devices when needed.

By associating the Brine device with the user's account, the mobile app can provide a personalized experience for the user. On future launches of the mobile app, it can retrieve the list of associated Brine devices from the backend and display relevant information from those devices, such as device status, sensor readings, or other device-specific data.

The device association step is crucial for maintaining a seamless connection between the Brine devices and the user's account, enabling efficient management and monitoring of the devices through the mobile app.

###  WiFi Credentials Transfer

After the Brine device is associated with the user’s account, the mobile app prompts the user to enter the WiFi credentials (SSID and password) of the network to which the Brine device should connect.

Once the user has entered the WiFi credentials, the mobile app proceeds to send these credentials to the Brine device over Bluetooth Low Energy (BLE).

After sending the WiFi credentials, the mobile app waits for a response from the Brine device to confirm the receipt and processing of the credentials. 

### Sending Public Key to the Cloud

Once the Brine device successfully connects to the WiFi network, it generates a public-private key pair. This key pair is used for secure communication between the device and the backend system. The Brine device uses a cryptographic coprocessor to generate a unique public-private key pair. The private key is securely stored on the device, while the public key is prepared for transmission to the backend service.

The Brine device sends its public key to the backend service via a REST API endpoint. This process involves the following sub-steps:

	1.	Prepare Data Packet: The Brine device packages its public key and any additional necessary metadata (such as device ID and a timestamp) into a data packet.
	2.	Establish Secure Connection: The Brine device establishes a secure connection with the backend service using HTTPS to ensure the confidentiality and integrity of the transmitted data.
	3.	Send Data Packet: The Brine device sends the data packet to the backend service via the designated REST API endpoint.

Upon receiving the public key from the Brine device, the backend service performs a series of checks to verify the authenticity of the device. This verification process involves the following sub-steps:

	1.	Extract Device Information: The backend service extracts the device ID and other relevant information from the received data packet.
	2.	Database Lookup: The backend service queries a database containing manufacturing records to verify the device’s authenticity. This database was created during the manufacturing process and includes information such as the device’s unique ID, serial number, and other identifying details.
	3.	Match Verification: The backend service compares the extracted device information with the records in the manufacturing database. If a match is found and the information is consistent, the device is considered authentic.
	4.	Handle Mismatch or Failure: If no match is found or the information is inconsistent, the backend service flags the device as potentially unauthorized, and further actions may be taken, such as notifying administrators or blocking the device.

If the authenticity verification process passes, the backend service stores the public key in its database. 