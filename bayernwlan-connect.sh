#!/bin/bash

# =============================================
# BayernWLAN Auto Connect
# Author: Ihor Kriazhev (IgorUspehov)
# GitHub: https://github.com/IgorUspehov
# Tested on: Linux Mint 21.3
# For: Munich BayernWLAN / Vodafone Hotspot
# =============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

VODAFONE_URL="https://hotspot.vodafone.de/api/v4/login?loginProfile=6&accessType=termsOnly&action=redirect&portal=bayern"

echo -e "${CYAN}"
echo "======================================"
echo "    BayernWLAN Auto Connect"
echo "======================================"
echo -e "${NC}"

# --- 1. Connect laptop ---
echo -e "${YELLOW}[1/3] Connecting laptop to BayernWLAN...${NC}"
RESPONSE=$(curl -s --max-time 10 "$VODAFONE_URL" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "    ${GREEN}Done.${NC}"
else
    echo -e "    ${RED}Failed. Check WiFi connection.${NC}"
fi

# --- 2. Check internet ---
echo -e "${YELLOW}[2/3] Checking internet connection...${NC}"
ping -c 2 -W 3 8.8.8.8 &>/dev/null
if [ $? -eq 0 ]; then
    echo -e "    ${GREEN}Online.${NC}"
else
    echo -e "    ${RED}No internet. Try again.${NC}"
fi

# --- 3. Connect TV boxes via ADB ---
echo -e "${YELLOW}[3/3] Connecting Android TV boxes via ADB...${NC}"

BOXES=$(adb devices | grep -v "List of devices" | grep "device$" | awk '{print $1}')

if [ -z "$BOXES" ]; then
    echo -e "    ${RED}No ADB devices found.${NC}"
else
    for BOX in $BOXES; do
        echo -e "    Connecting box: ${CYAN}$BOX${NC}"
        adb -s "$BOX" shell am start -a android.intent.action.VIEW \
            -d "$VODAFONE_URL" &>/dev/null
        sleep 2
        echo -e "    ${GREEN}Done: $BOX${NC}"
    done
fi

echo ""
echo -e "${CYAN}======================================"
echo -e "  BayernWLAN connect complete!"
echo -e "======================================${NC}"
