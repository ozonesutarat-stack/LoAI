# LoAI - Local AI Assistant

A comprehensive local AI assistant application with extensive features for chat, vision, tool support, and more.

## Features

### Chat
- Regular chat with AI models
- Code boxes with copy, download, and debug buttons
- Text bubbles for clear message display
- Support for various message types (text, code, image, file, tool results)

### Vision
- Image upload and processing
- PDF and document support
- Multimodal AI capabilities

### Tool Support
- Web search integration
- Knowledge base for imported documents
- Custom tools support
- Tool calling functionality

### Speech
- Speech-to-Text (STT) for voice input
- Text-to-Speech (TTS) with customizable voice, speed, and tone

### Model Management
- Local model support (copy files into app)
- Extended model support
- Hugging Face integration (search and download models)
- API provider support for cloud-based AI

### Features
- Chat history with last 3 conversations visible
- Project management
- Persona system with preset prompts
- Playground section with:
  - Co-debug for code testing and debugging
  - Smart Translator for accurate translations
  - Document Reader for file analysis

### Settings
- AI model customization (temperature, context length, max tokens, etc.)
- UI customization (colors, themes, gradients, transparency, blur, edges)

## Project Structure

```
loai/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                  # Data models
│   │   ├── chat_message.dart
│   │   ├── conversation.dart
│   │   ├── project.dart
│   │   ├── ai_model.dart
│   │   ├── persona.dart
│   │   └── tool.dart
│   ├── providers/               # State management
│   │   ├── theme_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── model_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/                 # UI screens
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── projects_screen.dart
│   │   ├── playground_screen.dart
│   │   ├── co_debug_screen.dart
│   │   ├── translator_screen.dart
│   │   ├── document_reader_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── model_manager_screen.dart
│   │   ├── persona_manager_screen.dart
│   │   └── tool_manager_screen.dart
│   └── widgets/                 # Custom widgets
│       ├── chat_bubble.dart
│       ├── code_block.dart
│       ├── input_bar.dart
│       ├── tool_bar.dart
│       ├── conversation_list.dart
│       ├── model_selector.dart
│       └── drawer_widget.dart
├── android/                     # Android specific files
├── ios/                         # iOS specific files
└── pubspec.yaml                 # Dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Android Studio (for APK building)
- Java JDK 11 or higher
- Android SDK with necessary packages

### Installation

1. Clone the repository:
```bash
cd /workspace
```

2. Install dependencies:
```bash
cd loai
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building APK

To build a release APK:

```bash
# Clean the project
flutter clean

# Build APK
flutter build apk --release

# The APK will be generated at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Building App Bundle

For Google Play Store:

```bash
flutter build appbundle --release
```

## Configuration

### Permissions

The app requires the following permissions:
- Internet access (for model downloads and API calls)
- Storage access (for file uploads and downloads)
- Camera access (for image capture)
- Microphone access (for voice input)

### API Keys

For certain features, you may need to configure API keys:
- Hugging Face API key (optional, for private models)
- Cloud AI provider API keys (optional)

## Usage

### Chat
1. Select a model from the model manager
2. Start a new conversation
3. Type your message and send
4. AI will respond with text or code

### Code Debugging
1. Go to Playground > Co-debug
2. Enter your code
3. Run or ask AI for help
4. View output and AI suggestions

### Translation
1. Go to Playground > Smart Translator
2. Select source and target languages
3. Enter text to translate
4. View translation and examples

### Document Reading
1. Go to Playground > Document Reader
2. Upload a document
3. View extracted content and summary

## Customization

### UI Settings
- Change theme (light/dark/system)
- Customize colors
- Adjust blur and transparency
- Configure chat bubble style

### AI Settings
- Adjust temperature (0.0 - 2.0)
- Set context length
- Configure max tokens
- Adjust sampling parameters

## Dependencies

The app uses the following Flutter packages:
- `provider` for state management
- `flutter_svg` for SVG support
- `google_fonts` for typography
- `image_picker` for image selection
- `file_picker` for file selection
- `speech_to_text` for voice input
- `flutter_tts` for text-to-speech
- `http` and `dio` for network requests
- `hive` for local storage
- `path_provider` for file paths
- `pdf_text` for PDF processing
- `highlight` for code syntax highlighting
- `flutter_code_editor` for code editing

## Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions, please open an issue on GitHub.

---

**LoAI - Your Local AI Assistant**

Version: 1.0.0

Made with Flutter and ❤️
