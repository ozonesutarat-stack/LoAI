#!/bin/bash

# LoAI APK Build Script
# This script automates the process of building an APK for the LoAI app

echo "=========================================="
echo "LoAI APK Build Script"
echo "=========================================="
echo ""

# Check if we're in the project directory
if [ ! -f "package.json" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed"
    echo "Please install Node.js (v18 or later) and try again"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed"
    echo "Please install npm and try again"
    exit 1
fi

# Check if Expo CLI is installed
if ! command -v expo &> /dev/null; then
    echo "Expo CLI not found. Installing..."
    npm install -g expo-cli
fi

# Check if EAS CLI is installed
if ! command -v eas &> /dev/null; then
    echo "EAS CLI not found. Installing..."
    npm install -g eas-cli
fi

# Install dependencies
echo "Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

echo ""
echo "Dependencies installed successfully!"
echo ""

# Check if user is logged in to Expo
echo "Checking Expo login status..."
eas whoami > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Not logged in to Expo. Please log in:"
    eas login
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to log in to Expo"
        exit 1
    fi
fi

echo ""
echo "Logged in to Expo successfully!"
echo ""

# Initialize EAS if not already done
if [ ! -f "eas.json" ]; then
    echo "Initializing EAS..."
    eas build:init
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to initialize EAS"
        exit 1
    fi
    
    echo ""
    echo "EAS initialized!"
    echo ""
fi

# Build the APK
echo "Building APK..."
echo "This may take several minutes depending on your internet connection and machine speed."
echo ""

# Create android folder if it doesn't exist
if [ ! -d "android" ]; then
    echo "Creating Android project structure..."
    expo prebuild
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create Android project structure"
        exit 1
    fi
    
    echo ""
    echo "Android project structure created!"
    echo ""
fi

# Build with EAS
echo "Starting EAS build..."
eas build --platform android --profile production

if [ $? -ne 0 ]; then
    echo "Error: EAS build failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "APK Build Started Successfully!"
echo "=========================================="
echo ""
echo "Your APK is being built on Expo's servers."
echo "You can monitor the build progress at:"
echo "https://expo.dev/accounts/$(eas whoami | grep 'Account:' | awk '{print $2}')/projects/loai/builds"
echo ""
echo "Once the build completes, you'll receive a notification"
echo "and can download the APK from the Expo website."
echo ""
echo "Build command completed!"
