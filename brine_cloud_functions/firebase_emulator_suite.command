#!/bin/bash

# This script is used to start and stop the Firebase Emulator Suite. The script
# exports the emulator state to the `emulator_data` directory when the emulator
# is stopped. This allows the emulator state to be preserved between emulator
# restarts. When the emulator is started, the script imports the state from the
# `emulator-data` directory.

# This script should be placed in the root directory of the Firebase project.
# This is the directory containing the firebase.json file.

# Usage:
# To start the Firebase Emulator Suite, simply double-click the script or run
# the following command:
# `./firebase_emulator_suite.sh`
# Alternatively, you can run the script with the `start` argument:
# `./firebase_emulator_suite.sh start`
# 
# To stop the Firebase Emulator Suite and export the state, press Ctrl+X. You
# can also run the script with the `stop` argument: 
# `./firebase_emulator_suite.sh stop`
#
# To stop the Firebase Emulator Suite without exporting the state, press Ctrl+C.

# Set the working directory to the location of the script.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Set the export directory where files used to export and import emulator state
# will be stored. If this directory does not exist, it will be created.
EXPORT_DIR="./emulator_data"

# Function to start the Firebase Emulator Suite
start_emulator() {
    echo "Starting Firebase Emulator Suite..."
    # Run the emulator suite.
    firebase emulators:start --import=$EXPORT_DIR &
    EMULATOR_PID=$!
    
    echo "Emulator running. Press Ctrl+X to stop and export state."

    # Listen for Ctrl+X (represented as $'\x18').
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
    # Check if the export directory exists, create it if not.
    if [ ! -d "$EXPORT_DIR" ]; then
        echo "Directory $EXPORT_DIR does not exist. Creating it..."
        mkdir -p "$EXPORT_DIR"
    fi

    echo "Stopping Firebase Emulator Suite and exporting state..."
    firebase emulators:export $EXPORT_DIR
}

# Trap SIGINT (Ctrl+C) to stop without saving state.
trap ctrl_c INT

ctrl_c() {
    echo "Caught Ctrl+C. Exiting without saving state."
    kill $EMULATOR_PID
    exit 0
}

# Automatically start the emulator if no arguments are provided. This will
# start the emulator when the script is simply executed by double-clicking.
# Also start the emulator if the `start` argument is provided.
if [ "$1" == "start" ] || [ -z "$1" ]; then
    start_emulator
# Stop the emulator if the `stop` argument is provided.
elif [ "$1" == "stop" ]; then
    stop_emulator
# Display usage if an invalid argument is provided.
else
    echo "Usage: $0 {start|stop}"
fi