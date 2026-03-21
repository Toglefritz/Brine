#!/bin/bash

# Launches the Brine Flutter app using the Splendid CLI.
# The setup command handles device selection and app startup.

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== Brine Flutter App ===${NC}"
echo ""

splendid_cli setup
