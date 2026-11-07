import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { STORAGE_KEYS, MESSAGE_LIMITS, DEFAULT_CHAT_SETTINGS } from '../constants';
import { ChatSession, Message, ChatSettings, ChatAction, ModelType } from '../types';

interface ChatContextType {
  sessions: ChatSession[];
  currentSession: ChatSession | null;
  messages: Message[];
  isLoading: boolean;
  error: string | null;
  settings: ChatSettings;
  createSession: (modelId: string, personaId?: string) => Promise<ChatSession>;
  switchSession: (sessionId: string) => Promise<void>;
  deleteSession: (sessionId: string) => Promise<void>;
  sendMessage: (content: string, attachments?: any[]) => Promise<Message | null>;
  updateMessage: (messageId: string, updates: Partial<Message>) => void;
  deleteMessage: (messageId: string) => void;
  clearMessages: () => void;
  updateSettings: (settings: Partial<ChatSettings>) => void;
  loadMoreMessages: () => Promise<void>;
  hasMoreMessages: boolean;
  visibleMessageCount: number;
}

const ChatContext = createContext<ChatContextType | undefined>(undefined);

const chatReducer = (state: {
  sessions: ChatSession[];
  currentSession: ChatSession | null;
  messages: Message[];
  isLoading: boolean;
  error: string | null;
  settings: ChatSettings;
  hasMoreMessages: boolean;
  visibleMessageCount: number;
}, action: ChatAction | { type: 'SET_SESSIONS'; payload: ChatSession[] } | { type: 'SET_CURRENT_SESSION'; payload: ChatSession | null } | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null } | { type: 'SET_SETTINGS'; payload: ChatSettings } | { type: 'LOAD_MORE_MESSAGES' } | { type: 'SET_HAS_MORE'; payload: boolean }) => {
  switch (action.type) {
    case 'ADD_MESSAGE':
      return {
        ...state,
        messages: [...state.messages, action.payload],
        isLoading: false,
        error: null,
      };
    case 'UPDATE_MESSAGE':
      return {
        ...state,
        messages: state.messages.map(msg =>
          msg.id === action.payload.id ? { ...msg, ...action.payload.updates } : msg
        ),
      };
    case 'DELETE_MESSAGE':
      return {
        ...state,
        messages: state.messages.filter(msg => msg.id !== action.payload),
      };
    case 'CLEAR_MESSAGES':
      return {
        ...state,
        messages: [],
      };
    case 'SET_SESSIONS':
      return {
        ...state,
        sessions: action.payload,
      };
    case 'SET_CURRENT_SESSION':
      return {
        ...state,
        currentSession: action.payload,
        messages: action.payload?.messages || [],
        visibleMessageCount: Math.min(action.payload?.messages.length || 0, MESSAGE_LIMITS.INITIAL_DISPLAY),
        hasMoreMessages: (action.payload?.messages.length || 0) > MESSAGE_LIMITS.INITIAL_DISPLAY,
      };
    case 'SET_LOADING':
      return {
        ...state,
        isLoading: action.payload,
      };
    case 'SET_ERROR':
      return {
        ...state,
        error: action.payload,
        isLoading: false,
      };
    case 'SET_SETTINGS':
      return {
        ...state,
        settings: action.payload,
      };
    case 'LOAD_MORE_MESSAGES':
      const newCount = Math.min(
        state.visibleMessageCount + MESSAGE_LIMITS.LOAD_MORE_BATCH,
        state.messages.length
      );
      return {
        ...state,
        visibleMessageCount: newCount,
        hasMoreMessages: newCount < state.messages.length,
      };
    case 'SET_HAS_MORE':
      return {
        ...state,
        hasMoreMessages: action.payload,
      };
    default:
      return state;
  }
};

export const ChatProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(chatReducer, {
    sessions: [],
    currentSession: null,
    messages: [],
    isLoading: false,
    error: null,
    settings: DEFAULT_CHAT_SETTINGS,
    hasMoreMessages: false,
    visibleMessageCount: 0,
  });

  // Load sessions from storage
  useEffect(() => {
    const loadSessions = async () => {
      try {
        const savedSessions = await AsyncStorage.getItem(STORAGE_KEYS.CHAT_SESSIONS);
        const savedSettings = await AsyncStorage.getItem(STORAGE_KEYS.AI_SETTINGS);
        const lastSessionId = await AsyncStorage.getItem(STORAGE_KEYS.LAST_SESSION);

        if (savedSessions) {
          const sessions: ChatSession[] = JSON.parse(savedSessions);
          dispatch({ type: 'SET_SESSIONS', payload: sessions });

          if (lastSessionId && sessions.find(s => s.id === lastSessionId)) {
            const currentSession = sessions.find(s => s.id === lastSessionId)!;
            dispatch({ type: 'SET_CURRENT_SESSION', payload: currentSession });
          } else if (sessions.length > 0) {
            dispatch({ type: 'SET_CURRENT_SESSION', payload: sessions[0] });
          }
        }

        if (savedSettings) {
          const settings: ChatSettings = JSON.parse(savedSettings);
          dispatch({ type: 'SET_SETTINGS', payload: settings });
        }
      } catch (error) {
        console.error('Failed to load sessions:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load chat sessions' });
      }
    };

    loadSessions();
  }, []);

  // Save sessions to storage when they change
  useEffect(() => {
    const saveSessions = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.CHAT_SESSIONS, JSON.stringify(state.sessions));
        if (state.currentSession) {
          await AsyncStorage.setItem(STORAGE_KEYS.LAST_SESSION, state.currentSession.id);
        }
      } catch (error) {
        console.error('Failed to save sessions:', error);
      }
    };

    if (state.sessions.length > 0) {
      saveSessions();
    }
  }, [state.sessions, state.currentSession]);

  // Save settings to storage when they change
  useEffect(() => {
    const saveSettings = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.AI_SETTINGS, JSON.stringify(state.settings));
      } catch (error) {
        console.error('Failed to save settings:', error);
      }
    };

    saveSettings();
  }, [state.settings]);

  const createSession = useCallback(async (modelId: string, personaId?: string) => {
    const newSession: ChatSession = {
      id: `session_${Date.now()}`,
      name: `Chat ${state.sessions.length + 1}`,
      messages: [],
      modelId,
      personaId,
      createdAt: new Date(),
      updatedAt: new Date(),
      settings: { ...state.settings },
    };

    const updatedSessions = [newSession, ...state.sessions].slice(0, MESSAGE_LIMITS.MAX_HISTORY);
    dispatch({ type: 'SET_SESSIONS', payload: updatedSessions });
    dispatch({ type: 'SET_CURRENT_SESSION', payload: newSession });

    return newSession;
  }, [state.sessions, state.settings]);

  const switchSession = useCallback(async (sessionId: string) => {
    const session = state.sessions.find(s => s.id === sessionId);
    if (session) {
      dispatch({ type: 'SET_CURRENT_SESSION', payload: session });
    }
  }, [state.sessions]);

  const deleteSession = useCallback(async (sessionId: string) => {
    const updatedSessions = state.sessions.filter(s => s.id !== sessionId);
    dispatch({ type: 'SET_SESSIONS', payload: updatedSessions });

    if (state.currentSession?.id === sessionId) {
      if (updatedSessions.length > 0) {
        dispatch({ type: 'SET_CURRENT_SESSION', payload: updatedSessions[0] });
      } else {
        dispatch({ type: 'SET_CURRENT_SESSION', payload: null });
        dispatch({ type: 'CLEAR_MESSAGES' });
      }
    }
  }, [state.sessions, state.currentSession]);

  const sendMessage = useCallback(async (content: string, attachments?: any[]) => {
    if (!state.currentSession) {
      dispatch({ type: 'SET_ERROR', payload: 'No active session' });
      return null;
    }

    const userMessage: Message = {
      id: `msg_${Date.now()}`,
      role: 'user',
      content,
      timestamp: new Date(),
      attachments: attachments?.map((att, idx) => ({
        id: `att_${Date.now()}_${idx}`,
        type: att.type,
        uri: att.uri,
        name: att.name,
        size: att.size,
        mimeType: att.mimeType,
      })),
    };

    dispatch({ type: 'ADD_MESSAGE', payload: userMessage });
    dispatch({ type: 'SET_LOADING', payload: true });

    try {
      // Simulate AI response (in real implementation, this would call the AI service)
      await new Promise(resolve => setTimeout(resolve, 1000));

      const assistantMessage: Message = {
        id: `msg_${Date.now() + 1}`,
        role: 'assistant',
        content: `This is a simulated response to: "${content}"`,
        timestamp: new Date(),
        metadata: {
          model: state.currentSession.modelId,
          tokens: Math.floor(Math.random() * 100) + 10,
        },
      };

      dispatch({ type: 'ADD_MESSAGE', payload: assistantMessage });
      return assistantMessage;
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to get response' });
      return null;
    } finally {
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  }, [state.currentSession]);

  const updateMessage = useCallback((messageId: string, updates: Partial<Message>) => {
    dispatch({ type: 'UPDATE_MESSAGE', payload: { id: messageId, updates } });
  }, []);

  const deleteMessage = useCallback((messageId: string) => {
    dispatch({ type: 'DELETE_MESSAGE', payload: messageId });
  }, []);

  const clearMessages = useCallback(() => {
    dispatch({ type: 'CLEAR_MESSAGES' });
  }, []);

  const updateSettings = useCallback((settings: Partial<ChatSettings>) => {
    dispatch({ type: 'SET_SETTINGS', payload: { ...state.settings, ...settings } });
  }, [state.settings]);

  const loadMoreMessages = useCallback(async () => {
    dispatch({ type: 'LOAD_MORE_MESSAGES' });
  }, []);

  const value: ChatContextType = {
    sessions: state.sessions,
    currentSession: state.currentSession,
    messages: state.messages,
    isLoading: state.isLoading,
    error: state.error,
    settings: state.settings,
    createSession,
    switchSession,
    deleteSession,
    sendMessage,
    updateMessage,
    deleteMessage,
    clearMessages,
    updateSettings,
    loadMoreMessages,
    hasMoreMessages: state.hasMoreMessages,
    visibleMessageCount: state.visibleMessageCount,
  };

  return <ChatContext.Provider value={value}>{children}</ChatContext.Provider>;
};

export const useChat = () => {
  const context = useContext(ChatContext);
  if (context === undefined) {
    throw new Error('useChat must be used within a ChatProvider');
  }
  return context;
};
