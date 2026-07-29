#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Ensure the script is not run directly with root/sudo privileges
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script with sudo directly."
        print_info "Run it as a regular user; sudo will be requested when needed."
        exit 1
    fi
}
