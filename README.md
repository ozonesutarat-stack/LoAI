# LoAI - Local AI Assistant

The local AI that runs locally on your phone. LoAI is a comprehensive mobile application that brings powerful AI capabilities to your device, including chat, vision, code generation, translation, and more.

## Features

### Chat
- **Regular Chat**: Normal conversation with AI
- **Code Box**: Responses with code include copy, download, and send to debug buttons
- **Text Bubbles**: Clear chat bubbles for easy reading
- **Vision Support**: Upload and analyze images/PDFs
- **Tool Support**:
  - Web Search: Search the web for information
  - Knowledge Base: AI answers from your imported documents
  - Custom Tools: Import and use custom tools
- **Speech to Text**: Speak and have it converted to text
- **Text to Speech**: AI and user can speak with customizable voice, speed, and tone

### Models
- **Chat Models**: Import locally or download from Hugging Face
  - Copy File: Copy model files to app storage
  - Extended: Use downloaded files directly
  - Hugging Face: Search and download models with extended file support
- **Image Models**: Same capabilities as chat models
- **TTS Models**: Text-to-speech models
- **STT Models**: Speech-to-text models
- **API Provider**: Use cloud-based AI APIs

### Features
- **Chat History**: Show last 3 chats with "show more" to expand
- **Projects**: Manage your projects with show more functionality
- **Persona**: Pre-set system prompts (Tutor, Math Teacher, Roleplaying, Custom)
- **Playground**:
  - **Co-Debug**: Code tester with AI assistance
  - **Smart Translator**: AI-powered translation with examples
  - **Document Reader**: Read and summarize any file

### Settings
- **AI Model Customization**:
  - Temperature (0.0 - 2.0)
  - Context Length
  - Max Tokens
  - Top-P
  - Top-K
  - Think Tokens
- **UI Customization**:
  - Color/Theme (Gradient/Solid)
  - Transparency
  - Blur (0.0 - 100.0)
  - Edge (thickness, color, transparency)

## Tech Stack

- **Framework**: React Native with Expo
- **Language**: TypeScript
- **State Management**: React Context API with useReducer
- **Navigation**: React Navigation (Native Stack + Bottom Tabs)
- **Storage**: AsyncStorage for persistent data
- **File System**: Expo File System for model and file management
- **AI Integration**: Hugging Face API for model downloads
- **UI Components**: Custom components with theming support

## Project Structure

```
loai/
├── App.tsx                    # Main app with navigation
├── app.json                   # Expo configuration
├── package.json               # Dependencies
├── tsconfig.json              # TypeScript configuration
├── babel.config.js            # Babel configuration
├── metro.config.js            # Metro bundler configuration
└── src/
    ├── components/            # Reusable components
    │   ├── ChatBubble.tsx     # Chat message bubbles
    │   ├── CodeBlockComponent.tsx # Code blocks with actions
    │   └── ToolSelector.tsx   # Tool selection modal
    ├── context/               # React Context providers
    │   ├── ChatContext.tsx     # Chat state management
    │   ├── ModelContext.tsx   # Model management
    │   ├── PersonaContext.tsx # Persona management
    │   ├── UISettingsContext.tsx # UI settings
    │   ├── ToolContext.tsx    # Tool management
    │   ├── ProjectContext.tsx # Project management
    │   └── KnowledgeBaseContext.tsx # Knowledge base
    ├── constants/              # App constants
    │   └── index.ts
    ├── screens/                # App screens
    │   ├── ChatScreen.tsx      # Main chat interface
    │   ├── ChatListScreen.tsx  # Chat history list
    │   ├── ModelSelectionScreen.tsx # Model management
    │   ├── SettingsScreen.tsx  # Main settings
    │   ├── AISettingsScreen.tsx # AI parameters
    │   ├── UISettingsScreen.tsx # UI customization
    │   ├── PlaygroundScreen.tsx # Playground hub
    │   ├── CoDebugScreen.tsx   # Code debugging
    │   └── ... (other screens)
    ├── types/                  # TypeScript type definitions
    │   └── index.ts
    └── utils/                  # Utility functions
```

## Getting Started

### Prerequisites

- Node.js (v18 or later)
- npm or yarn
- Expo CLI (`npm install -g expo-cli`)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ozonesutarat-stack/LoAI.git
   cd LoAI
   ```

2. **Install dependencies**:
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Install Expo CLI globally** (if not already installed):
   ```bash
   npm install -g expo-cli
   ```

### Running the App

#### Android

1. **Start the development server**:
   ```bash
   expo start
   ```

2. **Run on Android device/emulator**:
   - Open Android Studio and start an emulator
   - Or connect a physical device via USB with USB debugging enabled
   - Press `a` in the terminal to run on Android

#### iOS

1. **Start the development server**:
   ```bash
   expo start
   ```

2. **Run on iOS simulator**:
   - Open Xcode and start a simulator
   - Press `i` in the terminal to run on iOS

### Building APK

To build a production APK for Android:

1. **Install EAS CLI** (Expo Application Services):
   ```bash
   npm install -g eas-cli
   ```

2. **Log in to Expo**:
   ```bash
   eas login
   ```

3. **Configure EAS**:
   ```bash
   eas build:init
   ```
   - Select Android
   - Choose your preferred build configuration

4. **Build the APK**:
   ```bash
   eas build --platform android --profile production
   ```

5. **Download the APK**:
   - Once the build completes, you'll receive a URL to download the APK
   - Or check the builds on [Expo Application Services](https://expo.dev)

#### Alternative: Building with Gradle

If you prefer to build without EAS:

1. **Install Android Studio and Android SDK**

2. **Create android folder** (if it doesn't exist):
   ```bash
   expo prebuild
   ```

3. **Build the APK**:
   ```bash
   cd android
   ./gradlew assembleRelease
   ```

4. **Find the APK**:
   - The APK will be in `android/app/build/outputs/apk/release/`
   - File name: `app-release.apk`

### Building for iOS

To build for iOS:

1. **Install EAS CLI**:
   ```bash
   npm install -g eas-cli
   ```

2. **Build for iOS**:
   ```bash
   eas build --platform ios --profile production
   ```

3. **Download the IPA**:
   - The build will be available on Expo Application Services

## Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# Hugging Face API (optional)
HUGGINGFACE_API_KEY=your_api_key

# For production builds
EXPO_PUBLIC_API_URL=https://your-api-url.com
```

### App Configuration

Edit `app.json` to customize:
- App name
- Version
- Bundle identifier
- Android package name
- Permissions
- Icons and splash screen

## Features Implementation

### Chat Features

The chat system supports:
- Message history with pagination
- Code blocks with syntax highlighting
- Attachments (images, PDFs, documents)
- Tool calls and results
- Typing indicators

### Model Management

- Download models from Hugging Face
- Local model storage
- Model copying for persistence
- Extended file support (.mmproj, etc.)
- Model categorization (chat, image, TTS, STT)

### Vision Support

- Image upload and display
- PDF viewing and text extraction
- Document analysis

### Speech Features

- Speech to Text using device microphone
- Text to Speech with customizable:
  - Voice selection
  - Speed control
  - Pitch control
  - Tone adjustment

### Tools

- **Web Search**: Integrate with search APIs
- **Knowledge Base**: Import and query documents
- **Custom Tools**: User-defined tools and integrations

### Playground

- **Co-Debug**: Code execution with AI assistance
- **Smart Translator**: AI-powered translation
- **Document Reader**: File reading and summarization

## Customization

### UI Theming

Edit `src/constants/index.ts` to customize:
- Color palettes
- Default settings
- Predefined personas
- Predefined tools

### Adding New Features

1. **Create a new screen**: Add to `src/screens/`
2. **Add navigation**: Update `App.tsx` with new routes
3. **Create context**: Add state management in `src/context/`
4. **Add types**: Update `src/types/index.ts`

## Troubleshooting

### Common Issues

1. **Android build fails**:
   - Ensure Java JDK 11+ is installed
   - Ensure Android SDK is up to date
   - Check Android Studio settings

2. **iOS build fails**:
   - Ensure Xcode is up to date
   - Ensure CocoaPods is installed
   - Run `pod install` in the ios folder

3. **Dependencies not found**:
   - Run `npm install` or `yarn install`
   - Clear node_modules and reinstall

4. **Expo errors**:
   - Clear Expo cache: `expo start -c`
   - Reset Metro bundler: `npm start -- --reset-cache`

### Debugging

- **React Native Debugger**: Use Flipper or React DevTools
- **Console logs**: View in terminal or device logs
- **Network debugging**: Use Chrome DevTools or Flipper

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License

## Support

For issues and questions:
- Open an issue on GitHub
- Check the documentation
- Join the community discussions

---

**LoAI - Your Local AI Assistant**

Bringing AI power to your mobile device!
