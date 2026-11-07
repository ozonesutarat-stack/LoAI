import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
  TextInput,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { usePersonas } from '../context/PersonaContext';
import { useUISettings } from '../context/UISettingsContext';
import { Persona } from '../types';
import { PREDEFINED_PERSONAS } from '../constants';

const PersonaSelectionScreen: React.FC<{ navigation?: any }> = ({ navigation }) => {
  const { personas, selectedPersona, selectPersona, createPersona, deletePersona } = usePersonas();
  const { settings: uiSettings } = useUISettings();

  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newPersona, setNewPersona] = useState<Omit<Persona, 'id' | 'createdAt'>>({
    name: '',
    description: '',
    systemPrompt: '',
    category: 'custom',
    avatar: '👤',
    color: '#6c5ce7',
  });

  const handleSelectPersona = useCallback((persona: Persona) => {
    selectPersona(persona.id);
    navigation.goBack();
  }, [selectPersona, navigation]);

  const handleDeletePersona = useCallback((personaId: string) => {
    const persona = personas.find(p => p.id === personaId);
    if (!persona) return;

    Alert.alert(
      'Delete Persona',
      `Are you sure you want to delete "${persona.name}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => deletePersona(personaId) },
      ]
    );
  }, [personas, deletePersona]);

  const handleCreatePersona = useCallback(() => {
    if (!newPersona.name.trim()) {
      Alert.alert('Error', 'Persona name is required');
      return;
    }

    createPersona(newPersona);
    setShowCreateForm(false);
    setNewPersona({
      name: '',
      description: '',
      systemPrompt: '',
      category: 'custom',
      avatar: '👤',
      color: '#6c5ce7',
    });
  }, [newPersona, createPersona]);

  const handleEditPersona = useCallback((persona: Persona) => {
    navigation.navigate('PersonaEditor', { personaId: persona.id });
  }, [navigation]);

  const renderPersona = useCallback(({ item }: { item: Persona }) => {
    const isSelected = selectedPersona?.id === item.id;

    return (
      <View
        style={[
          styles.personaItem,
          { backgroundColor: uiSettings.theme.surface },
        ]}
      >
        <TouchableOpacity
          style={styles.personaContent}
          onPress={() => handleSelectPersona(item)}
        >
          <View style={[styles.personaAvatar, { backgroundColor: item.color }]}>
            <Text style={styles.personaAvatarText}>{item.avatar}</Text>
          </View>
          
          <View style={styles.personaInfo}>
            <Text
              style={[styles.personaName, { color: uiSettings.theme.textColor }]}
            >
              {item.name}
            </Text>
            <Text
              style={[styles.personaDescription, { color: uiSettings.theme.textSecondary }]}
              numberOfLines={1}
            >
              {item.description}
            </Text>
            <View style={styles.personaMeta}>
              <Text
                style={[styles.personaCategory, { color: uiSettings.theme.primaryColor }]}
              >
                {item.category.replace('_', ' ')}
              </Text>
              {item.id.startsWith('persona_') && (
                <Text style={[styles.personaCustom, { color: uiSettings.theme.textSecondary }]}>
                  Custom
                </Text>
              )}
            </View>
          </View>

          {isSelected && (
            <View style={styles.selectedIndicator}>
              <Ionicons name="checkmark" size={20} color="white" />
            </View>
          )}
        </TouchableOpacity>

        <View style={styles.personaActions}>
          <TouchableOpacity
            style={styles.actionButton}
            onPress={() => handleEditPersona(item)}
          >
            <Ionicons name="create-outline" size={20} color={uiSettings.theme.textSecondary} />
          </TouchableOpacity>
          
          {item.id.startsWith('persona_') && (
            <TouchableOpacity
              style={styles.actionButton}
              onPress={() => handleDeletePersona(item.id)}
            >
              <Ionicons name="trash-outline" size={20} color="#ff4757" />
            </TouchableOpacity>
          )}
        </View>
      </View>
    );
  }, [uiSettings, selectedPersona, handleSelectPersona, handleEditPersona, handleDeletePersona]);

  const renderCreateForm = () => (
    <View style={[styles.createForm, { backgroundColor: uiSettings.theme.surface }]}>
      <Text style={[styles.formTitle, { color: uiSettings.theme.textColor }]}>
        Create New Persona
      </Text>

      <View style={styles.formField}>
        <Text style={[styles.fieldLabel, { color: uiSettings.theme.textColor }]}>
          Name
        </Text>
        <TextInput
          style={[styles.fieldInput, { color: uiSettings.theme.textColor }]}
          placeholder="Persona name"
          placeholderTextColor={uiSettings.theme.textSecondary}
          value={newPersona.name}
          onChangeText={(text) => setNewPersona(prev => ({ ...prev, name: text }))}
        />
      </View>

      <View style={styles.formField}>
        <Text style={[styles.fieldLabel, { color: uiSettings.theme.textColor }]}>
          Description
        </Text>
        <TextInput
          style={[styles.fieldInput, { color: uiSettings.theme.textColor }]}
          placeholder="Brief description"
          placeholderTextColor={uiSettings.theme.textSecondary}
          value={newPersona.description}
          onChangeText={(text) => setNewPersona(prev => ({ ...prev, description: text }))}
        />
      </View>

      <View style={styles.formField}>
        <Text style={[styles.fieldLabel, { color: uiSettings.theme.textColor }]}>
          System Prompt
        </Text>
        <TextInput
          style={[styles.fieldInput, styles.multilineInput, { color: uiSettings.theme.textColor }]}
          placeholder="System prompt for the AI..."
          placeholderTextColor={uiSettings.theme.textSecondary}
          value={newPersona.systemPrompt}
          onChangeText={(text) => setNewPersona(prev => ({ ...prev, systemPrompt: text }))}
          multiline
        />
      </View>

      <View style={styles.formActions}>
        <TouchableOpacity
          style={[styles.cancelButton, { backgroundColor: uiSettings.theme.surface }]}
          onPress={() => setShowCreateForm(false)}
        >
          <Text style={[styles.cancelButtonText, { color: uiSettings.theme.textColor }]}>
            Cancel
          </Text>
        </TouchableOpacity>
        
        <TouchableOpacity
          style={[styles.createButton, { backgroundColor: uiSettings.theme.primaryColor }]}
          onPress={handleCreatePersona}
          disabled={!newPersona.name.trim()}
        >
          <Text style={styles.createButtonText}>Create</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={[styles.headerTitle, { color: uiSettings.theme.textColor }]}>
          Select Persona
        </Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => setShowCreateForm(true)}
        >
          <Ionicons name="add" size={24} color={uiSettings.theme.primaryColor} />
        </TouchableOpacity>
      </View>

      {/* Personas List */}
      <FlatList
        data={personas}
        renderItem={renderPersona}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        ListFooterComponent={showCreateForm ? renderCreateForm() : null}
      />

      {!showCreateForm && (
        <View style={styles.hintContainer}>
          <Text style={[styles.hintText, { color: uiSettings.theme.textSecondary }]}>
            Tap a persona to select it, or create a custom one
          </Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  addButton: {
    padding: 8,
  },
  listContent: {
    padding: 16,
  },
  personaItem: {
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  personaContent: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  personaAvatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  personaAvatarText: {
    fontSize: 24,
  },
  personaInfo: {
    flex: 1,
  },
  personaName: {
    fontSize: 16,
    fontWeight: '600',
  },
  personaDescription: {
    fontSize: 14,
    marginVertical: 2,
  },
  personaMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  personaCategory: {
    fontSize: 12,
  },
  personaCustom: {
    fontSize: 12,
    fontStyle: 'italic',
  },
  selectedIndicator: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#2ed573',
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 8,
  },
  personaActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionButton: {
    padding: 8,
    marginLeft: 8,
  },
  createForm: {
    padding: 16,
    borderRadius: 12,
    margin: 16,
  },
  formTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
  },
  formField: {
    marginBottom: 12,
  },
  fieldLabel: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  fieldInput: {
    fontSize: 14,
    padding: 12,
    borderRadius: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
  },
  multilineInput: {
    minHeight: 100,
    textAlignVertical: 'top',
  },
  formActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 8,
    marginTop: 16,
  },
  cancelButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  cancelButtonText: {
    fontSize: 14,
  },
  createButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  createButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  hintContainer: {
    padding: 16,
    alignItems: 'center',
  },
  hintText: {
    fontSize: 14,
    textAlign: 'center',
  },
});

export default PersonaSelectionScreen;
