#!/bin/bash

# This script is used to start and stop the Firebase Emulator Suite. The script
# exports the emulator state to the `emulator-data` directory when the emulator
# is stopped. This allows the emulator state to be preserved between emulator
# restarts. When the emulator is started, the script imports the state from the
# `emulator-data` directory.

# Start the Firebase Emulator Suite with the following command:
# `./firebase_emulator_suite.sh start`

# Stop the Firebase Emulator Suite with the following command:
# `./firebase_emulator_suite.sh stop`
# Alternatively, you can use Ctrl+X to stop the emulator and export the state.

# When running the command for the first time, ensure that the script is
# executable by running the following command:
# `chmod +x firebase_emulator_suite.sh`

EXPORT_DIR="./emulator_data"

# Function to start the Firebase Emulator Suite
start_emulator() {
    echo "Starting Firebase Emulator Suite..."
    # Run the emulator suite in the background
    firebase emulators:start --import=$EXPORT_DIR &
    EMULATOR_PID=$!
    
    echo "Emulator running. Press Ctrl+X to stop and export state."

    # Listen for Ctrl+X (represented as $'\x18')
    while true; do
        read -n 1 -s key
        if [[ $key == $'\x18' ]]; then
            echo "Ctrl+X pressed."
            stop_emulator
            kill $EMULATOR_PID
            exit 0
        fi
    done
}

# Function to stop the Firebase Emulator Suite and export state
stop_emulator() {
    echo "Stopping Firebase Emulator Suite and exporting state..."
    firebase emulators:export $EXPORT_DIR
}

# Trap SIGINT (Ctrl+C) to stop without saving state
trap ctrl_c INT

ctrl_c() {
    echo "Caught Ctrl+C. Exiting without saving state."
    kill $EMULATOR_PID
    exit 0
}

# Check the command passed to the script
if [ "$1" == "start" ]; then
    start_emulator
elif [ "$1" == "stop" ]; then
    stop_emulator
else
    echo "Usage: $0 {start|stop}"
fi