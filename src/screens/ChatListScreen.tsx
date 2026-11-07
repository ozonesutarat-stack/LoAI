import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
  RefreshControl,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useChat } from '../context/ChatContext';
import { useUISettings } from '../context/UISettingsContext';
import { useModels } from '../context/ModelContext';
import { ChatSession } from '../types';
import { MESSAGE_LIMITS } from '../constants';

const ChatListScreen: React.FC<{ navigation?: any }> = ({ navigation }) => {
  const { sessions, currentSession, switchSession, deleteSession, createSession } = useChat();
  const { settings: uiSettings } = useUISettings();
  const { models } = useModels();

  const [refreshing, setRefreshing] = useState(false);
  const [showMore, setShowMore] = useState(false);

  const handleNewChat = useCallback(async () => {
    if (models.length === 0) {
      Alert.alert('No models available', 'Please download a model first');
      return;
    }

    const newSession = await createSession(models[0].id);
    navigation.navigate('Chat', { sessionId: newSession.id });
  }, [models, createSession, navigation]);

  const handleSwitchSession = useCallback((session: ChatSession) => {
    switchSession(session.id);
    navigation.navigate('Chat', { sessionId: session.id });
  }, [switchSession, navigation]);

  const handleDeleteSession = useCallback((sessionId: string) => {
    Alert.alert(
      'Delete Chat',
      'Are you sure you want to delete this chat?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => deleteSession(sessionId) },
      ]
    );
  }, [deleteSession]);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    // In a real implementation, this would refresh the sessions
    setTimeout(() => setRefreshing(false), 1000);
  }, []);

  const handleShowMore = useCallback(() => {
    setShowMore(!showMore);
  }, [showMore]);

  const renderSession = useCallback(({ item }: { item: ChatSession }) => {
    const lastMessage = item.messages.length > 0 ? item.messages[item.messages.length - 1] : null;
    const model = models.find(m => m.id === item.modelId);

    return (
      <TouchableOpacity
        style={[styles.sessionItem, { backgroundColor: uiSettings.theme.surface }]}
        onPress={() => handleSwitchSession(item)}
      >
        <View style={styles.sessionContent}>
          <View style={styles.sessionInfo}>
            <Text
              style={[styles.sessionName, { color: uiSettings.theme.textColor }]}
              numberOfLines={1}
            >
              {item.name}
            </Text>
            {lastMessage && (
              <Text
                style={[styles.sessionPreview, { color: uiSettings.theme.textSecondary }]}
                numberOfLines={1}
              >
                {lastMessage.role === 'user' ? 'You: ' : 'AI: '}
                {lastMessage.content.length > 50
                  ? `${lastMessage.content.substring(0, 50)}...`
                  : lastMessage.content}
              </Text>
            )}
          </View>
          
          <View style={styles.sessionMeta}>
            {model && (
              <Text style={[styles.modelName, { color: uiSettings.theme.textSecondary }]}>
                {model.name}
              </Text>
            )}
            <Text style={[styles.sessionTime, { color: uiSettings.theme.textSecondary }]}>
              {new Date(item.updatedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
            </Text>
          </View>
        </View>

        <View style={styles.sessionActions}>
          <TouchableOpacity
            style={styles.actionButton}
            onPress={(e) => {
              e.stopPropagation();
              handleDeleteSession(item.id);
            }}
          >
            <Ionicons name="trash-outline" size={20} color={uiSettings.theme.textSecondary} />
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    );
  }, [models, uiSettings, handleSwitchSession, handleDeleteSession]);

  const visibleSessions = showMore ? sessions : sessions.slice(0, MESSAGE_LIMITS.INITIAL_DISPLAY);

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={[styles.headerTitle, { color: uiSettings.theme.textColor }]}>
          Chats
        </Text>
        <TouchableOpacity
          style={styles.newChatButton}
          onPress={handleNewChat}
        >
          <Ionicons name="add" size={24} color={uiSettings.theme.primaryColor} />
        </TouchableOpacity>
      </View>

      {/* Sessions List */}
      {sessions.length === 0 ? (
        <View style={styles.emptyState}>
          <Ionicons name="chatbubble-ellipses-outline" size={64} color={uiSettings.theme.textSecondary} />
          <Text style={[styles.emptyStateText, { color: uiSettings.theme.textSecondary }]}>
            No chats yet
          </Text>
          <Text style={[styles.emptyStateSubtext, { color: uiSettings.theme.textSecondary }]}>
            Start a new chat to begin
          </Text>
          <TouchableOpacity
            style={[styles.startButton, { backgroundColor: uiSettings.theme.primaryColor }]}
            onPress={handleNewChat}
          >
            <Text style={styles.startButtonText}>Start Chat</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={visibleSessions}
          renderItem={renderSession}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={handleRefresh}
              tintColor={uiSettings.theme.primaryColor}
            />
          }
          ListFooterComponent={sessions.length > MESSAGE_LIMITS.INITIAL_DISPLAY && (
            <TouchableOpacity
              style={styles.showMoreButton}
              onPress={handleShowMore}
            >
              <Text style={[styles.showMoreText, { color: uiSettings.theme.primaryColor }]}>
                {showMore ? 'Show Less' : 'Show More'}
              </Text>
            </TouchableOpacity>
          )}
        />
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
  newChatButton: {
    padding: 8,
  },
  listContent: {
    padding: 16,
  },
  sessionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  sessionContent: {
    flex: 1,
  },
  sessionInfo: {
    marginBottom: 4,
  },
  sessionName: {
    fontSize: 16,
    fontWeight: '600',
  },
  sessionPreview: {
    fontSize: 14,
    marginTop: 2,
  },
  sessionMeta: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  modelName: {
    fontSize: 12,
    marginRight: 8,
  },
  sessionTime: {
    fontSize: 12,
  },
  sessionActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionButton: {
    padding: 8,
    marginLeft: 8,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyStateText: {
    fontSize: 18,
    marginTop: 16,
    marginBottom: 8,
  },
  emptyStateSubtext: {
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 24,
  },
  startButton: {
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 24,
  },
  startButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  showMoreButton: {
    alignItems: 'center',
    padding: 16,
  },
  showMoreText: {
    fontSize: 14,
    fontWeight: '600',
  },
});

export default ChatListScreen;
