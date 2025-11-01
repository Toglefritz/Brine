# `/lib` Directory Overview

The `/lib` directory is a fundamental component of the project's structure, designed to accommodate custom libraries and modules that are specific to this project's needs, including device drivers for modular I2C components, utility libraries, and any other functionality that has been modularized. This directory supports the project's architecture by encouraging modularity and reusability of code. Below is an outline of its purpose, organization, and usage guidelines.

## Purpose

- **Modularity**: The `/lib` directory encourages a modular design approach by allowing developers to encapsulate specific functionalities or device drivers into self-contained libraries. This modularity facilitates easier code management, debugging, and testing.

- **Reusability**: By organizing code into libraries, components developed for this project can be easily reused in future projects or shared with the community, promoting efficient development practices.

- **Separation of Concerns**: It helps in maintaining a clear separation of concerns within the project by isolating device-specific code, utility functions, and other modular components from the main application logic stored in the `src` and `include` directories.

## Contents

The directory typically contains subdirectories for each library or module, which in turn contain the source files (`.cpp`, `.c`) and header files (`.h`) for that library. Example libraries/modules might include:

- **I2CButton**: Contains the driver for interfacing with the Qwiic Button module, encapsulating all the functionality needed to interact with the button.

- **DistanceSensor**: Unified interface for distance sensors that supports both VL53L0X and VL53L1X sensors based on compile-time configuration. Use `-DVL53L0X_SENSOR` build flag to use VL53L0X, otherwise VL53L1X is used by default.

- **VL53L1XSensor**: Houses the code required for interfacing with the Qwiic VL53L1X distance sensor, providing an API for measuring distances.

- **VL53L0XSensor**: Contains the driver for interfacing with the VL53L0X distance sensor using the Adafruit library, providing the same API interface as VL53L1XSensor for compatibility.

- **FirebaseModule**: A library that encapsulates the functionality required for interacting with Firebase, offering a simplified interface for database operations.

- **DeepSleepManager**: Manages the deep sleep states of the IoT device, abstracting the complexity of handling sleep/wakeup cycles.

Each library should include a README.md file that explains its purpose, functionality, and how to use it, enhancing the understandability and maintainability of the code.

## Best Practices

- **Self-contained Libraries**: Each library in the `/lib` directory should be self-contained, with minimal dependencies on other libraries within the same directory. This reduces coupling and enhances the reusability of the libraries.

- **Documentation**: Adequate documentation within each library is crucial. This includes commenting the code, providing usage examples, and detailing the library's API in the README.md file.

- **Version Control**: If a library is used across multiple projects or is beneficial to the broader community, consider maintaining it in a separate version-controlled repository. This facilitates version tracking, issue tracking, and contributions from others.

- **Testing**: Develop unit tests for libraries to ensure their functionality is verified independently from the main application. This aids in maintaining high code quality and reliability.

By adhering to these guidelines, the `/lib` directory serves as a robust foundation for building, organizing, and maintaining the modular components of the IoT device project, driving efficiency and scalability in development efforts.
