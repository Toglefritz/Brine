#!/bin/bash

# Builds and runs the Brine firmware emulator.
# This compiles the native emulator environment via PlatformIO
# and then launches the resulting binary.

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Brine Firmware Emulator ===${NC}"
echo ""
echo "Building emulator..."
echo ""

pio run -e emulator

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}Build failed.${NC}"
    exit 1
fi

echo ""
echo "Starting emulator..."
echo ""

.pio/build/emulator/program
