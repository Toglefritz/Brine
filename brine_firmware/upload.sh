#!/bin/bash

# Interactive PlatformIO Upload Script
# Allows user to select the correct serial port before uploading

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display available ports
show_ports() {
    echo -e "${BLUE}Available serial ports:${NC}"
    echo ""
    pio device list
    echo ""
}

# Main script
clear
echo -e "${GREEN}=== PlatformIO Firmware Upload ===${NC}"
echo ""

# Show ports initially
show_ports

# Get port selection with refresh capability
while true; do
    echo -e "${YELLOW}Enter port path (or 'r' to refresh list, Ctrl+C to exit):${NC}"
    read -r selected_port
    
    # Check if user wants to refresh
    if [ "$selected_port" = "r" ] || [ "$selected_port" = "R" ]; then
        echo ""
        show_ports
        continue
    fi
    
    # Check if port was entered
    if [ -z "$selected_port" ]; then
        echo -e "${RED}No port entered. Please try again.${NC}"
        echo ""
        continue
    fi
    
    # Port selected, proceed with upload
    echo ""
    echo -e "${GREEN}Selected port: $selected_port${NC}"
    echo -e "${BLUE}Starting upload...${NC}"
    echo ""
    
    pio run --target upload --upload-port "$selected_port"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Upload completed successfully!${NC}"
    else
        echo ""
        echo -e "${RED}Upload failed. Please check the port and try again.${NC}"
    fi
    
    exit 0
done
