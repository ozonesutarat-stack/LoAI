import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as FileSystem from 'expo-file-system';
import * as DocumentPicker from 'expo-document-picker';
import { STORAGE_KEYS, MESSAGE_LIMITS } from '../constants';
import { KnowledgeBase, KnowledgeFile, Tool } from '../types';

interface KnowledgeBaseContextType {
  knowledgeBases: KnowledgeBase[];
  isLoading: boolean;
  error: string | null;
  processing: boolean;
  selectedKnowledgeBase: KnowledgeBase | null;
  createKnowledgeBase: (name: string, description: string) => Promise<KnowledgeBase>;
  updateKnowledgeBase: (kbId: string, updates: Partial<KnowledgeBase>) => Promise<void>;
  deleteKnowledgeBase: (kbId: string) => Promise<void>;
  selectKnowledgeBase: (kbId: string) => void;
  addFileToKnowledgeBase: (kbId: string, file: KnowledgeFile) => Promise<void>;
  removeFileFromKnowledgeBase: (kbId: string, fileId: string) => Promise<void>;
  importFile: (kbId: string) => Promise<void>;
  processFile: (kbId: string, fileId: string) => Promise<void>;
  searchKnowledgeBase: (kbId: string, query: string) => Promise<string>;
  getKnowledgeBase: (kbId: string) => KnowledgeBase | undefined;
  getRecentKnowledgeBases: (limit?: number) => KnowledgeBase[];
}

const KnowledgeBaseContext = createContext<KnowledgeBaseContextType | undefined>(undefined);

interface KBAction {
  type: 'ADD_KB' | 'UPDATE_KB' | 'DELETE_KB' | 'SET_KBS';
  payload: KnowledgeBase | KnowledgeBase[] | string;
}

const kbReducer = (
  state: {
    knowledgeBases: KnowledgeBase[];
    isLoading: boolean;
    error: string | null;
    processing: boolean;
    selectedKnowledgeBase: KnowledgeBase | null;
  },
  action: KBAction | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null } | { type: 'SET_PROCESSING'; payload: boolean } | { type: 'SET_SELECTED'; payload: KnowledgeBase | null }
) => {
  switch (action.type) {
    case 'ADD_KB':
      return {
        ...state,
        knowledgeBases: [action.payload as KnowledgeBase, ...state.knowledgeBases],
        isLoading: false,
      };
    case 'UPDATE_KB':
      return {
        ...state,
        knowledgeBases: state.knowledgeBases.map(kb =>
          kb.id === (action.payload as KnowledgeBase).id ? { ...kb, ...(action.payload as KnowledgeBase) } : kb
        ),
      };
    case 'DELETE_KB':
      return {
        ...state,
        knowledgeBases: state.knowledgeBases.filter(kb => kb.id !== action.payload),
        selectedKnowledgeBase: state.selectedKnowledgeBase?.id === action.payload ? null : state.selectedKnowledgeBase,
      };
    case 'SET_KBS':
      return {
        ...state,
        knowledgeBases: action.payload as KnowledgeBase[],
        isLoading: false,
      };
    case 'SET_LOADING':
      return {
        ...state,
        isLoading: action.payload as boolean,
      };
    case 'SET_ERROR':
      return {
        ...state,
        error: action.payload as string | null,
        isLoading: false,
        processing: false,
      };
    case 'SET_PROCESSING':
      return {
        ...state,
        processing: action.payload as boolean,
      };
    case 'SET_SELECTED':
      return {
        ...state,
        selectedKnowledgeBase: action.payload as KnowledgeBase | null,
      };
    default:
      return state;
  }
};

export const KnowledgeBaseProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(kbReducer, {
    knowledgeBases: [],
    isLoading: false,
    error: null,
    processing: false,
    selectedKnowledgeBase: null,
  });

  // Load knowledge bases from storage
  useEffect(() => {
    const loadKnowledgeBases = async () => {
      try {
        dispatch({ type: 'SET_LOADING', payload: true });
        const savedKBs = await AsyncStorage.getItem(STORAGE_KEYS.KNOWLEDGE_BASES);

        if (savedKBs) {
          const knowledgeBases: KnowledgeBase[] = JSON.parse(savedKBs);
          dispatch({ type: 'SET_KBS', payload: knowledgeBases });
        }
      } catch (error) {
        console.error('Failed to load knowledge bases:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load knowledge bases' });
      }
    };

    loadKnowledgeBases();
  }, []);

  // Save knowledge bases to storage when they change
  useEffect(() => {
    const saveKnowledgeBases = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.KNOWLEDGE_BASES, JSON.stringify(state.knowledgeBases));
      } catch (error) {
        console.error('Failed to save knowledge bases:', error);
      }
    };

    if (state.knowledgeBases.length > 0) {
      saveKnowledgeBases();
    }
  }, [state.knowledgeBases]);

  const createKnowledgeBase = useCallback(async (name: string, description: string) => {
    const newKB: KnowledgeBase = {
      id: `kb_${Date.now()}`,
      name,
      description,
      files: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    dispatch({ type: 'ADD_KB', payload: newKB });
    return newKB;
  }, []);

  const updateKnowledgeBase = useCallback(async (kbId: string, updates: Partial<KnowledgeBase>) => {
    const kb = state.knowledgeBases.find(k => k.id === kbId);
    if (kb) {
      dispatch({
        type: 'UPDATE_KB',
        payload: { ...kb, ...updates, updatedAt: new Date() } as KnowledgeBase,
      });
    }
  }, [state.knowledgeBases]);

  const deleteKnowledgeBase = useCallback(async (kbId: string) => {
    const kb = state.knowledgeBases.find(k => k.id === kbId);
    if (kb) {
      // Delete associated files
      for (const file of kb.files) {
        try {
          if (file.path.startsWith(FileSystem.documentDirectory)) {
            await FileSystem.deleteAsync(file.path, { idempotent: true });
          }
        } catch (error) {
          console.error(`Failed to delete file ${file.path}:`, error);
        }
      }
    }

    dispatch({ type: 'DELETE_KB', payload: kbId });
  }, [state.knowledgeBases]);

  const selectKnowledgeBase = useCallback((kbId: string) => {
    const kb = state.knowledgeBases.find(k => k.id === kbId);
    if (kb) {
      dispatch({ type: 'SET_SELECTED', payload: kb });
    }
  }, [state.knowledgeBases]);

  const addFileToKnowledgeBase = useCallback(async (kbId: string, file: KnowledgeFile) => {
    const kb = state.knowledgeBases.find(k => k.id === kbId);
    if (kb) {
      const updatedKB: KnowledgeBase = {
        ...kb,
        files: [...kb.files, file],
        updatedAt: new Date(),
      };

      dispatch({ type: 'UPDATE_KB', payload: updatedKB });
    }
  }, [state.knowledgeBases]);

  const removeFileFromKnowledgeBase = useCallback(async (kbId: string, fileId: string) => {
    const kb = state.knowledgeBases.find(k => k.id === kbId);
    if (kb) {
      const file = kb.files.find(f => f.id === fileId);
      if (file && file.path.startsWith(FileSystem.documentDirectory)) {
        try {
          await FileSystem.deleteAsync(file.path, { idempotent: true });
        } catch (error) {
          console.error(`Failed to delete file ${file.path}:`, error);
        }
      }

      const updatedKB: KnowledgeBase = {
        ...kb,
        files: kb.files.filter(f => f.id !== fileId),
        updatedAt: new Date(),
      };

      dispatch({ type: 'UPDATE_KB', payload: updatedKB });
    }
  }, [state.knowledgeBases]);

  const importFile = useCallback(async (kbId: string) => {
    try {
      dispatch({ type: 'SET_PROCESSING', payload: true });
      dispatch({ type: 'SET_ERROR', payload: null });

      const result = await DocumentPicker.getDocumentAsync({
        type: ['application/pdf', 'text/plain', 'text/markdown', 'application/json'],
        multiple: false,
      });

      if (!result.canceled && result.assets && result.assets.length > 0) {
        const asset = result.assets[0];
        const kb = state.knowledgeBases.find(k => k.id === kbId);

        if (kb) {
          // Copy file to app storage
          const kbDir = `${FileSystem.documentDirectory}knowledge_bases/${kbId}/`;
          await FileSystem.makeDirectoryAsync(kbDir, { intermediates: true });

          const fileName = asset.name || `file_${Date.now()}`;
          const fileExt = fileName.split('.').pop() || 'txt';
          const newFileName = `${Date.now()}_${fileName}`;
          const filePath = `${kbDir}${newFileName}`;

          // Copy file
          await FileSystem.copyAsync({
            from: asset.uri,
            to: filePath,
          });

          const fileInfo = await FileSystem.getInfoAsync(filePath);

          const newFile: KnowledgeFile = {
            id: `kb_file_${Date.now()}`,
            path: filePath,
            name: fileName,
            size: fileInfo.size || 0,
            type: fileExt,
            processed: false,
          };

          await addFileToKnowledgeBase(kbId, newFile);

          // Auto-process the file
          await processFile(kbId, newFile.id);
        }
      }
    } catch (error) {
      console.error('Failed to import file:', error);
      dispatch({ type: 'SET_ERROR', payload: 'Failed to import file' });
    } finally {
      dispatch({ type: 'SET_PROCESSING', payload: false });
    }
  }, [state.knowledgeBases, addFileToKnowledgeBase, processFile]);

  const processFile = useCallback(async (kbId: string, fileId: string) => {
    try {
      dispatch({ type: 'SET_PROCESSING', payload: true });

      const kb = state.knowledgeBases.find(k => k.id === kbId);
      if (!kb) return;

      const file = kb.files.find(f => f.id === fileId);
      if (!file) return;

      // In a real implementation, this would:
      // 1. Read the file content
      // 2. Extract text (for PDFs, etc.)
      // 3. Generate embeddings
      // 4. Store the embeddings

      // Simulate processing
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Update file as processed
      const updatedFiles = kb.files.map(f =>
        f.id === fileId ? { ...f, processed: true, embeddings: Array(1536).fill(0) } : f
      );

      const updatedKB: KnowledgeBase = {
        ...kb,
        files: updatedFiles,
        updatedAt: new Date(),
      };

      dispatch({ type: 'UPDATE_KB', payload: updatedKB });
    } catch (error) {
      console.error('Failed to process file:', error);
      dispatch({ type: 'SET_ERROR', payload: 'Failed to process file' });
    } finally {
      dispatch({ type: 'SET_PROCESSING', payload: false });
    }
  }, [state.knowledgeBases]);

  const searchKnowledgeBase = useCallback(async (kbId: string, query: string) => {
    // In a real implementation, this would:
    // 1. Get the knowledge base
    // 2. Use embeddings to find relevant content
    // 3. Return the most relevant information

    const kb = state.knowledgeBases.find(k => k.id === kbId);
    if (!kb) return 'Knowledge base not found';

    // Simulate search
    await new Promise(resolve => setTimeout(resolve, 500));

    return `Search results for "${query}" in ${kb.name}:\n\nThis is a simulated search result. In a real implementation, this would return relevant information from the imported documents.`;
  }, [state.knowledgeBases]);

  const getKnowledgeBase = useCallback((kbId: string) => {
    return state.knowledgeBases.find(kb => kb.id === kbId);
  }, [state.knowledgeBases]);

  const getRecentKnowledgeBases = useCallback((limit: number = MESSAGE_LIMITS.INITIAL_DISPLAY) => {
    return [...state.knowledgeBases]
      .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
      .slice(0, limit);
  }, [state.knowledgeBases]);

  const value: KnowledgeBaseContextType = {
    knowledgeBases: state.knowledgeBases,
    isLoading: state.isLoading,
    error: state.error,
    processing: state.processing,
    selectedKnowledgeBase: state.selectedKnowledgeBase,
    createKnowledgeBase,
    updateKnowledgeBase,
    deleteKnowledgeBase,
    selectKnowledgeBase,
    addFileToKnowledgeBase,
    removeFileFromKnowledgeBase,
    importFile,
    processFile,
    searchKnowledgeBase,
    getKnowledgeBase,
    getRecentKnowledgeBases,
  };

  return <KnowledgeBaseContext.Provider value={value}>{children}</KnowledgeBaseContext.Provider>;
};

export const useKnowledgeBase = () => {
  const context = useContext(KnowledgeBaseContext);
  if (context === undefined) {
    throw new Error('useKnowledgeBase must be used within a KnowledgeBaseProvider');
  }
  return context;
};
