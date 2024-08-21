import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/unit_of_measurement.dart';
import '../../../services/device_management/device_management_service.dart';
import '../brine_installation/brine_installation_route.dart';
import 'appliance_measurement_route.dart';
import 'appliance_measurement_view.dart';

/// Controller for [BrineInstallationRoute].
class ApplianceMeasurementController extends State<ApplianceMeasurementRoute> {
  /// A controller for the [TextField] used to collect the height of the water softener from the user.
  final TextEditingController measurementFieldController = TextEditingController();

  /// The unit of measurement used for the height measurement.
  UnitOfMeasurement unitOfMeasurement = UnitOfMeasurement.inches;

  @override
  void initState() {
    // TODO(Toglefritz): add analytics call

    super.initState();
  }

  /// Handles changes in the unit of measurement.
  void onUnitOfMeasurementChanged(UnitOfMeasurement? unit) {
    // TODO(Toglefritz): add analytics call

    // Update the unit of measurement.
    setState(() {
      unitOfMeasurement = unit ?? UnitOfMeasurement.inches;
    });
  }

  /// Handles submission of the height of the water softener.
  void onHeightSubmitted() {
    // TODO(Toglefritz): add analytics call

    try {
      final int rawHeight = int.parse(measurementFieldController.text);

      // Convert the height to the millimeters to match the output unit of the distance sensor.
      final int height = _convertToMillimeters(rawHeight);

      // Get the current user.
      final User user = FirebaseAuth.instance.currentUser!;

      // Update the appliance height in the database.
      DeviceManagementService(user: user).updateApplianceHeight(
        deviceId: widget.deviceId,
        height: height,
      );
    } catch(e) {
      debugPrint('Failed to parse height with exception, $e');

      // TODO(Toglefritz): Handle the failure to parse the height.
    }

    // TODO(Toglefritz): navigate to next route
  }

  /// Converts the height of the water softener to millimeters.
  int _convertToMillimeters(int height) {
    // If the unit is already millimeters, return the height as is.
    if (unitOfMeasurement == UnitOfMeasurement.mm) {
      return height;
    }
    // If the unit is inches, convert the height to millimeters.
    else if (unitOfMeasurement == UnitOfMeasurement.inches) {
      return (height * 25.4).round();
    }
    // If the unit is centimeters, convert the height to millimeters.
    else if (unitOfMeasurement == UnitOfMeasurement.cm) {
      return height * 10;
    }
    // If the unit is meters, convert the height to millimeters.
    else if (unitOfMeasurement == UnitOfMeasurement.m) {
      return height * 1000;
    }
    // If the unit is feet, convert the height to millimeters.
    else if (unitOfMeasurement == UnitOfMeasurement.feet) {
      return (height * 304.8).round();
    } else {
      // We should not reach this point.
      return height;
    }
  }

  @override
  Widget build(BuildContext context) => ApplianceMeasurementView(this);
}
