// Message types
export type MessageRole = 'user' | 'assistant' | 'system' | 'tool';

export interface Message {
  id: string;
  role: MessageRole;
  content: string;
  timestamp: Date;
  metadata?: {
    model?: string;
    tokens?: number;
    temperature?: number;
    finishReason?: string;
  };
  attachments?: Attachment[];
  codeBlock?: CodeBlock;
  toolCalls?: ToolCall[];
  toolResults?: ToolResult[];
}

export interface Attachment {
  id: string;
  type: 'image' | 'pdf' | 'text' | 'audio' | 'video' | 'file';
  uri: string;
  name: string;
  size: number;
  mimeType: string;
  thumbnail?: string;
}

export interface CodeBlock {
  language: string;
  code: string;
  fileName?: string;
}

export interface ToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

export interface ToolResult {
  id: string;
  toolCallId: string;
  content: string;
  isError: boolean;
}

// Chat types
export interface ChatSession {
  id: string;
  name: string;
  messages: Message[];
  modelId: string;
  personaId?: string;
  createdAt: Date;
  updatedAt: Date;
  settings: ChatSettings;
}

export interface ChatSettings {
  temperature: number;
  maxTokens: number;
  contextLength: number;
  topP: number;
  topK: number;
  thinkTokens: number;
}

// Model types
export type ModelType = 'chat' | 'image' | 'tts' | 'stt';
export type ModelSource = 'local' | 'huggingface' | 'api';

export interface AIModel {
  id: string;
  name: string;
  type: ModelType;
  source: ModelSource;
  path: string;
  size: number;
  description: string;
  parameters: number;
  quantized: boolean;
  fileType: string;
  extendedFiles?: string[];
  downloadUrl?: string;
  isDownloaded: boolean;
  isCopied: boolean;
  createdAt: Date;
  metadata?: Record<string, unknown>;
}

// Persona types
export interface Persona {
  id: string;
  name: string;
  description: string;
  systemPrompt: string;
  category: 'tutor' | 'math_teacher' | 'roleplaying' | 'custom';
  avatar?: string;
  color?: string;
}

// Tool types
export type ToolType = 'web_search' | 'knowledge_base' | 'custom';

export interface Tool {
  id: string;
  name: string;
  type: ToolType;
  description: string;
  icon: string;
  enabled: boolean;
  configuration: Record<string, unknown>;
}

// Knowledge Base types
export interface KnowledgeBase {
  id: string;
  name: string;
  description: string;
  files: KnowledgeFile[];
  embeddingsModel?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface KnowledgeFile {
  id: string;
  path: string;
  name: string;
  size: number;
  type: string;
  processed: boolean;
  embeddings?: number[];
}

// Project types
export interface Project {
  id: string;
  name: string;
  description: string;
  type: 'chat' | 'code' | 'document' | 'translation';
  files: ProjectFile[];
  createdAt: Date;
  updatedAt: Date;
}

export interface ProjectFile {
  id: string;
  path: string;
  name: string;
  content: string;
  type: string;
}

// TTS/STT types
export interface TTSConfig {
  voice: string;
  speed: number;
  pitch: number;
  tone: string;
  modelId: string;
}

export interface STTConfig {
  modelId: string;
  language: string;
  continuous: boolean;
}

// UI Customization types
export interface UITheme {
  primaryColor: string;
  secondaryColor: string;
  backgroundColor: string;
  textColor: string;
  bubbleColor: string;
  gradientEnabled: boolean;
  gradientColors: string[];
  gradientDirection: 'toRight' | 'toBottom' | 'toBottomRight';
}

export interface UIBlur {
  enabled: boolean;
  intensity: number; // 0-100
}

export interface UIEdge {
  thickness: number;
  color: string;
  transparency: number; // 0-1
}

export interface UISettings {
  theme: UITheme;
  blur: UIBlur;
  edge: UIEdge;
  transparency: number; // 0-1
}

// Playground types
export interface PlaygroundCode {
  id: string;
  code: string;
  language: string;
  output: string;
  errors: string[];
  executionTime: number;
  timestamp: Date;
}

export interface PlaygroundTranslation {
  id: string;
  text: string;
  sourceLanguage: string;
  targetLanguage: string;
  result: string;
  examples: string[];
  timestamp: Date;
}

export interface PlaygroundDocument {
  id: string;
  file: Attachment;
  summary: string;
  keyPoints: string[];
  timestamp: Date;
}

// Navigation types
export type RootStackParamList = {
  Home: undefined;
  Chat: { sessionId?: string };
  ChatList: undefined;
  ModelSelection: { type: ModelType };
  ModelDownload: { model: AIModel };
  ModelSettings: { modelId: string };
  PersonaSelection: undefined;
  PersonaEditor: { personaId?: string };
  Settings: undefined;
  AISettings: undefined;
  UISettings: undefined;
  Tools: undefined;
  ToolConfig: { toolId: string };
  KnowledgeBase: undefined;
  KnowledgeBaseDetail: { kbId: string };
  Playground: undefined;
  CoDebug: undefined;
  SmartTranslator: undefined;
  DocumentReader: undefined;
  Projects: undefined;
  ProjectDetail: { projectId: string };
  History: undefined;
};

export type TabParamList = {
  ChatTab: undefined;
  ModelsTab: undefined;
  PlaygroundTab: undefined;
  SettingsTab: undefined;
};

// API types
export interface APIProvider {
  id: string;
  name: string;
  baseUrl: string;
  apiKey: string;
  type: 'openai' | 'anthropic' | 'huggingface' | 'custom';
  models: string[];
  enabled: boolean;
}

// Action types
export type ChatAction = 
  | { type: 'ADD_MESSAGE'; payload: Message }
  | { type: 'UPDATE_MESSAGE'; payload: { id: string; updates: Partial<Message> } }
  | { type: 'DELETE_MESSAGE'; payload: string }
  | { type: 'CLEAR_MESSAGES' }
  | { type: 'SET_SESSION'; payload: Partial<ChatSession> };

export type ModelAction = 
  | { type: 'ADD_MODEL'; payload: AIModel }
  | { type: 'UPDATE_MODEL'; payload: Partial<AIModel> }
  | { type: 'DELETE_MODEL'; payload: string }
  | { type: 'DOWNLOAD_MODEL'; payload: string }
  | { type: 'SET_MODELS'; payload: AIModel[] };

export type PersonaAction = 
  | { type: 'ADD_PERSONA'; payload: Persona }
  | { type: 'UPDATE_PERSONA'; payload: Partial<Persona> }
  | { type: 'DELETE_PERSONA'; payload: string }
  | { type: 'SET_PERSONAS'; payload: Persona[] };
