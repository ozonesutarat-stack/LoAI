# LoAI Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Flutter

If you don't have Flutter installed:

```bash
# Install Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### Step 2: Get the Project

The project is already in `/workspace/loai`

```bash
cd /workspace/loai
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Run the App

```bash
# Run on connected device
flutter run

# Or run on emulator
flutter emulators --launch <emulator_name>
flutter run
```

### Step 5: Build APK

```bash
# Quick build
./build_apk.sh

# Or manual build
flutter build apk --release
```

## 📱 First Time Using the App

### 1. Splash Screen
- App starts with animated splash screen
- Automatically navigates to home after 3 seconds

### 2. Home Screen
- Bottom navigation with 4 tabs:
  - **Chat**: Start conversations
  - **Projects**: Manage projects
  - **Playground**: Test features
  - **Settings**: Customize app

### 3. Start a Chat
1. Tap **Chat** tab
2. Tap **+** button or **New Chat** in drawer
3. Type your message
4. Send and wait for AI response (simulated)

### 4. Use Code Features
1. Type code in chat
2. AI may respond with code block
3. Code block has:
   - Copy button
   - Download button
   - Debug button (opens Co-debug)

### 5. Try Playground
1. Tap **Playground** tab
2. Try **Co-debug**: Write and test code
3. Try **Smart Translator**: Translate text
4. Try **Document Reader**: Upload and analyze files

### 6. Customize Settings
1. Tap **Settings** tab
2. Explore **General**, **AI**, and **UI** tabs
3. Change theme, colors, AI parameters
4. Save your preferences

## 🎯 Common Tasks

### Create New Chat
- Tap **+** button in app bar
- Or select **New Chat** from drawer
- Or tap **Chat** tab and start typing

### Switch Conversations
- Tap **history** icon in app bar
- Or open drawer and select from recent chats
- Or go to **Chat History** in drawer

### Use Different AI Model
1. Open chat settings (gear icon in app bar)
2. Select **Model** dropdown
3. Choose from available models
4. Save selection

### Use Persona
1. Open chat settings
2. Select **Persona** dropdown
3. Choose preset or custom persona
4. AI will use persona's system prompt

### Add Custom Persona
1. Go to **Persona Manager** from drawer
2. Tap **+** button
3. Fill in details:
   - Name
   - Description
   - System Prompt
   - Icon (emoji)
   - Color
4. Save

### Download Model
1. Go to **Model Manager** from drawer
2. Find model to download
3. Tap download button
4. Wait for download to complete
5. Load model when ready

### Use Tools
1. In chat, tap tool icons in tool bar
2. Or mention tool in message
3. AI will use tool and show results

### Customize UI
1. Go to **Settings** > **UI** tab
2. Change:
   - Theme (light/dark/system)
   - Colors
   - Gradient toggle
   - Blur, transparency
   - Edge settings
3. Changes apply immediately

## 🔧 Troubleshooting

### App won't build
```bash
flutter clean
flutter pub get
flutter run
```

### Dependencies missing
```bash
flutter pub get
flutter pub upgrade
```

### Android permissions not working
- Check `android/app/src/main/AndroidManifest.xml`
- Ensure all permissions are declared
- Request permissions at runtime in code

### Models not loading
- Check internet connection
- Verify storage permissions
- Check available storage space
- Try with smaller models first

### UI not updating
- Check for `notifyListeners()` calls
- Verify Provider usage
- Test with hot reload (`r` in terminal)

## 📚 Learn More

- **README.md** - Detailed project overview
- **IMPLEMENTATION_SUMMARY.md** - All features explained
- **DELIVERY_SUMMARY.md** - Project statistics and delivery info

## 💡 Tips

1. **Use hot reload** during development: Press `r` in terminal
2. **Use hot restart** for major changes: Press `R` in terminal
3. **Check logs** for errors: `flutter logs`
4. **Test on multiple devices** for compatibility
5. **Customize themes** to match your brand

## 🎉 You're Ready!

The LoAI app is fully functional with all UI features working. The simulated AI responses will give you a complete experience of how the app works.

To add real AI capabilities, you'll need to integrate with AI model inference libraries or APIs.

**Enjoy your Local AI Assistant!** 🎉
