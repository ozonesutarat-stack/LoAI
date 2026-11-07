import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { STORAGE_KEYS, DEFAULT_UI_SETTINGS, COLOR_PALETTES } from '../constants';
import { UISettings } from '../types';

interface UISettingsContextType {
  settings: UISettings;
  isLoading: boolean;
  error: string | null;
  updateSettings: (updates: Partial<UISettings>) => Promise<void>;
  resetToDefault: () => Promise<void>;
  applyTheme: (themeName: 'DEFAULT' | 'DARK' | 'LIGHT') => Promise<void>;
  getCurrentTheme: () => any;
}

const UISettingsContext = createContext<UISettingsContextType | undefined>(undefined);

const uiSettingsReducer = (
  state: {
    settings: UISettings;
    isLoading: boolean;
    error: string | null;
  },
  action: { type: 'SET_SETTINGS'; payload: UISettings } | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null } | { type: 'UPDATE_SETTINGS'; payload: Partial<UISettings> }
) => {
  switch (action.type) {
    case 'SET_SETTINGS':
      return {
        ...state,
        settings: action.payload,
        isLoading: false,
      };
    case 'UPDATE_SETTINGS':
      return {
        ...state,
        settings: { ...state.settings, ...action.payload },
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
    default:
      return state;
  }
};

export const UISettingsProvider: React.FC<{ children: React.ReactNode; initialSettings?: UISettings }> = ({
  children,
  initialSettings = DEFAULT_UI_SETTINGS,
}) => {
  const [state, dispatch] = useReducer(uiSettingsReducer, {
    settings: initialSettings,
    isLoading: false,
    error: null,
  });

  // Load settings from storage
  useEffect(() => {
    const loadSettings = async () => {
      try {
        dispatch({ type: 'SET_LOADING', payload: true });
        const savedSettings = await AsyncStorage.getItem(STORAGE_KEYS.UI_SETTINGS);

        if (savedSettings) {
          const settings: UISettings = JSON.parse(savedSettings);
          dispatch({ type: 'SET_SETTINGS', payload: settings });
        } else {
          dispatch({ type: 'SET_SETTINGS', payload: initialSettings });
        }
      } catch (error) {
        console.error('Failed to load UI settings:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load UI settings' });
        dispatch({ type: 'SET_SETTINGS', payload: initialSettings });
      }
    };

    loadSettings();
  }, [initialSettings]);

  // Save settings to storage when they change
  useEffect(() => {
    const saveSettings = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.UI_SETTINGS, JSON.stringify(state.settings));
      } catch (error) {
        console.error('Failed to save UI settings:', error);
      }
    };

    saveSettings();
  }, [state.settings]);

  const updateSettings = useCallback(async (updates: Partial<UISettings>) => {
    dispatch({ type: 'UPDATE_SETTINGS', payload: updates });
  }, []);

  const resetToDefault = useCallback(async () => {
    dispatch({ type: 'SET_SETTINGS', payload: DEFAULT_UI_SETTINGS });
  }, []);

  const applyTheme = useCallback(async (themeName: 'DEFAULT' | 'DARK' | 'LIGHT') => {
    const palette = COLOR_PALETTES[themeName];
    const newSettings: UISettings = {
      ...state.settings,
      theme: {
        ...state.settings.theme,
        ...palette,
      },
    };
    dispatch({ type: 'SET_SETTINGS', payload: newSettings });
  }, [state.settings]);

  const getCurrentTheme = useCallback(() => {
    return {
      ...state.settings.theme,
      blur: state.settings.blur,
      edge: state.settings.edge,
      transparency: state.settings.transparency,
    };
  }, [state.settings]);

  const value: UISettingsContextType = {
    settings: state.settings,
    isLoading: state.isLoading,
    error: state.error,
    updateSettings,
    resetToDefault,
    applyTheme,
    getCurrentTheme,
  };

  return <UISettingsContext.Provider value={value}>{children}</UISettingsContext.Provider>;
};

export const useUISettings = () => {
  const context = useContext(UISettingsContext);
  if (context === undefined) {
    throw new Error('useUISettings must be used within a UISettingsProvider');
  }
  return context;
};
