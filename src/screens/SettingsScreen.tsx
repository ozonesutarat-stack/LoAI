import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useUISettings } from '../context/UISettingsContext';

const SettingsScreen: React.FC<{ navigation?: any }> = ({ navigation }) => {
  const { settings: uiSettings } = useUISettings();

  const settingsItems = [
    {
      id: 'ai',
      title: 'AI Settings',
      icon: 'brain',
      screen: 'AISettings',
      description: 'Configure AI model parameters',
    },
    {
      id: 'ui',
      title: 'UI Settings',
      icon: 'color-palette',
      screen: 'UISettings',
      description: 'Customize app appearance',
    },
    {
      id: 'tools',
      title: 'Tools',
      icon: 'apps',
      screen: 'Tools',
      description: 'Manage available tools',
    },
    {
      id: 'knowledge',
      title: 'Knowledge Base',
      icon: 'book',
      screen: 'KnowledgeBase',
      description: 'Manage your knowledge base',
    },
    {
      id: 'models',
      title: 'Model Management',
      icon: 'cube',
      screen: 'ModelSelection',
      description: 'Download and manage AI models',
    },
    {
      id: 'personas',
      title: 'Personas',
      icon: 'people',
      screen: 'PersonaSelection',
      description: 'Manage AI personas',
    },
    {
      id: 'projects',
      title: 'Projects',
      icon: 'folder',
      screen: 'Projects',
      description: 'View your projects',
    },
    {
      id: 'history',
      title: 'Chat History',
      icon: 'time',
      screen: 'History',
      description: 'View chat history',
    },
  ];

  const renderSettingItem = (item: any) => (
    <TouchableOpacity
      key={item.id}
      style={[styles.settingItem, { backgroundColor: uiSettings.theme.surface }]}
      onPress={() => navigation.navigate(item.screen)}
    >
      <View style={styles.settingIcon}>
        <Ionicons name={item.icon as any} size={24} color={uiSettings.theme.primaryColor} />
      </View>
      <View style={styles.settingInfo}>
        <Text style={[styles.settingTitle, { color: uiSettings.theme.textColor }]}>
          {item.title}
        </Text>
        <Text
          style={[styles.settingDescription, { color: uiSettings.theme.textSecondary }]}
          numberOfLines={1}
        >
          {item.description}
        </Text>
      </View>
      <Ionicons name="chevron-forward" size={20} color={uiSettings.theme.textSecondary} />
    </TouchableOpacity>
  );

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={[styles.header, { color: uiSettings.theme.textColor }]}>
          Settings
        </Text>

        <View style={styles.settingsList}>
          {settingsItems.map(renderSettingItem)}
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
  },
  header: {
    fontSize: 28,
    fontWeight: '600',
    marginBottom: 24,
  },
  settingsList: {
    gap: 12,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
  },
  settingIcon: {
    width: 48,
    height: 48,
    borderRadius: 12,
    backgroundColor: 'rgba(108, 92, 231, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  settingInfo: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
  },
  settingDescription: {
    fontSize: 14,
    marginTop: 2,
  },
});

export default SettingsScreen;
