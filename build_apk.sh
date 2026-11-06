#!/bin/bash

# LoAI APK Build Script
# This script automates the process of building the LoAI Flutter app into an APK

echo "=========================================="
echo "LoAI APK Build Script"
echo "=========================================="

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: Not in the LoAI project directory"
    echo "Please run this script from the loai/ directory"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed"
    echo "Please install Flutter and add it to your PATH"
    exit 1
fi

# Check Flutter version
flutter_version=$(flutter --version | head -n 1)
echo "Using Flutter: $flutter_version"

# Clean the project
echo "Cleaning the project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Check for build issues
echo "Running pub upgrade..."
flutter pub upgrade

# Build the APK
echo "Building APK..."
echo "This may take several minutes depending on your system."

# Build release APK
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "APK Build Successful!"
    echo "=========================================="
    
    # Find the APK file
    apk_path="build/app/outputs/flutter-apk/app-release.apk"
    
    if [ -f "$apk_path" ]; then
        echo "APK file created at: $apk_path"
        echo ""
        
        # Get file size
        file_size=$(du -h "$apk_path" | cut -f1)
        echo "APK size: $file_size"
        echo ""
        
        # Ask if user wants to install
        read -p "Do you want to install the APK on a connected device? (y/n): " install_choice
        if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
            echo "Installing APK..."
            adb install "$apk_path"
            if [ $? -eq 0 ]; then
                echo "APK installed successfully!"
            else
                echo "Failed to install APK. Make sure you have a device connected."
            fi
        fi
    else
        echo "Error: APK file not found at expected location"
        exit 1
    fi
else
    echo ""
    echo "=========================================="
    echo "APK Build Failed!"
    echo "=========================================="
    exit 1
fi

echo ""
echo "Build process completed."
