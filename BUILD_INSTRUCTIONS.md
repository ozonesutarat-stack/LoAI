# LoAI - Build Instructions

This guide will help you build the LoAI app and generate an APK file for Android.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### Required Software

1. **Node.js** (v18 or later)
   - Download: https://nodejs.org/
   - Verify: `node --version`

2. **npm** (comes with Node.js) or **yarn**
   - Verify: `npm --version` or `yarn --version`

3. **Git**
   - Download: https://git-scm.com/
   - Verify: `git --version`

4. **Java JDK 11+** (for Android development)
   - Download: https://www.oracle.com/java/technologies/javase-jdk11-downloads.html
   - Verify: `java -version`

5. **Android Studio** (for local builds)
   - Download: https://developer.android.com/studio
   - Install Android SDK (API 34 recommended)
   - Install Android NDK (Side by side)
   - Install Android Emulator

6. **Expo CLI** (optional, but recommended)
   - Install: `npm install -g expo-cli`
   - Verify: `expo --version`

7. **EAS CLI** (Expo Application Services)
   - Install: `npm install -g eas-cli`
   - Verify: `eas --version`

### Recommended Hardware

- Minimum 8GB RAM (16GB recommended)
- SSD storage (faster builds)
- At least 10GB free disk space

---

## Method 1: Building with EAS (Recommended)

This is the easiest method and uses Expo's cloud build service.

### Step 1: Clone the Repository

```bash
git clone https://github.com/ozonesutarat-stack/LoAI.git
cd LoAI
```

### Step 2: Install Dependencies

```bash
npm install
# or
yarn install
```

### Step 3: Log in to Expo

```bash
npx eas login
```

Follow the prompts to log in with your Expo account. If you don't have one, you'll need to create it at https://expo.dev/signup

### Step 4: Initialize EAS

```bash
npx eas build:init
```

This will create an `eas.json` configuration file. Select the following options:
- Platform: Android
- Build profile: production
- Project ID: (leave as default or enter your project ID)

### Step 5: Build the APK

```bash
npx eas build --platform android --profile production
```

This will start the build process on Expo's servers. The build may take 15-30 minutes depending on the queue.

### Step 6: Download the APK

Once the build completes:
1. You'll receive an email notification
2. You can check the build status at: https://expo.dev/accounts/[your-username]/projects/loai/builds
3. Download the APK from the build page

The APK will be available in the "Artifacts" section of the build page.

### Step 7: Install the APK

Transfer the APK to your Android device and install it, or use:

```bash
adb install app-release.apk
```

---

## Method 2: Local Build with Gradle

This method builds the APK locally on your machine.

### Step 1: Clone the Repository

```bash
git clone https://github.com/ozonesutarat-stack/LoAI.git
cd LoAI
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Prebuild Android Project

```bash
npx expo prebuild
```

This creates the `android` folder with all necessary native files.

### Step 4: Configure Android Project

Edit `android/app/src/main/AndroidManifest.xml` to customize:
- Application ID
- Permissions
- App name and icon

Edit `android/app/build.gradle` to configure:
- Version code and name
- Signing configurations
- Build types

### Step 5: Set Up Signing (Optional)

For release builds, you need to set up signing. Create a `keystore` file:

```bash
keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

Then update `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            storeFile file('my-release-key.keystore')
            storePassword 'yourpassword'
            keyAlias 'my-key-alias'
            keyPassword 'yourpassword'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 6: Build the APK

#### Debug Build

```bash
cd android
./gradlew assembleDebug
```

The debug APK will be at: `android/app/build/outputs/apk/debug/app-debug.apk`

#### Release Build

```bash
cd android
./gradlew assembleRelease
```

The release APK will be at: `android/app/build/outputs/apk/release/app-release.apk`

### Step 7: Install the APK

```bash
adb install android/app/build/outputs/apk/release/app-release.apk
```

Or transfer the file to your device and install manually.

---

## Method 3: Using the Build Script

A convenience script is provided to automate the build process.

### Step 1: Make the script executable

```bash
chmod +x scripts/build-apk.sh
```

### Step 2: Run the build script

```bash
./scripts/build-apk.sh
```

This script will:
1. Check for required dependencies
2. Install missing tools
3. Install npm packages
4. Log in to Expo (if needed)
5. Initialize EAS
6. Start the build process

---

## Troubleshooting

### Common Issues

#### 1. Java Not Found

**Error**: `Java not found` or `JAVA_HOME not set`

**Solution**:
- Install Java JDK 11+
- Set JAVA_HOME environment variable:
  ```bash
  export JAVA_HOME=/path/to/jdk
  ```
- Add to your shell configuration file (~/.bashrc, ~/.zshrc, etc.)

#### 2. Android SDK Not Found

**Error**: `Android SDK not found`

**Solution**:
- Install Android Studio
- Open Android Studio and install the Android SDK
- Set ANDROID_HOME environment variable:
  ```bash
  export ANDROID_HOME=/path/to/android/sdk
  ```
- Add to your shell configuration file

#### 3. Gradle Build Failed

**Error**: Gradle build fails with various errors

**Solution**:
- Clean the project: `cd android && ./gradlew clean`
- Delete build folders: `rm -rf android/app/build`
- Retry the build
- Check for specific error messages and search for solutions

#### 4. EAS Login Failed

**Error**: `Not logged in to Expo`

**Solution**:
- Run `eas login` and follow the prompts
- Ensure you have a stable internet connection
- Check your Expo account credentials

#### 5. Missing Dependencies

**Error**: `Package not found` or `Cannot find module`

**Solution**:
- Delete `node_modules` and `package-lock.json`
- Run `npm install` or `yarn install`
- Ensure you're using the correct Node.js version (v18+)

#### 6. Out of Memory

**Error**: `Java heap space` or `Out of memory`

**Solution**:
- Increase Gradle heap size in `gradle.properties`:
  ```properties
  org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
  ```
- Close other applications to free up memory
- Use a machine with more RAM

#### 7. Keystore Issues

**Error**: `Keystore file not found` or `Invalid keystore`

**Solution**:
- Ensure the keystore file path is correct
- Verify the keystore password and alias
- Create a new keystore if needed
- For debug builds, use the default debug keystore

### Debugging Tools

1. **Android Studio Logcat**: Monitor device logs
2. **Flipper**: Debug React Native apps
3. **Chrome DevTools**: Debug JavaScript (for web-based debugging)
4. **ADB**: Android Debug Bridge for device management

---

## Customization

### Changing App Name and Icon

1. Edit `app.json`:
   ```json
   {
     "expo": {
       "name": "Your App Name",
       "slug": "your-app-slug",
       "icon": "./assets/icon.png",
       "splash": {
         "image": "./assets/splash.png"
       }
     }
   }
   ```

2. Replace the icon and splash screen images in the `assets` folder

3. Update `AndroidManifest.xml`:
   ```xml
   <application
       android:label="Your App Name"
       android:icon="@mipmap/ic_launcher">
   ```

### Changing Package Name

1. Edit `app.json`:
   ```json
   {
     "expo": {
       "android": {
         "package": "com.yourcompany.yourapp"
       },
       "ios": {
         "bundleIdentifier": "com.yourcompany.yourapp"
       }
     }
   }
   ```

2. Update `AndroidManifest.xml`:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="com.yourcompany.yourapp">
   ```

3. Update `MainApplication.java`:
   ```java
   public class MainApplication extends Application implements ReactApplication {
       // ...
   }
   ```

### Adding Permissions

Edit `AndroidManifest.xml` to add required permissions:

```xml
<manifest>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
</manifest>
```

---

## Testing

### Running on Emulator

1. Start an Android emulator:
   ```bash
   emulator -avd Your_AVD_Name
   ```

2. Run the app:
   ```bash
   npx expo start
   ```

3. Press `a` to run on Android

### Running on Physical Device

1. Enable USB debugging on your device:
   - Go to Settings > About phone > Tap Build number 7 times
   - Go to Settings > Developer options > Enable USB debugging

2. Connect your device via USB

3. Run the app:
   ```bash
   npx expo start
   ```

4. Press `a` to run on Android

### Testing the APK

1. Install the APK on your device:
   ```bash
   adb install app-release.apk
   ```

2. Open the app and test all features

---

## Deployment

### Publishing to Google Play Store

1. **Create a developer account**: https://play.google.com/console/

2. **Prepare your app**:
   - Ensure all features work correctly
   - Test on multiple devices
   - Optimize performance
   - Fix all bugs

3. **Create a signed release APK**:
   ```bash
   cd android
   ./gradlew bundleRelease
   ```
   
   This creates an Android App Bundle (AAB) at:
   `android/app/build/outputs/bundle/release/app-release.aab`

4. **Upload to Google Play Console**:
   - Go to https://play.google.com/console/
   - Create a new app
   - Upload the AAB file
   - Fill in all required information
   - Submit for review

5. **Wait for approval**: Google Play review typically takes 1-3 days

6. **Publish**: Once approved, publish your app

### Alternative: Direct APK Distribution

1. Upload the APK to a file hosting service
2. Share the download link with users
3. Users can install the APK directly

**Note**: Users may need to enable "Unknown sources" in their device settings to install APKs from outside the Play Store.

---

## Updates

### Updating the App

1. **Make changes** to your code
2. **Update version** in `app.json`:
   ```json
   {
     "expo": {
       "version": "1.0.1"
     }
   }
   ```
3. **Build new APK** using one of the methods above
4. **Distribute** the updated APK

### Over-the-Air (OTA) Updates

With Expo, you can push OTA updates without rebuilding the APK:

1. Make changes to your JavaScript code
2. Publish the update:
   ```bash
   npx expo publish
   ```
3. Users will receive the update automatically

**Note**: OTA updates only work for JavaScript changes. Native code changes require a new APK build.

---

## Performance Tips

1. **Optimize Images**: Use compressed images and appropriate sizes
2. **Lazy Loading**: Load components only when needed
3. **Memoization**: Use `React.memo` and `useMemo` to prevent unnecessary re-renders
4. **Avoid Large Dependencies**: Only include necessary libraries
5. **Code Splitting**: Split your code into smaller chunks
6. **Proguard**: Enable Proguard for release builds to remove unused code

---

## Security Best Practices

1. **Secure API Keys**: Never hardcode API keys in your app. Use environment variables or a backend service.
2. **HTTPS**: Always use HTTPS for network requests
3. **Data Encryption**: Encrypt sensitive data stored on the device
4. **Permissions**: Only request permissions that are absolutely necessary
5. **Input Validation**: Validate all user inputs to prevent injection attacks
6. **Secure Storage**: Use secure storage for sensitive information

---

## Additional Resources

- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [Expo Documentation](https://docs.expo.dev/)
- [EAS Documentation](https://docs.expo.dev/eas/)
- [Android Developer Documentation](https://developer.android.com/docs)
- [React Navigation](https://reactnavigation.org/)
- [Hugging Face Model Hub](https://huggingface.co/models)

---

## Support

If you encounter any issues during the build process:

1. **Check the logs**: Look for error messages in the console
2. **Search online**: Most errors have been encountered by others
3. **Expo Community**: Join the [Expo Discord](https://chat.expo.dev/) or [Forums](https://forums.expo.dev/)
4. **GitHub Issues**: Open an issue on the [LoAI repository](https://github.com/ozonesutarat-stack/LoAI)

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Happy Building!**

The LoAI team
