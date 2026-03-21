#!/bin/bash

# Double-click this file in Finder to build and launch the Brine Dev TUI.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

echo "Building Brine Launcher..."
go build -o brine-launcher .

if [ $? -ne 0 ]; then
    echo "Build failed."
    read -n 1 -s -r -p "Press any key to close."
    exit 1
fi

./brine-launcher
