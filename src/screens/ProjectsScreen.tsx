import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useUISettings } from '../context/UISettingsContext';

const ProjectsScreen: React.FC<{ navigation?: any; route?: any }> = ({ navigation, route }) => {
  const { settings: uiSettings } = useUISettings();

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      <Text style={[styles.title, { color: uiSettings.theme.textColor }]}>
        ProjectsScreen
      </Text>
      <Text style={[styles.subtitle, { color: uiSettings.theme.textSecondary }]}>
        Coming Soon
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
  },
});

export default ProjectsScreen;

