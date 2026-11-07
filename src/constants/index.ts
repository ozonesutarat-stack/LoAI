// App constants
export const APP_NAME = 'LoAI';
export const APP_VERSION = '1.0.0';
export const APP_DESCRIPTION = 'The local AI that runs locally on your phone';

// Storage keys
export const STORAGE_KEYS = {
  CHAT_SESSIONS: '@loai_chat_sessions',
  MODELS: '@loai_models',
  PERSONAS: '@loai_personas',
  TOOLS: '@loai_tools',
  KNOWLEDGE_BASES: '@loai_knowledge_bases',
  PROJECTS: '@loai_projects',
  UI_SETTINGS: '@loai_ui_settings',
  AI_SETTINGS: '@loai_ai_settings',
  API_PROVIDERS: '@loai_api_providers',
  HISTORY: '@loai_history',
  LAST_SESSION: '@loai_last_session',
};

// Default settings
export const DEFAULT_CHAT_SETTINGS: ChatSettings = {
  temperature: 0.7,
  maxTokens: 4096,
  contextLength: 8192,
  topP: 0.9,
  topK: 50,
  thinkTokens: 100,
};

export const DEFAULT_UI_SETTINGS: UISettings = {
  theme: {
    primaryColor: '#6c5ce7',
    secondaryColor: '#a29bfe',
    backgroundColor: '#1a1a2e',
    textColor: '#ffffff',
    bubbleColor: '#2d3436',
    gradientEnabled: true,
    gradientColors: ['#6c5ce7', '#a29bfe'],
    gradientDirection: 'toBottomRight',
  },
  blur: {
    enabled: true,
    intensity: 10,
  },
  edge: {
    thickness: 1,
    color: '#6c5ce7',
    transparency: 0.5,
  },
  transparency: 0.9,
};

// Model defaults
export const DEFAULT_TTS_CONFIG: TTSConfig = {
  voice: 'default',
  speed: 1.0,
  pitch: 1.0,
  tone: 'normal',
  modelId: '',
};

export const DEFAULT_STT_CONFIG: STTConfig = {
  modelId: '',
  language: 'en-US',
  continuous: false,
};

// Predefined personas
export const PREDEFINED_PERSONAS: Persona[] = [
  {
    id: 'tutor',
    name: 'Tutor',
    description: 'A helpful tutor that explains concepts clearly',
    systemPrompt: 'You are a knowledgeable tutor. Explain concepts in a clear, educational manner. Be patient and provide examples when helpful.',
    category: 'tutor',
    avatar: '🎓',
    color: '#3498db',
  },
  {
    id: 'math_teacher',
    name: 'Math Teacher',
    description: 'A math expert that helps with problems and explanations',
    systemPrompt: 'You are an expert mathematics teacher. Solve problems step-by-step and explain the reasoning behind each step. Use LaTeX for equations when appropriate.',
    category: 'math_teacher',
    avatar: '➗',
    color: '#e74c3c',
  },
  {
    id: 'roleplaying',
    name: 'Roleplaying Assistant',
    description: 'Assists with roleplaying scenarios and character interactions',
    systemPrompt: 'You are a creative roleplaying assistant. Stay in character and help develop engaging stories. Respond in a narrative style appropriate to the setting.',
    category: 'roleplaying',
    avatar: '🎭',
    color: '#9b59b6',
  },
  {
    id: 'coder',
    name: 'Coding Assistant',
    description: 'Helps with coding problems and generates code',
    systemPrompt: 'You are an expert programmer. Provide clean, well-commented code. Explain your reasoning and offer multiple approaches when appropriate. Always use code blocks for code.',
    category: 'custom',
    avatar: '💻',
    color: '#2ecc71',
  },
];

// Predefined tools
export const PREDEFINED_TOOLS: Tool[] = [
  {
    id: 'web_search',
    name: 'Web Search',
    type: 'web_search',
    description: 'Search the web for information',
    icon: '🔍',
    enabled: true,
    configuration: {
      searchEngine: 'google',
      maxResults: 5,
    },
  },
  {
    id: 'knowledge_base',
    name: 'Knowledge Base',
    type: 'knowledge_base',
    description: 'Search your imported documents and files',
    icon: '📚',
    enabled: true,
    configuration: {
      kbId: '',
    },
  },
];

// Model file extensions
export const MODEL_EXTENSIONS = {
  chat: ['.gguf', '.bin', '.safetensors', '.pkl', '.pt', '.th', '.ckpt', '.h5'],
  image: ['.gguf', '.bin', '.safetensors', '.ckpt'],
  tts: ['.gguf', '.bin', '.safetensors', '.pkl'],
  stt: ['.gguf', '.bin', '.safetensors', '.pkl'],
};

// Extended model files
export const EXTENDED_MODEL_EXTENSIONS = ['.mmproj', '.mml', '.json', '.yaml'];

// API endpoints
export const API_ENDPOINTS = {
  HUGGINGFACE_MODELS: 'https://huggingface.co/api/models',
  HUGGINGFACE_MODEL_INFO: (modelId: string) => `https://huggingface.co/api/models/${modelId}`,
  HUGGINGFACE_MODEL_FILES: (modelId: string) => `https://huggingface.co/api/models/${modelId}/tree/main`,
  HUGGINGFACE_DOWNLOAD: (modelId: string, filePath: string) => 
    `https://huggingface.co/${modelId}/resolve/main/${filePath}`,
};

// Hugging Face categories
export const HF_CATEGORIES = {
  CHAT: ['llm', 'conversational', 'text-generation', 'chatbot'],
  IMAGE: ['text-to-image', 'image-to-text', 'image-classification', 'object-detection'],
  TTS: ['text-to-speech', 'tts'],
  STT: ['automatic-speech-recognition', 'asr'],
};

// Supported languages for STT/TTS
export const SUPPORTED_LANGUAGES = [
  { code: 'en-US', name: 'English (US)' },
  { code: 'en-GB', name: 'English (UK)' },
  { code: 'es-ES', name: 'Spanish' },
  { code: 'fr-FR', name: 'French' },
  { code: 'de-DE', name: 'German' },
  { code: 'it-IT', name: 'Italian' },
  { code: 'ja-JP', name: 'Japanese' },
  { code: 'ko-KR', name: 'Korean' },
  { code: 'zh-CN', name: 'Chinese (Mandarin)' },
  { code: 'pt-BR', name: 'Portuguese (Brazil)' },
  { code: 'ru-RU', name: 'Russian' },
  { code: 'ar-SA', name: 'Arabic' },
];

// Code languages
export const CODE_LANGUAGES = [
  'javascript', 'typescript', 'python', 'java', 'c', 'cpp', 'csharp',
  'go', 'rust', 'swift', 'kotlin', 'php', 'ruby', 'bash', 'sql',
  'html', 'css', 'json', 'xml', 'yaml', 'markdown', 'text'
];

// File type icons
export const FILE_ICONS: Record<string, string> = {
  pdf: '📄',
  jpg: '🖼️',
  jpeg: '🖼️',
  png: '🖼️',
  gif: '🎬',
  txt: '📝',
  md: '📝',
  doc: '📄',
  docx: '📄',
  xls: '📊',
  xlsx: '📊',
  ppt: '📑',
  pptx: '📑',
  zip: '🗄️',
  rar: '🗄️',
  py: '🐍',
  js: '⚛️',
  ts: '⚛️',
  java: '☕',
  c: '🔧',
  cpp: '🔧',
  go: '🏃',
  rs: '🦀',
  swift: '🍎',
  kt: '🤖',
};

// Message limits
export const MESSAGE_LIMITS = {
  MAX_HISTORY: 1000,
  MAX_DISPLAY: 50,
  INITIAL_DISPLAY: 3,
  LOAD_MORE_BATCH: 10,
};

// Model size limits
export const MODEL_LIMITS = {
  MAX_DOWNLOAD_SIZE: 10 * 1024 * 1024 * 1024, // 10GB
  MAX_LOCAL_SIZE: 20 * 1024 * 1024 * 1024, // 20GB
  MIN_FREE_SPACE: 1 * 1024 * 1024 * 1024, // 1GB
};

// Animation durations
export const ANIMATION_DURATIONS = {
  FAST: 200,
  NORMAL: 300,
  SLOW: 500,
  TYPING: 20,
};

// Color palettes
export const COLOR_PALETTES = {
  DEFAULT: {
    primary: '#6c5ce7',
    secondary: '#a29bfe',
    background: '#1a1a2e',
    surface: '#2d3436',
    text: '#ffffff',
    textSecondary: '#b2bec3',
    error: '#ff4757',
    success: '#2ed573',
    warning: '#ffa502',
    info: '#3742fa',
  },
  DARK: {
    primary: '#8e44ad',
    secondary: '#9b59b6',
    background: '#121212',
    surface: '#1e1e1e',
    text: '#e0e0e0',
    textSecondary: '#a0a0a0',
    error: '#f44336',
    success: '#4caf50',
    warning: '#ff9800',
    info: '#2196f3',
  },
  LIGHT: {
    primary: '#74b9ff',
    secondary: '#0984e3',
    background: '#f5f6fa',
    surface: '#ffffff',
    text: '#2d3436',
    textSecondary: '#636e72',
    error: '#d63031',
    success: '#00b894',
    warning: '#fdcb6e',
    info: '#00cec9',
  },
};
