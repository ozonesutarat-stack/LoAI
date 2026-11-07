import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { STORAGE_KEYS, PREDEFINED_TOOLS } from '../constants';
import { Tool, ToolType } from '../types';

interface ToolContextType {
  tools: Tool[];
  isLoading: boolean;
  error: string | null;
  enabledTools: Tool[];
  webSearchTool: Tool | null;
  knowledgeBaseTool: Tool | null;
  customTools: Tool[];
  enableTool: (toolId: string) => Promise<void>;
  disableTool: (toolId: string) => Promise<void>;
  configureTool: (toolId: string, configuration: Record<string, unknown>) => Promise<void>;
  createCustomTool: (tool: Omit<Tool, 'id' | 'type' | 'enabled'>) => Promise<Tool>;
  deleteCustomTool: (toolId: string) => Promise<void>;
  getTool: (toolId: string) => Tool | undefined;
  getToolsByType: (type: ToolType) => Tool[];
  resetToDefault: () => Promise<void>;
}

const ToolContext = createContext<ToolContextType | undefined>(undefined);

interface ToolAction {
  type: 'ADD_TOOL' | 'UPDATE_TOOL' | 'DELETE_TOOL' | 'SET_TOOLS';
  payload: Tool | Tool[] | string;
}

const toolReducer = (
  state: {
    tools: Tool[];
    isLoading: boolean;
    error: string | null;
  },
  action: ToolAction | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null }
) => {
  switch (action.type) {
    case 'ADD_TOOL':
      return {
        ...state,
        tools: [...state.tools, action.payload as Tool],
        isLoading: false,
      };
    case 'UPDATE_TOOL':
      return {
        ...state,
        tools: state.tools.map(tool =>
          tool.id === (action.payload as Tool).id ? { ...tool, ...(action.payload as Tool) } : tool
        ),
      };
    case 'DELETE_TOOL':
      return {
        ...state,
        tools: state.tools.filter(tool => tool.id !== action.payload),
      };
    case 'SET_TOOLS':
      return {
        ...state,
        tools: action.payload as Tool[],
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
      };
    default:
      return state;
  }
};

export const ToolProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(toolReducer, {
    tools: [],
    isLoading: false,
    error: null,
  });

  // Load tools from storage
  useEffect(() => {
    const loadTools = async () => {
      try {
        dispatch({ type: 'SET_LOADING', payload: true });
        const savedTools = await AsyncStorage.getItem(STORAGE_KEYS.TOOLS);

        if (savedTools) {
          const tools: Tool[] = JSON.parse(savedTools);
          dispatch({ type: 'SET_TOOLS', payload: tools });
        } else {
          // Initialize with predefined tools
          dispatch({ type: 'SET_TOOLS', payload: PREDEFINED_TOOLS });
        }
      } catch (error) {
        console.error('Failed to load tools:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load tools' });
        // Fallback to predefined tools
        dispatch({ type: 'SET_TOOLS', payload: PREDEFINED_TOOLS });
      }
    };

    loadTools();
  }, []);

  // Save tools to storage when they change
  useEffect(() => {
    const saveTools = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.TOOLS, JSON.stringify(state.tools));
      } catch (error) {
        console.error('Failed to save tools:', error);
      }
    };

    if (state.tools.length > 0) {
      saveTools();
    }
  }, [state.tools]);

  const enableTool = useCallback(async (toolId: string) => {
    dispatch({
      type: 'UPDATE_TOOL',
      payload: { id: toolId, enabled: true } as Tool,
    });
  }, []);

  const disableTool = useCallback(async (toolId: string) => {
    dispatch({
      type: 'UPDATE_TOOL',
      payload: { id: toolId, enabled: false } as Tool,
    });
  }, []);

  const configureTool = useCallback(async (toolId: string, configuration: Record<string, unknown>) => {
    const tool = state.tools.find(t => t.id === toolId);
    if (tool) {
      dispatch({
        type: 'UPDATE_TOOL',
        payload: { ...tool, configuration: { ...tool.configuration, ...configuration } } as Tool,
      });
    }
  }, [state.tools]);

  const createCustomTool = useCallback(async (toolData: Omit<Tool, 'id' | 'type' | 'enabled'>) => {
    const newTool: Tool = {
      ...toolData,
      id: `custom_tool_${Date.now()}`,
      type: 'custom',
      enabled: true,
    };

    dispatch({ type: 'ADD_TOOL', payload: newTool });
    return newTool;
  }, []);

  const deleteCustomTool = useCallback(async (toolId: string) => {
    const tool = state.tools.find(t => t.id === toolId);
    if (tool && tool.type === 'custom') {
      dispatch({ type: 'DELETE_TOOL', payload: toolId });
    }
  }, [state.tools]);

  const getTool = useCallback((toolId: string) => {
    return state.tools.find(tool => tool.id === toolId);
  }, [state.tools]);

  const getToolsByType = useCallback((type: ToolType) => {
    return state.tools.filter(tool => tool.type === type);
  }, [state.tools]);

  const resetToDefault = useCallback(async () => {
    dispatch({ type: 'SET_TOOLS', payload: PREDEFINED_TOOLS });
  }, []);

  // Computed values
  const enabledTools = state.tools.filter(t => t.enabled);
  const webSearchTool = state.tools.find(t => t.type === 'web_search') || null;
  const knowledgeBaseTool = state.tools.find(t => t.type === 'knowledge_base') || null;
  const customTools = state.tools.filter(t => t.type === 'custom');

  const value: ToolContextType = {
    tools: state.tools,
    isLoading: state.isLoading,
    error: state.error,
    enabledTools,
    webSearchTool,
    knowledgeBaseTool,
    customTools,
    enableTool,
    disableTool,
    configureTool,
    createCustomTool,
    deleteCustomTool,
    getTool,
    getToolsByType,
    resetToDefault,
  };

  return <ToolContext.Provider value={value}>{children}</ToolContext.Provider>;
};

export const useTools = () => {
  const context = useContext(ToolContext);
  if (context === undefined) {
    throw new Error('useTools must be used within a ToolProvider');
  }
  return context;
};
