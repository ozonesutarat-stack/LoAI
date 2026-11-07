import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch, Slider, TextInput } from 'react-native';
import { useChat } from '../context/ChatContext';
import { useUISettings } from '../context/UISettingsContext';
import { ChatSettings } from '../types';

const AISettingsScreen: React.FC = () => {
  const { settings, updateSettings } = useChat();
  const { settings: uiSettings } = useUISettings();

  const [tempSettings, setTempSettings] = useState<ChatSettings>(settings);

  const handleSave = useCallback(() => {
    updateSettings(tempSettings);
  }, [tempSettings, updateSettings]);

  const handleChange = useCallback((key: keyof ChatSettings, value: number) => {
    setTempSettings(prev => ({ ...prev, [key]: value }));
  }, []);

  const settingsItems = [
    {
      id: 'temperature',
      title: 'Temperature',
      description: 'Controls randomness. Lower values produce more deterministic responses.',
      min: 0,
      max: 2,
      step: 0.1,
      icon: 'thermometer',
    },
    {
      id: 'maxTokens',
      title: 'Max Tokens',
      description: 'Maximum number of tokens to generate in the response.',
      min: 1,
      max: 8192,
      step: 1,
      icon: 'text',
    },
    {
      id: 'contextLength',
      title: 'Context Length',
      description: 'Number of tokens from the conversation to consider for context.',
      min: 1,
      max: 32768,
      step: 1,
      icon: 'layers',
    },
    {
      id: 'topP',
      title: 'Top P (Nucleus Sampling)',
      description: 'Probability threshold for nucleus sampling. Lower values focus on more likely tokens.',
      min: 0,
      max: 1,
      step: 0.01,
      icon: 'pulse',
    },
    {
      id: 'topK',
      title: 'Top K',
      description: 'Number of most likely tokens to consider at each step.',
      min: 1,
      max: 100,
      step: 1,
      icon: 'list',
    },
    {
      id: 'thinkTokens',
      title: 'Think Tokens',
      description: 'Number of tokens to use for thinking/processing before generating response.',
      min: 0,
      max: 1000,
      step: 1,
      icon: 'brain',
    },
  ];

  const renderSliderSetting = (item: any) => (
    <View
      key={item.id}
      style={[styles.settingItem, { backgroundColor: uiSettings.theme.surface }]}
    >
      <View style={styles.settingHeader}>
        <Text style={[styles.settingTitle, { color: uiSettings.theme.textColor }]}>
          {item.title}
        </Text>
      </View>
      
      <Text
        style={[styles.settingDescription, { color: uiSettings.theme.textSecondary }]}
      >
        {item.description}
      </Text>

      <View style={styles.sliderContainer}>
        <Slider
          style={styles.slider}
          minimumValue={item.min}
          maximumValue={item.max}
          step={item.step}
          value={tempSettings[item.id as keyof ChatSettings] as number}
          onValueChange={(value) => handleChange(item.id as keyof ChatSettings, value)}
          minimumTrackTintColor={uiSettings.theme.primaryColor}
          maximumTrackTintColor="rgba(255, 255, 255, 0.2)"
          thumbTintColor={uiSettings.theme.primaryColor}
        />
        <Text
          style={[styles.sliderValue, { color: uiSettings.theme.textColor }]}
        >
          {typeof tempSettings[item.id as keyof ChatSettings] === 'number' 
            ? (tempSettings[item.id as keyof ChatSettings] as number).toFixed(item.step < 1 ? 2 : 0)
            : tempSettings[item.id as keyof ChatSettings]}
        </Text>
      </View>
    </View>
  );

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={[styles.header, { color: uiSettings.theme.textColor }]}>
          AI Settings
        </Text>

        <Text
          style={[styles.subHeader, { color: uiSettings.theme.textSecondary }]}
        >
          Configure the parameters for AI responses
        </Text>

        <View style={styles.settingsList}>
          {settingsItems.map(renderSliderSetting)}
        </View>

        <View style={styles.saveContainer}>
          <Text
            style={[styles.saveText, { color: uiSettings.theme.textSecondary }]}
          >
            Changes will be applied to new conversations
          </Text>
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
  settingsList: {
    gap: 16,
  },
  settingItem: {
    padding: 16,
    borderRadius: 12,
  },
  settingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
  },
  settingDescription: {
    fontSize: 14,
    marginBottom: 12,
  },
  sliderContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  slider: {
    flex: 1,
    height: 40,
  },
  sliderValue: {
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 12,
    minWidth: 50,
    textAlign: 'right',
  },
  saveContainer: {
    marginTop: 24,
    alignItems: 'center',
  },
  saveText: {
    fontSize: 14,
  },
});

export default AISettingsScreen;
