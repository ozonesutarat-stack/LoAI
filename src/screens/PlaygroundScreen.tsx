import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useUISettings } from '../context/UISettingsContext';

const PlaygroundScreen: React.FC<{ navigation?: any }> = ({ navigation }) => {
  const { settings: uiSettings } = useUISettings();

  const playgroundItems = [
    {
      id: 'codebug',
      title: 'Co-Debug',
      icon: 'code-working',
      screen: 'CoDebug',
      description: 'Test and debug code with AI assistance',
      color: '#6c5ce7',
    },
    {
      id: 'translator',
      title: 'Smart Translator',
      icon: 'language',
      screen: 'SmartTranslator',
      description: 'Translate text with AI-powered accuracy',
      color: '#00cec9',
    },
    {
      id: 'document',
      title: 'Document Reader',
      icon: 'document-text',
      screen: 'DocumentReader',
      description: 'Read and summarize documents',
      color: '#fd79a8',
    },
  ];

  const renderPlaygroundItem = (item: any) => (
    <TouchableOpacity
      key={item.id}
      style={[styles.item, { backgroundColor: item.color }]}
      onPress={() => navigation.navigate(item.screen)}
    >
      <View style={styles.itemContent}>
        <Ionicons name={item.icon as any} size={32} color="white" />
        <Text style={styles.itemTitle}>{item.title}</Text>
        <Text style={styles.itemDescription}>{item.description}</Text>
      </View>
      <Ionicons name="chevron-forward" size={24} color="white" />
    </TouchableOpacity>
  );

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={[styles.header, { color: uiSettings.theme.textColor }]}>
          Playground
        </Text>

        <Text
          style={[styles.subHeader, { color: uiSettings.theme.textSecondary }]}
        >
          Experiment with AI-powered tools
        </Text>

        <View style={styles.itemsList}>
          {playgroundItems.map(renderPlaygroundItem)}
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
    marginBottom: 8,
  },
  subHeader: {
    fontSize: 14,
    marginBottom: 24,
  },
  itemsList: {
    gap: 16,
  },
  item: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderRadius: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 4,
  },
  itemContent: {
    flex: 1,
  },
  itemTitle: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
    marginTop: 8,
    marginBottom: 4,
  },
  itemDescription: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
  },
});

export default PlaygroundScreen;
