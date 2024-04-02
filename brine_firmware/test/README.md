# README for Hardware-in-the-Loop (HITL) Tests

This directory contains Hardware-in-the-Loop (HITL) tests for each hardware component of the Brine IoT device. These 
tests are designed to interactively verify the functionality of the hardware components by collecting feedback from a 
human tester over serial communication.

## Writing HITL Tests

Each hardware component should have a corresponding test file in this directory. The test file should be named 
`test_<component>.cpp`, where `<component>` is the name of the hardware component being tested, which in turn, is 
tyically represented by a class within the codebase that provides an interface for that hardware and allows for the 
encapsulation of these interfaces.

Each test file should include the following:

1. Include necessary libraries and headers.
2. Initialize the hardware component.
3. Write a setup function to initialize any necessary variables.
4. Write a test function to perform the actual testing. This function should control the hardware component and then 
ask the human tester to verify the result, when necessary.

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
    // Control the component
    component.control();
    // Ask the tester to verify the result
    Serial.println("Please verify the result and then type 'y' to continue.");
    while (Serial.available() == 0) {
        // Wait for the tester to type 'y'
    }
    // Read the response
    char response = Serial.read();
    if (response != 'y') {
        // If the response is not 'y', print an error message and return
        Serial.println("Error: Test failed.");
        return;
    } else {
        // If the response is 'y', print a success message
        Serial.println("Test passed.");
    }
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

During the test, the tester will be asked to verify the result of each test step. The tester should observe the 
hardware component and then type 'y' in the serial monitor to indicate that the test step passed. If the test step did 
not pass, the tester should type anything other than 'y'. The test will then print an error message and stop.