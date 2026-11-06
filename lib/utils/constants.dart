class AppConstants {
  static const String appName = 'LoAI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Local AI Assistant';
  
  // Storage keys
  static const String storageChatHistoryKey = 'chat_history';
  static const String storageProjectsKey = 'projects';
  static const String storageSettingsKey = 'settings';
  static const String storageModelsKey = 'models';
  static const String storagePersonaKey = 'persona';
  
  // API endpoints
  static const String huggingFaceApi = 'https://huggingface.co/api';
  static const String huggingFaceModels = 'https://huggingface.co/models';
  
  // File types
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  static const List<String> supportedDocumentTypes = ['pdf', 'txt', 'doc', 'docx', 'md'];
  static const List<String> supportedCodeTypes = ['py', 'js', 'java', 'cpp', 'c', 'go', 'rs', 'php', 'rb', 'swift', 'kt'];
  
  // Model types
  static const List<String> modelTypes = ['chat', 'image', 'tts', 'stt'];
  
  // Personas
  static const Map<String, String> presetPersonas = {
    'tutor': 'You are a helpful tutor. Explain concepts clearly and provide step-by-step guidance.',
    'math_teacher': 'You are a math teacher. Solve problems step-by-step and explain mathematical concepts clearly.',
    'roleplaying': 'You are a roleplaying assistant. Stay in character and respond appropriately to the roleplay scenario.',
    'developer': 'You are a senior developer. Provide code solutions, debug issues, and explain programming concepts.',
    'writer': 'You are a creative writer. Help with story ideas, character development, and writing improvement.',
    'translator': 'You are a professional translator. Provide accurate translations with context and examples.',
  };
  
  // Tool types
  static const List<String> toolTypes = ['web_search', 'knowledge_base', 'custom'];
  
  // Default settings
  static const double defaultTemperature = 0.7;
  static const int defaultContextLength = 2048;
  static const int defaultMaxTokens = 512;
  static const double defaultTopP = 0.9;
  static const int defaultTopK = 50;
  
  // UI defaults
  static const double defaultBlur = 0.0;
  static const double defaultTransparency = 1.0;
  static const double defaultEdgeThickness = 1.0;
  
  // Colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFF3700B3);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Gradients
  static const List<Color> userGradient = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const List<Color> botGradient = [Color(0xFF009688), Color(0xFF4DB6AC)];
  static const List<Color> systemGradient = [Color(0xFFB71C1C), Color(0xFFE53935)];
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // File size limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxDocumentSize = 50 * 1024 * 1024; // 50MB
  static const int maxModelSize = 500 * 1024 * 1024; // 500MB
}
