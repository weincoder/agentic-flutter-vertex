# 🌟 VoiceFlow Diary

<div align="center">

  <p>
    <a href="https://flutter.dev/" target="_blank">
      <img src="https://img.shields.io/badge/Flutter-3.10.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    </a>
    <a href="https://firebase.google.com/" target="_blank">
      <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
    </a>
    <a href="https://cloud.google.com/vertex-ai" target="_blank">
      <img src="https://img.shields.io/badge/Vertex%20AI-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Vertex AI" />
    </a>
  </p>


**An intelligent diary app powered by voice AI** 🎙️✨

Transform your thoughts into beautiful diary entries using the power of Google's Gemini AI with real-time voice conversation capabilities.

[Documentation / Documentación (Docusaurus)](documentation/README.md) • [Features](#-features) • [Demo](#-demo)

</div>

---

## 📖 Overview

**VoiceFlow Diary** is a next-generation journaling application that combines traditional diary keeping with cutting-edge AI voice technology. Built with Flutter and powered by Firebase Vertex AI (Gemini), it offers multiple ways to capture your daily moments—from traditional typing to hands-free voice conversations.

### 🎯 What Makes It Special?

- 🎤 **Real-Time Voice Conversations**: Talk naturally with Gemini Live for instant, fluid diary creation
- 🗣️ **Traditional Voice Commands**: Record, transcribe, and process voice commands step-by-step
- 🎨 **Dynamic AI-Powered Themes**: Change your app's appearance by simply asking
- 🖼️ **Automatic Image Generation**: AI creates beautiful illustrations for your entries
- 📊 **Smart Summaries**: Get AI-generated insights about your daily, weekly, or monthly reflections
- 🌐 **Cross-Platform**: Works seamlessly on iOS, Android, Web, Windows, macOS, and Linux

---

## ✨ Features

### 🎙️ Voice Interaction Modes

VoiceFlow Diary offers **three distinct voice interaction modes** for maximum flexibility:

#### 1. 🔮 Gemini Live Assistant (Real-Time Conversation)
- **Bidirectional streaming audio** with Gemini 2.0 Flash Live
- **Sub-second latency** for natural conversations
- **Continuous dialogue** without manual start/stop
- **Function calling** during conversation for actions
- Available commands:
  - 🎨 Change app theme/color
  - ❓ Ask any question
  - 📝 Get diary summaries
  - 🗑️ Delete entries (with confirmation)

#### 2. 🎤 Traditional Voice Assistant
- **Record → Transcribe → Process → Respond** workflow
- **Text-based feedback** via SnackBars
- **Explicit control** over recording sessions
- Same command capabilities as Live mode
- Ideal for **slower, deliberate** interactions

#### 3. 🎙️ Voice Note Creation
- **Quick diary entry** creation via voice
- **Automatic transcription** using Gemini
- **AI-powered content analysis** with:
  - Emotion detection
  - Key themes extraction
  - Automatic tagging
- **Optional image generation** with Imagen 3.0
- Perfect for **capturing moments on-the-go**

### 🤖 AI Capabilities

#### Content Analysis
- **Sentiment Analysis**: Detects emotions (joy, sadness, excitement, etc.)
- **Theme Extraction**: Identifies main topics and themes
- **Smart Tagging**: Automatically categorizes entries
- **Title Generation**: Creates compelling titles from content

#### Image Generation
- **Imagen 3.0 Integration**: Generates beautiful illustrations
- **Context-Aware**: Images match your entry's mood and content
- **High Quality**: Professional-looking artwork for every entry

#### Conversational AI
- **Natural Language Understanding**: Gemini understands context and nuance
- **Multi-Turn Conversations**: Maintains context across exchanges
- **Spanish Voice Support**: Native Spanish voice synthesis (Achernar)
- **Function Calling**: Execute actions during conversations

### 💾 Data Management

- **SQLite Local Storage**: All your data stays on your device
- **Fast Retrieval**: Optimized database queries
- **Rich Media Support**: Store text, images, and metadata
- **Date-Based Organization**: Entries grouped by day/week/month

### 🎨 User Interface

- **Material Design 3**: Modern, clean interface
- **Dynamic Theming**: App colors change based on your preferences
- **Smooth Animations**: Polished interactions throughout
- **Responsive Layout**: Adapts to any screen size
- **Visual Feedback**: Clear indicators for all actions

---

## 🎬 Demo

### Voice Interaction Comparison

| Feature | Gemini Live | Traditional | Voice Note |
|---------|-------------|-------------|------------|
| **Latency** | <1 second | 3-5 seconds | 2-4 seconds |
| **Interaction** | Continuous | Start/Stop | Single shot |
| **Response Type** | Voice | Text | Processed entry |
| **Best For** | Natural chat | Deliberate commands | Quick capture |
| **Network Usage** | Higher | Medium | Medium |

### Screenshots

```
┌─────────────────────────────────────────────────────────┐
│                    📱 VoiceFlow Diary                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🔮  Live Voice Assistant (Large Purple Button)        │
│      → Real-time conversation with Gemini              │
│                                                         │
│  🎤  Traditional Assistant (Deep Purple)               │
│      → Record → Process → Respond                      │
│                                                         │
│  🎙️  Voice Command (Teal)                              │
│      → Quick diary entry creation                      │
│                                                         │
│  ✏️  Manual Entry (Primary Color)                      │
│      → Traditional typing                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK**: ^3.10.1
- **Firebase Project**: With Vertex AI enabled
- **Google Cloud**: Vertex AI API access
- **Platform SDKs**:
  - iOS: Xcode 14+, CocoaPods
  - Android: Android Studio, Gradle 8+
  - Web: Modern browser
  - Desktop: Platform-specific tools

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/weincoder/agentic-flutter-vertex.git
   cd agentic-flutter-vertex/example
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

4. **Set up Vertex AI**
   - Enable Vertex AI API in Google Cloud Console
 

5. **Configure permissions**

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>VoiceFlow Diary needs microphone access to record voice notes</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>VoiceFlow Diary uses speech recognition to transcribe your voice</string>
   ```

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

6. **Run the app**
   ```bash
   # iOS
   flutter run -d ios
   
   # Android
   flutter run -d android
   
   # Web
   flutter run -d chrome
   
   # Desktop
   flutter run -d macos  # or windows, linux
   ```

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   ├── app/
│   │   └── app.dart                   # Root app widget with Provider
│   ├── data/
│   │   ├── database_helper.dart       # SQLite database setup
│   │   └── diary_repository.dart      # Data access layer
│   ├── firebase/
│   │   └── firebase_options.dart      # Firebase configuration
│   ├── ia/
│   │   ├── app_agents/
│   │   │   ├── diary_agent.dart       # Diary entry AI agent
│   │   │   ├── image_generator.dart   # Imagen 3.0 integration
│   │   │   └── voice_assistant_agent.dart  # Voice command processor
│   │   └── models/
│   │       └── ia_models.dart         # AI model configurations
│   ├── models/
│   │   └── diary_entry.dart           # Data models
│   └── state/
│       └── app_state.dart             # Global app state (Provider)
└── ui/
    ├── pages/
    │   ├── diary_home_page.dart       # Main screen
    │   └── new_entry_page.dart        # Entry editor
    └── widgets/
        ├── entry_card.dart            # Entry display card
        ├── image_viewer.dart          # Full-screen image viewer
        ├── live_voice_assistant.dart  # Gemini Live integration
        ├── voice_assistant_button.dart # Traditional voice assistant
        ├── voice_command_button.dart  # Voice note creation
        └── voice_commands_help_dialog.dart # Help dialog
```

### Tech Stack

#### Core Framework
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language

#### Firebase & AI
- **Firebase Core**: Firebase initialization
- **Firebase Vertex AI**: Gemini model access
  - `firebase_ai: ^3.6.1`
- **Gemini Models**:
  - `gemini-1.5-flash`: Text generation and analysis
  - `gemini-2.0-flash-live-preview-04-09`: Real-time audio streaming
  - `imagen-3.0-generate-002`: Image generation

#### Audio Processing
- **record**: `^6.1.2` - Audio recording
- **flutter_soloud**: `^3.4.7` - Audio playback (for Gemini Live)
- **audio_session**: `^0.2.2` - Audio session management
- **Configuration**:
  - Format: PCM 16-bit
  - Sample Rate: 24kHz
  - Channels: Mono
  - Features: Echo cancellation, noise suppression

#### State Management
- **provider**: `^6.1.5+1` - Reactive state management
- **AppState**: Global theme and app state

#### Data Persistence
- **sqflite**: `^2.4.1` - Local SQLite database
- **path_provider**: Directory access

#### UI & Utilities
- **intl**: Date formatting
- **path**: File path operations

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         User Input                          │
│            (Voice / Text / Traditional Commands)            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     Voice Processing                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Gemini Live │  │ Traditional  │  │  Voice Note  │      │
│  │  (Streaming) │  │  (Recording) │  │  (Capture)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Gemini AI Processing                      │
│  • Transcription  • Analysis  • Classification              │
│  • Content Generation  • Function Calling                   │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    ┌────────┐     ┌─────────┐    ┌──────────┐
    │ Action │     │  Store  │    │  Image   │
    │ (Theme)│     │  Entry  │    │  Gen     │
    └────────┘     └─────────┘    └──────────┘
         │               │               │
         ▼               ▼               ▼
    ┌──────────────────────────────────────┐
    │         App State / Database         │
    │   (Provider notifies UI updates)     │
    └──────────────────────────────────────┘
                     │
                     ▼
               ┌──────────┐
               │ UI Update│
               └──────────┘
```

### Key Design Patterns

1. **Singleton Pattern**: AI agents are instantiated once
2. **Repository Pattern**: Data access abstraction
3. **Provider Pattern**: Reactive state management
4. **Factory Pattern**: Model creation and initialization
5. **Stream Pattern**: Real-time audio streaming (Gemini Live)

---

## 📚 Documentation

### Additional Guides

Located in `/example`:

- **[GEMINI_LIVE_GUIDE.md](example/GEMINI_LIVE_GUIDE.md)**: Complete guide to Gemini Live integration
- **[LIVE_VS_TRADITIONAL_COMPARISON.md](example/LIVE_VS_TRADITIONAL_COMPARISON.md)**: Detailed comparison of voice modes
- **[VOICE_ASSISTANT_GUIDE.md](example/VOICE_ASSISTANT_GUIDE.md)**: Traditional voice assistant documentation

### Voice Commands Reference

#### Theme Commands
```
"Cambia el color a azul"
"Pon la app en rojo"
"Quiero el tema morado"
```

#### Query Commands
```
"¿Qué tiempo hace hoy?"
"¿Cuál es la capital de Francia?"
"Explícame qué es la fotosíntesis"
```

#### Diary Commands
```
"Resume mi semana"
"Muestra un resumen del mes"
"¿Qué escribí hoy?"
```

#### Management Commands
```
"Elimina la última entrada"
"Borra la entrada de ayer"
```

### API Reference

#### DiaryAgent
```dart
class DiaryAgent {
  // Analyze diary content
  Future<Map<String, dynamic>> analyzeContent(String content);
  
  // Generate entry title
  Future<String> generateTitle(String content);
  
  // Extract emotions
  Future<List<String>> detectEmotions(String content);
  
  // Generate tags
  Future<List<String>> generateTags(String content);
}
```

#### VoiceAssistantAgent
```dart
class VoiceAssistantAgent {
  // Process voice command
  Future<VoiceCommandResult> processCommand(String audioPath);
  
  // Command types
  enum VoiceCommandType {
    colorChange,
    question,
    summary,
    deleteEntry,
    unknown,
  }
}
```

#### LiveVoiceAssistant
```dart
class LiveVoiceAssistant {
  // Function declarations for Gemini Live
  - setAppColor(color: String)
  - getDiarySummary(timeRange: String)
  - deleteEntry(target: String)
}
```

---

## 🎨 Customization

### Theme Colors

The app supports dynamic theming via voice commands. Available colors:

| Spanish | English | Color Code |
|---------|---------|------------|
| rojo | red | `Colors.red` |
| azul | blue | `Colors.blue` |
| verde | green | `Colors.green` |
| morado | purple | `Colors.purple` |
| naranja | orange | `Colors.orange` |
| rosa | pink | `Colors.pink` |
| turquesa | teal | `Colors.teal` |
| índigo | indigo | `Colors.indigo` |
| café | brown | `Colors.brown` |
| ámbar | amber | `Colors.amber` |

### Voice Configuration

Edit voice settings in `live_voice_assistant.dart`:

```dart
LiveGenerationConfig(
  speechConfig: SpeechConfig(
    voiceName: 'Achernar', // Change voice
  ),
  responseModalities: [ResponseModalities.audio],
)
```

Available voices: Check [Google Cloud TTS documentation](https://cloud.google.com/text-to-speech/docs/voices)

### Audio Settings

Modify audio configuration in voice widgets:

```dart
RecordConfig(
  encoder: AudioEncoder.pcm16bits,
  sampleRate: 24000,  // Adjust sample rate
  numChannels: 1,     // Mono/Stereo
  echoCancel: true,   // Echo cancellation
  noiseSuppress: true, // Noise suppression
)
```

---

## 🔧 Configuration

### Environment Variables

Create a `.env` file (if needed for future enhancements):

```env
FIREBASE_PROJECT_ID=your-project-id
VERTEX_AI_LOCATION=us-central1
```

### Firebase Configuration

Edit `firebase_options.dart` after running `flutterfire configure`:

```dart
static const FirebaseOptions currentPlatform = FirebaseOptions(
  apiKey: 'your-api-key',
  projectId: 'your-project-id',
  messagingSenderId: 'your-sender-id',
  appId: 'your-app-id',
  // ... platform-specific options
);
```

---

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Analyze Code
```bash
flutter analyze
```

---

## 📊 Performance

### Benchmarks

| Metric | Gemini Live | Traditional | Voice Note |
|--------|-------------|-------------|------------|
| **Response Time** | <1s | 3-5s | 2-4s |
| **Token Usage** | 2-3x higher | Medium | Medium |
| **Network Bandwidth** | High (streaming) | Medium | Medium |
| **Battery Impact** | Higher | Medium | Low |
| **Accuracy** | Excellent | Excellent | Excellent |

### Optimization Tips

1. **Use Traditional mode** for battery-conscious scenarios
2. **Batch operations** when creating multiple entries
3. **Cache images** locally to reduce API calls
4. **Limit summary queries** to reduce token usage

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` before committing
- Add comments for complex logic
- Write tests for new features

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Google Cloud**: For Vertex AI and Gemini models
- **Firebase**: For seamless backend integration
- **Flutter Team**: For the amazing framework
- **Open Source Community**: For the excellent packages

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/weincoder/agentic-flutter-vertex/issues)
- **Discussions**: [GitHub Discussions](https://github.com/weincoder/agentic-flutter-vertex/discussions)
- **Email**: support@voiceflowdiary.app (example)

---

## 🗺️ Roadmap

### Version 2.0
- [ ] Cloud sync across devices
- [ ] Multi-language support (English, French, German)
- [ ] Advanced search with AI-powered filters
- [ ] Export to PDF/DOCX
- [ ] Dark mode enhancements

### Version 3.0
- [ ] Collaborative diaries
- [ ] Voice journal analytics dashboard
- [ ] Custom AI prompts and personas
- [ ] Integration with wearables
- [ ] Mental wellness insights

---

<div align="center">

### Made with ❤️ using Flutter & Firebase Vertex AI

**[⬆ Back to Top](#-voiceflow-diary)**

</div>
# agentic-flutter-vertex
