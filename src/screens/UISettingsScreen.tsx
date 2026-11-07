import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch, Slider, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useUISettings } from '../context/UISettingsContext';
import { COLOR_PALETTES } from '../constants';
import { UISettings, UITheme } from '../types';

const UISettingsScreen: React.FC = () => {
  const { settings, updateSettings, applyTheme } = useUISettings();

  const [tempSettings, setTempSettings] = useState<UISettings>(settings);

  const handleSave = useCallback(() => {
    updateSettings(tempSettings);
  }, [tempSettings, updateSettings]);

  const handleThemeChange = useCallback((themeName: 'DEFAULT' | 'DARK' | 'LIGHT') => {
    applyTheme(themeName);
  }, [applyTheme]);

  const handleThemeColorChange = useCallback((key: keyof UITheme, value: string) => {
    setTempSettings(prev => ({
      ...prev,
      theme: {
        ...prev.theme,
        [key]: value,
      },
    }));
  }, []);

  const handleBlurChange = useCallback((key: keyof UISettings['blur'], value: number) => {
    setTempSettings(prev => ({
      ...prev,
      blur: {
        ...prev.blur,
        [key]: value,
      },
    }));
  }, []);

  const handleEdgeChange = useCallback((key: keyof UISettings['edge'], value: number) => {
    setTempSettings(prev => ({
      ...prev,
      edge: {
        ...prev.edge,
        [key]: value,
      },
    }));
  }, []);

  const handleGradientToggle = useCallback((enabled: boolean) => {
    setTempSettings(prev => ({
      ...prev,
      theme: {
        ...prev.theme,
        gradientEnabled: enabled,
      },
    }));
  }, []);

  const colorOptions = [
    { name: 'Primary', key: 'primaryColor' },
    { name: 'Secondary', key: 'secondaryColor' },
    { name: 'Background', key: 'backgroundColor' },
    { name: 'Surface', key: 'surface' },
    { name: 'Text', key: 'textColor' },
    { name: 'Bubble', key: 'bubbleColor' },
  ];

  const themePresets = [
    { name: 'Default', value: 'DEFAULT' },
    { name: 'Dark', value: 'DARK' },
    { name: 'Light', value: 'LIGHT' },
  ];

  const renderColorPicker = (label: string, value: string, onChange: (color: string) => void) => (
    <View style={styles.colorPickerContainer}>
      <Text style={[styles.colorLabel, { color: settings.theme.textColor }]}>{label}</Text>
      <View style={styles.colorOptions}>
        {Object.entries(COLOR_PALETTES).map(([name, palette]) => (
          <TouchableOpacity
            key={name}
            style={[styles.colorOption, { backgroundColor: palette.primary }]}
            onPress={() => onChange(palette.primary)}
          >
            {value === palette.primary && (
              <Ionicons name="checkmark" size={20} color="white" />
            )}
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );

  return (
    <View style={[styles.container, { backgroundColor: settings.theme.backgroundColor }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={[styles.header, { color: settings.theme.textColor }]}>
          UI Settings
        </Text>

        {/* Theme Presets */}
        <View style={[styles.section, { backgroundColor: settings.theme.surface }]}>
          <Text style={[styles.sectionTitle, { color: settings.theme.textColor }]}>
            Theme Presets
          </Text>
          <View style={styles.presetsContainer}>
            {themePresets.map(preset => (
              <TouchableOpacity
                key={preset.value}
                style={[
                  styles.presetButton,
                  {
                    backgroundColor: settings.theme.surface,
                    borderColor: settings.theme.edge.color,
                    borderWidth: settings.theme.edge.thickness,
                  },
                ]}
                onPress={() => handleThemeChange(preset.value as 'DEFAULT' | 'DARK' | 'LIGHT')}
              >
                <Text style={[styles.presetText, { color: settings.theme.textColor }]}>
                  {preset.name}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Gradient Toggle */}
        <View style={[styles.section, { backgroundColor: settings.theme.surface }]}>
          <View style={styles.settingRow}>
            <Text style={[styles.settingLabel, { color: settings.theme.textColor }]}>
              Gradient Background
            </Text>
            <Switch
              value={tempSettings.theme.gradientEnabled}
              onValueChange={handleGradientToggle}
              trackColor={{ false: 'rgba(255, 255, 255, 0.2)', true: settings.theme.primaryColor }}
              thumbColor={tempSettings.theme.gradientEnabled ? settings.theme.primaryColor : 'rgba(255, 255, 255, 0.5)'}
            />
          </View>
          
          {tempSettings.theme.gradientEnabled && (
            <>
              <Text style={[styles.settingLabel, { color: settings.theme.textColor, marginTop: 8 }]}>
                Gradient Colors
              </Text>
              <View style={styles.gradientPreview}>
                <View
                  style={[
                    styles.gradientBox,
                    {
                      backgroundColor: tempSettings.theme.gradientColors[0],
                      borderColor: settings.theme.edge.color,
                      borderWidth: settings.theme.edge.thickness,
                    },
                  ]}
                />
                <View
                  style={[
                    styles.gradientBox,
                    {
                      backgroundColor: tempSettings.theme.gradientColors[1],
                      borderColor: settings.theme.edge.color,
                      borderWidth: settings.theme.edge.thickness,
                    },
                  ]}
                />
              </View>
            </>
          )}
        </View>

        {/* Blur Settings */}
        <View style={[styles.section, { backgroundColor: settings.theme.surface }]}>
          <Text style={[styles.sectionTitle, { color: settings.theme.textColor }]}>
            Blur Settings
          </Text>
          
          <View style={styles.sliderContainer}>
            <Text style={[styles.sliderLabel, { color: settings.theme.textColor }]}>
              Blur Intensity: {tempSettings.blur.intensity}%
            </Text>
            <Slider
              style={styles.slider}
              minimumValue={0}
              maximumValue={100}
              step={1}
              value={tempSettings.blur.intensity}
              onValueChange={(value) => handleBlurChange('intensity', value)}
              minimumTrackTintColor={settings.theme.primaryColor}
              maximumTrackTintColor="rgba(255, 255, 255, 0.2)"
              thumbTintColor={settings.theme.primaryColor}
            />
          </View>
          
          <View style={styles.settingRow}>
            <Text style={[styles.settingLabel, { color: settings.theme.textColor }]}>
              Enable Blur
            </Text>
            <Switch
              value={tempSettings.blur.enabled}
              onValueChange={(value) => handleBlurChange('enabled', value ? 1 : 0)}
              trackColor={{ false: 'rgba(255, 255, 255, 0.2)', true: settings.theme.primaryColor }}
              thumbColor={tempSettings.blur.enabled ? settings.theme.primaryColor : 'rgba(255, 255, 255, 0.5)'}
            />
          </View>
        </View>

        {/* Edge Settings */}
        <View style={[styles.section, { backgroundColor: settings.theme.surface }]}>
          <Text style={[styles.sectionTitle, { color: settings.theme.textColor }]}>
            Edge Settings
          </Text>

          <View style={styles.sliderContainer}>
            <Text style={[styles.sliderLabel, { color: settings.theme.textColor }]}>
              Edge Thickness: {tempSettings.edge.thickness}px
            </Text>
            <Slider
              style={styles.slider}
              minimumValue={0}
              maximumValue={10}
              step={0.5}
              value={tempSettings.edge.thickness}
              onValueChange={(value) => handleEdgeChange('thickness', value)}
              minimumTrackTintColor={settings.theme.primaryColor}
              maximumTrackTintColor="rgba(255, 255, 255, 0.2)"
              thumbTintColor={settings.theme.primaryColor}
            />
          </View>

          <View style={styles.sliderContainer}>
            <Text style={[styles.sliderLabel, { color: settings.theme.textColor }]}>
              Edge Transparency: {Math.round(tempSettings.edge.transparency * 100)}%
            </Text>
            <Slider
              style={styles.slider}
              minimumValue={0}
              maximumValue={1}
              step={0.05}
              value={tempSettings.edge.transparency}
              onValueChange={(value) => handleEdgeChange('transparency', value)}
              minimumTrackTintColor={settings.theme.primaryColor}
              maximumTrackTintColor="rgba(255, 255, 255, 0.2)"
              thumbTintColor={settings.theme.primaryColor}
            />
          </View>

          {renderColorPicker(
            'Edge Color',
            tempSettings.edge.color,
            (color) => handleEdgeChange('color', color)
          )}
        </View>

        {/* Transparency */}
        <View style={[styles.section, { backgroundColor: settings.theme.surface }]}>
          <Text style={[styles.sectionTitle, { color: settings.theme.textColor }]}>
            Transparency
          </Text>

          <View style={styles.sliderContainer}>
            <Text style={[styles.sliderLabel, { color: settings.theme.textColor }]}>
              Overall Transparency: {Math.round(tempSettings.transparency * 100)}%
            </Text>
            <Slider
              style={styles.slider}
              minimumValue={0}
              maximumValue={1}
              step={0.05}
              value={tempSettings.transparency}
              onValueChange={(value) => setTempSettings(prev => ({ ...prev, transparency: value }))}
              minimumTrackTintColor={settings.theme.primaryColor}
              maximumTrackTintColor="rgba(255, 255, 255, 0.2)"
              thumbTintColor={settings.theme.primaryColor}
            />
          </View>
        </View>

        <View style={styles.saveContainer}>
          <Text
            style={[styles.saveText, { color: settings.theme.textSecondary }]}
          >
            Changes will be applied immediately
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
  section: {
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 12,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  settingLabel: {
    fontSize: 14,
  },
  colorPickerContainer: {
    marginTop: 8,
  },
  colorLabel: {
    fontSize: 14,
    marginBottom: 8,
  },
  colorOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  colorOption: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  presetsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 8,
  },
  presetButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  presetText: {
    fontSize: 14,
  },
  sliderContainer: {
    marginBottom: 12,
  },
  sliderLabel: {
    fontSize: 14,
    marginBottom: 4,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  gradientPreview: {
    flexDirection: 'row',
    marginTop: 8,
  },
  gradientBox: {
    width: 40,
    height: 40,
    borderRadius: 8,
    marginRight: 8,
  },
  saveContainer: {
    marginTop: 24,
    alignItems: 'center',
  },
  saveText: {
    fontSize: 14,
  },
});

export default UISettingsScreen;
