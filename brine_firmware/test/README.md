# README for Hardware-in-the-Loop (HITL) Tests

This directory contains Hardware-in-the-Loop (HITL) tests for each hardware component of the Brine IoT device. These 
tests are designed to interactively verify the functionality of the hardware components, sometimes by collecting 
feedback from a human tester over serial communication.

## Writing HITL Tests

Each hardware component should have a corresponding test file in this directory. The test file should be named 
`test_<component>.cpp`, where `<component>` is the name of the hardware component being tested, which in turn, is 
tyically represented by a class within the codebase that provides an interface for that hardware and allows for the 
encapsulation of these interfaces.

Each test file should include the following:

1. Include necessary libraries and headers.
2. Initialize the hardware component.
3. Write a setup function to initialize any necessary variables and resources such as an I2C bus.
4. Write a test function to perform the actual testing. This function should control the hardware component and,
optionally, ask the human tester to verify the result, when necessary.

Here is a pseudocode example of what a test file might look like:

```cpp
// Include necessary libraries and headers
#include <Arduino.h>
#include <Component.h>

// Initialize the Component object
Component component;

// Setup function
void setup() {
    // Initialize the hardware and variables
}

// Test function
void test_component() {
    // Perform an action on the component.
    TEST_ASSERT_TRUE(component.action());
}

// Register the test function
void loop() {
    test_component();
}
```

## Running HITL Tests

To run the HITL tests, you can use the PlatformIO CLI or the PlatformIO IDE.

### PlatformIO CLI

To run all tests in the `test` directory, use the following command in your terminal:

```
pio test
```

To run a specific test, use the `-e` option followed by the name of the environment and the `--filter` option followed 
by the name of the test. For example:

```
pio test -e uno --filter test_component
```

### PlatformIO IDE

To run tests in the PlatformIO IDE, click on the "PlatformIO" icon in the Activity Bar on the side of the window, then 
navigate to "Test" and click on the "Run" button.

## Interactive Testing

During the test, the tester may be asked to verify the result of each test step. The tester should observe the output
in the PlatformIO CLI and perform the requested actions as required by the test.

## Full System Test

The full system test, located in the *test_fullSystem* directory, is designed to run a comprehensive set of tests covering all hardware components and their interactions. Unlike individual component tests, which focus on testing specific hardware in isolation, the full system test ensures that all components work together correctly when integrated into the Brine IoT device.

### Running the Full System Test

To run the full system test, you can use the PlatformIO CLI:

```sh
pio test --filter test_fullSystem
```

Alternatively, if you are using the PlatformIO IDE, navigate to the “Test” section, select the test_fullSystem environment, and click “Run.”