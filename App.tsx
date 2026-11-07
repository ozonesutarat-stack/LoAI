import React, { useEffect, useState } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { StatusBar, StyleSheet, View } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import { useFonts } from 'expo-font';
import { Ionicons } from '@expo/vector-icons';
import { ChatProvider } from './src/context/ChatContext';
import { ModelProvider } from './src/context/ModelContext';
import { PersonaProvider } from './src/context/PersonaContext';
import { UISettingsProvider } from './src/context/UISettingsContext';
import { ToolProvider } from './src/context/ToolContext';
import { ProjectProvider } from './src/context/ProjectContext';
import { KnowledgeBaseProvider } from './src/context/KnowledgeBaseContext';
import { DEFAULT_UI_SETTINGS } from './src/constants';
import { UISettings } from './src/types';

// Import screens
import ChatScreen from './src/screens/ChatScreen';
import ChatListScreen from './src/screens/ChatListScreen';
import ModelSelectionScreen from './src/screens/ModelSelectionScreen';
import ModelDownloadScreen from './src/screens/ModelDownloadScreen';
import ModelSettingsScreen from './src/screens/ModelSettingsScreen';
import PersonaSelectionScreen from './src/screens/PersonaSelectionScreen';
import PersonaEditorScreen from './src/screens/PersonaEditorScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import AISettingsScreen from './src/screens/AISettingsScreen';
import UISettingsScreen from './src/screens/UISettingsScreen';
import ToolsScreen from './src/screens/ToolsScreen';
import ToolConfigScreen from './src/screens/ToolConfigScreen';
import KnowledgeBaseScreen from './src/screens/KnowledgeBaseScreen';
import KnowledgeBaseDetailScreen from './src/screens/KnowledgeBaseDetailScreen';
import PlaygroundScreen from './src/screens/PlaygroundScreen';
import CoDebugScreen from './src/screens/CoDebugScreen';
import SmartTranslatorScreen from './src/screens/SmartTranslatorScreen';
import DocumentReaderScreen from './src/screens/DocumentReaderScreen';
import ProjectsScreen from './src/screens/ProjectsScreen';
import ProjectDetailScreen from './src/screens/ProjectDetailScreen';
import HistoryScreen from './src/screens/HistoryScreen';

// Import types
import { RootStackParamList, TabParamList } from './src/types';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

// Tab Bar Component
const TabBar: React.FC = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          switch (route.name) {
            case 'ChatTab':
              iconName = focused ? 'chatbubble-ellipses' : 'chatbubble-ellipses-outline';
              break;
            case 'ModelsTab':
              iconName = focused ? 'cube' : 'cube-outline';
              break;
            case 'PlaygroundTab':
              iconName = focused ? 'flask' : 'flask-outline';
              break;
            case 'SettingsTab':
              iconName = focused ? 'settings' : 'settings-outline';
              break;
            default:
              iconName = 'home';
          }
          return <Ionicons name={iconName as any} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#6c5ce7',
        tabBarInactiveTintColor: '#b2bec3',
        tabBarStyle: {
          backgroundColor: '#1a1a2e',
          borderTopWidth: 0,
          elevation: 0,
          height: 60,
        },
        tabBarLabelStyle: {
          fontSize: 12,
        },
        headerShown: false,
      })}
    >
      <Tab.Screen name="ChatTab" component={ChatListScreen} />
      <Tab.Screen name="ModelsTab" component={ModelSelectionScreen} />
      <Tab.Screen name="PlaygroundTab" component={PlaygroundScreen} />
      <Tab.Screen name="SettingsTab" component={SettingsScreen} />
    </Tab.Navigator>
  );
};

// Main App Component
const App: React.FC = () => {
  const [appIsReady, setAppIsReady] = useState(false);
  const [uiSettings, setUISettings] = useState<UISettings>(DEFAULT_UI_SETTINGS);

  // Load fonts
  const [fontsLoaded] = useFonts({
    'Inter-Regular': require('./assets/fonts/Inter-Regular.ttf'),
    'Inter-Medium': require('./assets/fonts/Inter-Medium.ttf'),
    'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),
  });

  useEffect(() => {
    const prepare = async () => {
      try {
        await SplashScreen.preventAutoHideAsync();
        // Load settings from storage
        // await loadSettings();
        setAppIsReady(true);
        await SplashScreen.hideAsync();
      } catch (e) {
        console.warn(e);
      } finally {
        setAppIsReady(true);
      }
    };

    prepare();
  }, []);

  if (!appIsReady || !fontsLoaded) {
    return null;
  }

  return (
    <GestureHandlerRootView style={styles.container}>
      <SafeAreaProvider>
        <UISettingsProvider initialSettings={uiSettings}>
          <ChatProvider>
            <ModelProvider>
              <PersonaProvider>
                <ToolProvider>
                  <ProjectProvider>
                    <KnowledgeBaseProvider>
                      <NavigationContainer>
                        <StatusBar
                          barStyle="light-content"
                          backgroundColor={uiSettings.theme.backgroundColor}
                        />
                        <Stack.Navigator
                          initialRouteName="Home"
                          screenOptions={{
                            headerStyle: {
                              backgroundColor: uiSettings.theme.backgroundColor,
                            },
                            headerTintColor: uiSettings.theme.textColor,
                            contentStyle: {
                              backgroundColor: uiSettings.theme.backgroundColor,
                            },
                            animation: 'slide_from_right',
                          }}
                        >
                          <Stack.Screen
                            name="Home"
                            component={TabBar}
                            options={{
                              headerShown: false,
                            }}
                          />
                          <Stack.Screen
                            name="Chat"
                            component={ChatScreen}
                            options={{
                              title: 'Chat',
                              headerBackTitle: 'Back',
                            }}
                          />
                          <Stack.Screen
                            name="ChatList"
                            component={ChatListScreen}
                            options={{
                              title: 'Chats',
                            }}
                          />
                          <Stack.Screen
                            name="ModelSelection"
                            component={ModelSelectionScreen}
                            options={{
                              title: 'Select Model',
                            }}
                          />
                          <Stack.Screen
                            name="ModelDownload"
                            component={ModelDownloadScreen}
                            options={{
                              title: 'Download Model',
                            }}
                          />
                          <Stack.Screen
                            name="ModelSettings"
                            component={ModelSettingsScreen}
                            options={{
                              title: 'Model Settings',
                            }}
                          />
                          <Stack.Screen
                            name="PersonaSelection"
                            component={PersonaSelectionScreen}
                            options={{
                              title: 'Select Persona',
                            }}
                          />
                          <Stack.Screen
                            name="PersonaEditor"
                            component={PersonaEditorScreen}
                            options={{
                              title: 'Edit Persona',
                            }}
                          />
                          <Stack.Screen
                            name="Settings"
                            component={SettingsScreen}
                            options={{
                              title: 'Settings',
                            }}
                          />
                          <Stack.Screen
                            name="AISettings"
                            component={AISettingsScreen}
                            options={{
                              title: 'AI Settings',
                            }}
                          />
                          <Stack.Screen
                            name="UISettings"
                            component={UISettingsScreen}
                            options={{
                              title: 'UI Settings',
                            }}
                          />
                          <Stack.Screen
                            name="Tools"
                            component={ToolsScreen}
                            options={{
                              title: 'Tools',
                            }}
                          />
                          <Stack.Screen
                            name="ToolConfig"
                            component={ToolConfigScreen}
                            options={{
                              title: 'Tool Configuration',
                            }}
                          />
                          <Stack.Screen
                            name="KnowledgeBase"
                            component={KnowledgeBaseScreen}
                            options={{
                              title: 'Knowledge Base',
                            }}
                          />
                          <Stack.Screen
                            name="KnowledgeBaseDetail"
                            component={KnowledgeBaseDetailScreen}
                            options={{
                              title: 'Knowledge Base Details',
                            }}
                          />
                          <Stack.Screen
                            name="Playground"
                            component={PlaygroundScreen}
                            options={{
                              title: 'Playground',
                            }}
                          />
                          <Stack.Screen
                            name="CoDebug"
                            component={CoDebugScreen}
                            options={{
                              title: 'Co-Debug',
                            }}
                          />
                          <Stack.Screen
                            name="SmartTranslator"
                            component={SmartTranslatorScreen}
                            options={{
                              title: 'Smart Translator',
                            }}
                          />
                          <Stack.Screen
                            name="DocumentReader"
                            component={DocumentReaderScreen}
                            options={{
                              title: 'Document Reader',
                            }}
                          />
                          <Stack.Screen
                            name="Projects"
                            component={ProjectsScreen}
                            options={{
                              title: 'Projects',
                            }}
                          />
                          <Stack.Screen
                            name="ProjectDetail"
                            component={ProjectDetailScreen}
                            options={{
                              title: 'Project Details',
                            }}
                          />
                          <Stack.Screen
                            name="History"
                            component={HistoryScreen}
                            options={{
                              title: 'History',
                            }}
                          />
                        </Stack.Navigator>
                      </NavigationContainer>
                    </KnowledgeBaseProvider>
                  </ProjectProvider>
                </ToolProvider>
              </PersonaProvider>
            </ModelProvider>
          </ChatProvider>
        </UISettingsProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
