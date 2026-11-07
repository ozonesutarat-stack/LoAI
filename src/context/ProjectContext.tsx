import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { STORAGE_KEYS, MESSAGE_LIMITS } from '../constants';
import { Project, ProjectFile } from '../types';

interface ProjectContextType {
  projects: Project[];
  isLoading: boolean;
  error: string | null;
  createProject: (name: string, description: string, type: string) => Promise<Project>;
  updateProject: (projectId: string, updates: Partial<Project>) => Promise<void>;
  deleteProject: (projectId: string) => Promise<void>;
  getProject: (projectId: string) => Project | undefined;
  addFileToProject: (projectId: string, file: Omit<ProjectFile, 'id'>) => Promise<ProjectFile>;
  removeFileFromProject: (projectId: string, fileId: string) => Promise<void>;
  updateProjectFile: (projectId: string, fileId: string, updates: Partial<ProjectFile>) => Promise<void>;
  getRecentProjects: (limit?: number) => Project[];
  searchProjects: (query: string) => Project[];
}

const ProjectContext = createContext<ProjectContextType | undefined>(undefined);

interface ProjectAction {
  type: 'ADD_PROJECT' | 'UPDATE_PROJECT' | 'DELETE_PROJECT' | 'SET_PROJECTS';
  payload: Project | Project[] | string;
}

const projectReducer = (
  state: {
    projects: Project[];
    isLoading: boolean;
    error: string | null;
  },
  action: ProjectAction | { type: 'SET_LOADING'; payload: boolean } | { type: 'SET_ERROR'; payload: string | null }
) => {
  switch (action.type) {
    case 'ADD_PROJECT':
      return {
        ...state,
        projects: [action.payload as Project, ...state.projects],
        isLoading: false,
      };
    case 'UPDATE_PROJECT':
      return {
        ...state,
        projects: state.projects.map(project =>
          project.id === (action.payload as Project).id ? { ...project, ...(action.payload as Project) } : project
        ),
      };
    case 'DELETE_PROJECT':
      return {
        ...state,
        projects: state.projects.filter(project => project.id !== action.payload),
      };
    case 'SET_PROJECTS':
      return {
        ...state,
        projects: action.payload as Project[],
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

export const ProjectProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(projectReducer, {
    projects: [],
    isLoading: false,
    error: null,
  });

  // Load projects from storage
  useEffect(() => {
    const loadProjects = async () => {
      try {
        dispatch({ type: 'SET_LOADING', payload: true });
        const savedProjects = await AsyncStorage.getItem(STORAGE_KEYS.PROJECTS);

        if (savedProjects) {
          const projects: Project[] = JSON.parse(savedProjects);
          dispatch({ type: 'SET_PROJECTS', payload: projects });
        }
      } catch (error) {
        console.error('Failed to load projects:', error);
        dispatch({ type: 'SET_ERROR', payload: 'Failed to load projects' });
      }
    };

    loadProjects();
  }, []);

  // Save projects to storage when they change
  useEffect(() => {
    const saveProjects = async () => {
      try {
        await AsyncStorage.setItem(STORAGE_KEYS.PROJECTS, JSON.stringify(state.projects));
      } catch (error) {
        console.error('Failed to save projects:', error);
      }
    };

    if (state.projects.length > 0) {
      saveProjects();
    }
  }, [state.projects]);

  const createProject = useCallback(async (name: string, description: string, type: Project['type']) => {
    const newProject: Project = {
      id: `project_${Date.now()}`,
      name,
      description,
      type,
      files: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    dispatch({ type: 'ADD_PROJECT', payload: newProject });
    return newProject;
  }, []);

  const updateProject = useCallback(async (projectId: string, updates: Partial<Project>) => {
    const project = state.projects.find(p => p.id === projectId);
    if (project) {
      dispatch({
        type: 'UPDATE_PROJECT',
        payload: { ...project, ...updates, updatedAt: new Date() } as Project,
      });
    }
  }, [state.projects]);

  const deleteProject = useCallback(async (projectId: string) => {
    dispatch({ type: 'DELETE_PROJECT', payload: projectId });
  }, []);

  const getProject = useCallback((projectId: string) => {
    return state.projects.find(project => project.id === projectId);
  }, [state.projects]);

  const addFileToProject = useCallback(async (projectId: string, fileData: Omit<ProjectFile, 'id'>) => {
    const project = state.projects.find(p => p.id === projectId);
    if (project) {
      const newFile: ProjectFile = {
        ...fileData,
        id: `file_${Date.now()}`,
      };

      const updatedProject: Project = {
        ...project,
        files: [...project.files, newFile],
        updatedAt: new Date(),
      };

      dispatch({ type: 'UPDATE_PROJECT', payload: updatedProject });
      return newFile;
    }
    throw new Error('Project not found');
  }, [state.projects]);

  const removeFileFromProject = useCallback(async (projectId: string, fileId: string) => {
    const project = state.projects.find(p => p.id === projectId);
    if (project) {
      const updatedProject: Project = {
        ...project,
        files: project.files.filter(f => f.id !== fileId),
        updatedAt: new Date(),
      };

      dispatch({ type: 'UPDATE_PROJECT', payload: updatedProject });
    }
  }, [state.projects]);

  const updateProjectFile = useCallback(async (projectId: string, fileId: string, updates: Partial<ProjectFile>) => {
    const project = state.projects.find(p => p.id === projectId);
    if (project) {
      const updatedFiles = project.files.map(f =>
        f.id === fileId ? { ...f, ...updates } : f
      );

      const updatedProject: Project = {
        ...project,
        files: updatedFiles,
        updatedAt: new Date(),
      };

      dispatch({ type: 'UPDATE_PROJECT', payload: updatedProject });
    }
  }, [state.projects]);

  const getRecentProjects = useCallback((limit: number = MESSAGE_LIMITS.INITIAL_DISPLAY) => {
    return [...state.projects]
      .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
      .slice(0, limit);
  }, [state.projects]);

  const searchProjects = useCallback((query: string) => {
    return state.projects.filter(project =>
      project.name.toLowerCase().includes(query.toLowerCase()) ||
      project.description.toLowerCase().includes(query.toLowerCase())
    );
  }, [state.projects]);

  const value: ProjectContextType = {
    projects: state.projects,
    isLoading: state.isLoading,
    error: state.error,
    createProject,
    updateProject,
    deleteProject,
    getProject,
    addFileToProject,
    removeFileFromProject,
    updateProjectFile,
    getRecentProjects,
    searchProjects,
  };

  return <ProjectContext.Provider value={value}>{children}</ProjectContext.Provider>;
};

export const useProjects = () => {
  const context = useContext(ProjectContext);
  if (context === undefined) {
    throw new Error('useProjects must be used within a ProjectProvider');
  }
  return context;
};
