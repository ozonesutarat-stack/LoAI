import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Modal, FlatList } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Tool } from '../types';
import { useUISettings } from '../context/UISettingsContext';

interface ToolSelectorProps {
  tools: Tool[];
  onSelect: (toolId: string) => void;
  onClose: () => void;
  style?: any;
  visible?: boolean;
}

const ToolSelector: React.FC<ToolSelectorProps> = ({
  tools,
  onSelect,
  onClose,
  style,
  visible = true,
}) => {
  const { settings: uiSettings } = useUISettings();

  const renderTool = ({ item }: { item: Tool }) => (
    <TouchableOpacity
      style={[styles.toolItem, { backgroundColor: uiSettings.theme.surface }]}
      onPress={() => {
        onSelect(item.id);
        onClose();
      }}
    >
      <Text style={[styles.toolIcon, { color: uiSettings.theme.primaryColor }]}>
        {item.icon}
      </Text>
      <View style={styles.toolInfo}>
        <Text style={[styles.toolName, { color: uiSettings.theme.textColor }]}>
          {item.name}
        </Text>
        <Text
          style={[styles.toolDescription, { color: uiSettings.theme.textSecondary }]}
          numberOfLines={1}
        >
          {item.description}
        </Text>
      </View>
      <Ionicons name="chevron-forward" size={20} color={uiSettings.theme.textSecondary} />
    </TouchableOpacity>
  );

  return (
    <Modal
      visible={visible}
      transparent={true}
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={styles.modalContainer}>
        <View
          style={[
            styles.content,
            { backgroundColor: uiSettings.theme.backgroundColor },
            style,
          ]}
        >
          <View style={styles.header}>
            <Text style={[styles.headerTitle, { color: uiSettings.theme.textColor }]}>
              Select Tool
            </Text>
            <TouchableOpacity onPress={onClose} style={styles.closeButton}>
              <Ionicons name="close" size={24} color={uiSettings.theme.textColor} />
            </TouchableOpacity>
          </View>

          <FlatList
            data={tools}
            renderItem={renderTool}
            keyExtractor={(item) => item.id}
            contentContainerStyle={styles.listContent}
          />
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  content: {
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    padding: 16,
    maxHeight: '50%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  closeButton: {
    padding: 8,
  },
  listContent: {
    paddingBottom: 16,
  },
  toolItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  toolIcon: {
    fontSize: 24,
    marginRight: 12,
  },
  toolInfo: {
    flex: 1,
  },
  toolName: {
    fontSize: 16,
    fontWeight: '600',
  },
  toolDescription: {
    fontSize: 14,
    marginTop: 2,
  },
});

export default ToolSelector;
