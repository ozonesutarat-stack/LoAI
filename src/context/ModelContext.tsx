import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as FileSystem from 'expo-file-system';
import { STORAGE_KEYS, MODEL_EXTENSIONS, EXTENDED_MODEL_EXTENSIONS, API_ENDPOINTS, HF_CATEGORIES } from '../constants';
import { AIModel, ModelType, ModelSource, ModelAction } from '../types';

interface ModelContextType {
  models: AIModel[];
  isLoading: boolean;
  error: string | null;
  downloadProgress: Record<string, { progress: number; status: 'pending' | 'downloading' | 'completed' | 'failed' }>;
  fetchHuggingFaceModels: (type: ModelType, searchQuery?: string) => Promise<AIModel[]>;
  downloadModel: (model: AIModel, includeExtended?: boolean) => Promise<void>;
  deleteModel: (modelId: string) => Promise<void>;
  copyModel: (modelId: string) => Promise<void>;
  getModel: (modelId: string) => AIModel | undefined;
  getModelsByType: (type: ModelType) => AIModel[];
  searchModels: (query: string, type?: ModelType) => AIModel[];
  checkStorageSpace: (requiredSpace: number) => Promise<boolean>;
  getModelPath: (modelId: string) => string;
}

const ModelContext = createContext<ModelContextType | undefined>(undefined);

const modelReducer = (
  state: {
    models: AIModel[];
    isLoading: boolean;
    error: string | null;
    downloadProgress: Record<string, { progress: number; status: string }>;
  },
  action: ModelAction | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null } | { type: 'UPDATE_DOWNLOAD_PROGRESS'; payload: { modelId: string; progress: number; status: string } }
) => {
  switch (action.type) {
    case 'ADD_MODEL':
      return {
        ...state,
        models: [...state.models, action.payload],
        isLoading: false,
      };
    case 'UPDATE_MODEL':
      return {
        ...state,
        models: state.models.map(model =>
          model.id === action.payload.id ? { ...model, ...action.payload } : model
        ),
      };
    case 'DELETE_MODEL':
      return {
        ...state,
        models: state.models.filter(model => model.id !== action.payload),
      };
    case 'SET_MODELS':
      return {
        ...state,
        models: action.payload,
        isLoading: false,
      };
    case 'DOWNLOAD_MODEL':
      return {
        ...state,
        models: state.models.map(model =>
          model.id === action.payload
            ? { ...model, isDownloaded: true, isCopied: true }
            : model
        ),
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
    case 'UPDATE_DOWNLOAD_PROGRESS':
      return {
        ...state,
        downloadProgress: {
          ...state.downloadProgress,
          [action.payload.modelId]: {
            progress: action.payload.progress,
            status: action.payload.status,
          },
        },
      };
    default:
      return state;
  }
};

export const ModelProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(modelReducer, {
    models: [],
    isLoading: false,
    error: null,
    downloadProgress: {},
  });

  // Load models from storage
  useEffect(() => {
    const loadModels = async () => {
      try {
        dispatch({ type: 'SET_LOADING', payload: true });
        const savedModels = await AsyncStorage.getItem(STORAGE_KEYS.MODELS);
        if (savedModels) {
          const models: AIModel[] = JSON.parse(savedModels);
          dispatch({ type: 'SET_MODELS', payload: models });
        }
      } catch (error) {
        console.error('Failed to load models:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load models' });
      }
    };

    loadModels();
  }, []);

  // Save models to storage when they change
  useEffect(() => {
    const saveModels = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.MODELS, JSON.stringify(state.models));
      } catch (error) {
        console.error('Failed to save models:', error);
      }
    };

    if (state.models.length > 0) {
      saveModels();
    }
  }, [state.models]);

  const fetchHuggingFaceModels = useCallback(async (type: ModelType, searchQuery?: string) => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'SET_ERROR', payload: null });

      // In a real implementation, this would fetch from Hugging Face API
      // For now, return mock data
      const mockModels: AIModel[] = [
        {
          id: 'mistral-7b',
          name: 'Mistral 7B',
          type: 'chat',
          source: 'huggingface',
          path: '',
          size: 14000000000,
          description: 'Mistral 7B language model',
          parameters: 7000000000,
          quantized: false,
          fileType: 'gguf',
          downloadUrl: 'https://huggingface.co/mistralai/Mistral-7B',
          isDownloaded: false,
          isCopied: false,
          createdAt: new Date(),
        },
        {
          id: 'llama-2-7b',
          name: 'Llama 2 7B',
          type: 'chat',
          source: 'huggingface',
          path: '',
          size: 13000000000,
          description: 'Llama 2 7B language model',
          parameters: 7000000000,
          quantized: false,
          fileType: 'gguf',
          downloadUrl: 'https://huggingface.co/meta-llama/Llama-2-7b',
          isDownloaded: false,
          isCopied: false,
          createdAt: new Date(),
        },
        {
          id: 'phi-2',
          name: 'Phi-2',
          type: 'chat',
          source: 'huggingface',
          path: '',
          size: 2500000000,
          description: 'Phi-2 language model',
          parameters: 2500000000,
          quantized: false,
          fileType: 'gguf',
          downloadUrl: 'https://huggingface.co/microsoft/phi-2',
          isDownloaded: false,
          isCopied: false,
          createdAt: new Date(),
        },
      ].filter(model => {
        if (type && model.type !== type) return false;
        if (searchQuery && !model.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
        return true;
      });

      return mockModels;
    } catch (error) {
      console.error('Failed to fetch models:', error);
      dispatch({ type: 'SET_ERROR', payload: 'Failed to fetch models from Hugging Face' });
      return [];
    }
  }, []);

  const downloadModel = useCallback(async (model: AIModel, includeExtended = false) => {
    try {
      dispatch({
        type: 'UPDATE_DOWNLOAD_PROGRESS',
        payload: { modelId: model.id, progress: 0, status: 'pending' },
      });

      dispatch({
        type: 'UPDATE_DOWNLOAD_PROGRESS',
        payload: { modelId: model.id, progress: 0, status: 'downloading' },
      });

      // Simulate download progress
      for (let i = 0; i <= 100; i += 10) {
        await new Promise(resolve => setTimeout(resolve, 500));
        dispatch({
          type: 'UPDATE_DOWNLOAD_PROGRESS',
          payload: { modelId: model.id, progress: i, status: 'downloading' },
        });
      }

      // In a real implementation:
      // 1. Download the model file
      // 2. Save it to the app's file system
      // 3. Update the model's path and isDownloaded status

      const modelDir = `${FileSystem.documentDirectory}models/`;
      await FileSystem.makeDirectoryAsync(modelDir, { intermediates: true });

      const fileExt = MODEL_EXTENSIONS[model.type][0];
      const fileName = `${model.id.replace(/[^a-z0-9]/gi, '_')}${fileExt}`;
      const filePath = `${modelDir}${fileName}`;

      // Simulate file download
      await FileSystem.writeAsStringAsync(filePath, `Mock model file for ${model.name}`);

      // Handle extended files if requested
      let extendedFiles: string[] = [];
      if (includeExtended) {
        // Check if model has extended files
        const extendedExts = EXTENDED_MODEL_EXTENSIONS;
        for (const ext of extendedExts) {
          const extendedFileName = `${model.id.replace(/[^a-z0-9]/gi, '_')}${ext}`;
          const extendedFilePath = `${modelDir}${extendedFileName}`;
          await FileSystem.writeAsStringAsync(extendedFilePath, `Mock extended file ${ext}`);
          extendedFiles.push(extendedFileName);
        }
      }

      // Update model
      dispatch({
        type: 'UPDATE_MODEL',
        payload: {
          id: model.id,
          path: filePath,
          isDownloaded: true,
          isCopied: false,
          extendedFiles,
        },
      });

      dispatch({
        type: 'UPDATE_DOWNLOAD_PROGRESS',
        payload: { modelId: model.id, progress: 100, status: 'completed' },
      });
    } catch (error) {
      console.error('Failed to download model:', error);
      dispatch({
        type: 'UPDATE_DOWNLOAD_PROGRESS',
        payload: { modelId: model.id, progress: 0, status: 'failed' },
      });
      dispatch({ type: 'SET_ERROR', payload: 'Failed to download model' });
    }
  }, []);

  const deleteModel = useCallback(async (modelId: string) => {
    try {
      const model = state.models.find(m => m.id === modelId);
      if (!model) return;

      // Delete the model file
      if (model.path && model.path.startsWith(FileSystem.documentDirectory)) {
        await FileSystem.deleteAsync(model.path, { idempotent: true });
      }

      // Delete extended files
      if (model.extendedFiles) {
        for (const extFile of model.extendedFiles) {
          const extPath = `${FileSystem.documentDirectory}models/${extFile}`;
          await FileSystem.deleteAsync(extPath, { idempotent: true });
        }
      }

      dispatch({ type: 'DELETE_MODEL', payload: modelId });
    } catch (error) {
      console.error('Failed to delete model:', error);
      dispatch({ type: 'SET_ERROR', payload: 'Failed to delete model' });
    }
  }, [state.models]);

  const copyModel = useCallback(async (modelId: string) => {
    try {
      const model = state.models.find(m => m.id === modelId);
      if (!model || !model.path) return;

      // In a real implementation, this would copy the model file
      // to the app's internal storage so it can be used even if the
      // original file is deleted

      const modelDir = `${FileSystem.documentDirectory}models/`;
      await FileSystem.makeDirectoryAsync(modelDir, { intermediates: true });

      const fileName = model.path.split('/').pop() || model.id;
      const newPath = `${modelDir}copied_${fileName}`;

      // Simulate copy
      const fileInfo = await FileSystem.getInfoAsync(model.path);
      if (fileInfo.exists) {
        await FileSystem.copyAsync({ from: model.path, to: newPath });
      }

      dispatch({
        type: 'UPDATE_MODEL',
        payload: {
          id: modelId,
          path: newPath,
          isCopied: true,
        },
      });
    } catch (error) {
      console.error('Failed to copy model:', error);
      dispatch({ type: 'SET_ERROR', payload: 'Failed to copy model' });
    }
  }, [state.models]);

  const getModel = useCallback((modelId: string) => {
    return state.models.find(model => model.id === modelId);
  }, [state.models]);

  const getModelsByType = useCallback((type: ModelType) => {
    return state.models.filter(model => model.type === type);
  }, [state.models]);

  const searchModels = useCallback((query: string, type?: ModelType) => {
    return state.models.filter(model => {
      const matchesType = type ? model.type === type : true;
      const matchesQuery = model.name.toLowerCase().includes(query.toLowerCase()) ||
        model.description.toLowerCase().includes(query.toLowerCase());
      return matchesType && matchesQuery;
    });
  }, [state.models]);

  const checkStorageSpace = useCallback(async (requiredSpace: number) => {
    try {
      const freeSpace = await FileSystem.getFreeDiskSpaceAsync();
      return freeSpace > requiredSpace;
    } catch (error) {
      console.error('Failed to check storage space:', error);
      return false;
    }
  }, []);

  const getModelPath = useCallback((modelId: string) => {
    const model = state.models.find(m => m.id === modelId);
    return model?.path || '';
  }, [state.models]);

  const value: ModelContextType = {
    models: state.models,
    isLoading: state.isLoading,
    error: state.error,
    downloadProgress: state.downloadProgress,
    fetchHuggingFaceModels,
    downloadModel,
    deleteModel,
    copyModel,
    getModel,
    getModelsByType,
    searchModels,
    checkStorageSpace,
    getModelPath,
  };

  return <ModelContext.Provider value={value}>{children}</ModelContext.Provider>;
};

export const useModels = () => {
  const context = useContext(ModelContext);
  if (context === undefined) {
    throw new Error('useModels must be used within a ModelProvider');
  }
  return context;
};
