import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { STORAGE_KEYS, PREDEFINED_PERSONAS } from '../constants';
import { Persona, PersonaAction } from '../types';

interface PersonaContextType {
  personas: Persona[];
  isLoading: boolean;
  error: string | null;
  selectedPersona: Persona | null;
  selectPersona: (personaId: string) => void;
  createPersona: (persona: Omit<Persona, 'id' | 'createdAt'>) => Promise<Persona>;
  updatePersona: (personaId: string, updates: Partial<Persona>) => Promise<void>;
  deletePersona: (personaId: string) => Promise<void>;
  getPersona: (personaId: string) => Persona | undefined;
  getPersonasByCategory: (category: string) => Persona[];
  resetToDefault: () => Promise<void>;
}

const PersonaContext = createContext<PersonaContextType | undefined>(undefined);

const personaReducer = (
  state: {
    personas: Persona[];
    isLoading: boolean;
    error: string | null;
    selectedPersona: Persona | null;
  },
  action: PersonaAction | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null } | { type: 'SET_SELECTED'; payload: Persona | null } | { type: 'SET_PERSONAS'; payload: Persona[] }
) => {
  switch (action.type) {
    case 'ADD_PERSONA':
      return {
        ...state,
        personas: [...state.personas, action.payload],
        isLoading: false,
      };
    case 'UPDATE_PERSONA':
      return {
        ...state,
        personas: state.personas.map(persona =>
          persona.id === action.payload.id ? { ...persona, ...action.payload } : persona
        ),
      };
    case 'DELETE_PERSONA':
      return {
        ...state,
        personas: state.personas.filter(persona => persona.id !== action.payload),
        selectedPersona: state.selectedPersona?.id === action.payload ? null : state.selectedPersona,
      };
    case 'SET_PERSONAS':
      return {
        ...state,
        personas: action.payload,
        isLoading: false,
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
    case 'SET_SELECTED':
      return {
        ...state,
        selectedPersona: action.payload,
      };
    default:
      return state;
  }
};

export const PersonaProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(personaReducer, {
    personas: [],
    isLoading: false,
    error: null,
    selectedPersona: null,
  });

  // Load personas from storage
  useEffect(() => {
    const loadPersonas = async () => {
      try {
        dispatch({ type: 'SET_LOADING', payload: true });
        const savedPersonas = await AsyncStorage.getItem(STORAGE_KEYS.PERSONAS);

        if (savedPersonas) {
          const personas: Persona[] = JSON.parse(savedPersonas);
          dispatch({ type: 'SET_PERSONAS', payload: personas });
        } else {
          // Initialize with predefined personas
          dispatch({ type: 'SET_PERSONAS', payload: PREDEFINED_PERSONAS });
        }
      } catch (error) {
        console.error('Failed to load personas:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load personas' });
        // Fallback to predefined personas
        dispatch({ type: 'SET_PERSONAS', payload: PREDEFINED_PERSONAS });
      }
    };

    loadPersonas();
  }, []);

  // Save personas to storage when they change
  useEffect(() => {
    const savePersonas = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.PERSONAS, JSON.stringify(state.personas));
      } catch (error) {
        console.error('Failed to save personas:', error);
      }
    };

    if (state.personas.length > 0) {
      savePersonas();
    }
  }, [state.personas]);

  const selectPersona = useCallback((personaId: string) => {
    const persona = state.personas.find(p => p.id === personaId);
    if (persona) {
      dispatch({ type: 'SET_SELECTED', payload: persona });
    }
  }, [state.personas]);

  const createPersona = useCallback(async (personaData: Omit<Persona, 'id' | 'createdAt'>) => {
    const newPersona: Persona = {
      ...personaData,
      id: `persona_${Date.now()}`,
      createdAt: new Date(),
    };

    dispatch({ type: 'ADD_PERSONA', payload: newPersona });
    return newPersona;
  }, []);

  const updatePersona = useCallback(async (personaId: string, updates: Partial<Persona>) => {
    dispatch({ type: 'UPDATE_PERSONA', payload: { id: personaId, ...updates } });
  }, []);

  const deletePersona = useCallback(async (personaId: string) => {
    dispatch({ type: 'DELETE_PERSONA', payload: personaId });
  }, []);

  const getPersona = useCallback((personaId: string) => {
    return state.personas.find(persona => persona.id === personaId);
  }, [state.personas]);

  const getPersonasByCategory = useCallback((category: string) => {
    return state.personas.filter(persona => persona.category === category);
  }, [state.personas]);

  const resetToDefault = useCallback(async () => {
    dispatch({ type: 'SET_PERSONAS', payload: PREDEFINED_PERSONAS });
    dispatch({ type: 'SET_SELECTED', payload: null });
  }, []);

  const value: PersonaContextType = {
    personas: state.personas,
    isLoading: state.isLoading,
    error: state.error,
    selectedPersona: state.selectedPersona,
    selectPersona,
    createPersona,
    updatePersona,
    deletePersona,
    getPersona,
    getPersonasByCategory,
    resetToDefault,
  };

  return <PersonaContext.Provider value={value}>{children}</PersonaContext.Provider>;
};

export const usePersonas = () => {
  const context = useContext(PersonaContext);
  if (context === undefined) {
    throw new Error('usePersonas must be used within a PersonaProvider');
  }
  return context;
};
