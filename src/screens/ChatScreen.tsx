import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Image,
  Alert,
  ActivityIndicator,
  FlatList,
  TouchableWithoutFeedback,
  Keyboard,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import * as DocumentPicker from 'expo-document-picker';
import * as FileSystem from 'expo-file-system';
import { useChat } from '../context/ChatContext';
import { useModels } from '../context/ModelContext';
import { usePersonas } from '../context/PersonaContext';
import { useUISettings } from '../context/UISettingsContext';
import { useTools } from '../context/ToolContext';
import { Message, Attachment, CodeBlock } from '../types';
import { FILE_ICONS, MESSAGE_LIMITS } from '../constants';
import CodeBlockComponent from '../components/CodeBlockComponent';
import ChatBubble from '../components/ChatBubble';
import ToolSelector from '../components/ToolSelector';

const ChatScreen: React.FC<{ route?: any; navigation?: any }> = ({ route, navigation }) => {
  const { sessionId } = route?.params || {};
  const {
    currentSession,
    messages,
    sendMessage,
    isLoading,
    error,
    createSession,
    settings,
    visibleMessageCount,
    loadMoreMessages,
    hasMoreMessages,
  } = useChat();

  const { models, getModel } = useModels();
  const { selectedPersona } = usePersonas();
  const { settings: uiSettings } = useUISettings();
  const { enabledTools, webSearchTool, knowledgeBaseTool } = useTools();

  const [inputText, setInputText] = useState('');
  const [attachments, setAttachments] = useState<Attachment[]>([]);
  const [isSending, setIsSending] = useState(false);
  const [showToolSelector, setShowToolSelector] = useState(false);

  const scrollViewRef = useRef<ScrollView>(null);
  const flatListRef = useRef<FlatList>(null);

  // Initialize session if needed
  useEffect(() => {
    if (!currentSession && models.length > 0) {
      createSession(models[0].id);
    }
  }, [currentSession, models, createSession]);

  // Load specific session if provided
  useEffect(() => {
    if (sessionId && currentSession?.id !== sessionId) {
      // Switch to the specified session
      // In a real implementation, this would be handled by the context
    }
  }, [sessionId, currentSession]);

  // Scroll to bottom when messages change
  useEffect(() => {
    if (messages.length > 0) {
      setTimeout(() => {
        scrollViewRef.current?.scrollToEnd({ animated: true });
      }, 100);
    }
  }, [messages]);

  // Handle error
  useEffect(() => {
    if (error) {
      Alert.alert('Error', error);
    }
  }, [error]);

  const handleSend = useCallback(async () => {
    if (!inputText.trim() && attachments.length === 0) return;

    setIsSending(true);
    Keyboard.dismiss();

    try {
      await sendMessage(inputText, attachments);
      setInputText('');
      setAttachments([]);
      setShowToolSelector(false);
    } catch (err) {
      console.error('Failed to send message:', err);
    } finally {
      setIsSending(false);
    }
  }, [inputText, attachments, sendMessage]);

  const handleAddAttachment = useCallback(async (type: 'image' | 'document' | 'camera') => {
    try {
      let result;

      if (type === 'camera') {
        const { status } = await ImagePicker.requestCameraPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Permission required', 'Camera permission is required to take photos');
          return;
        }
        result = await ImagePicker.launchCameraAsync({
          mediaTypes: ImagePicker.MediaTypeOptions.Images,
          allowsMultipleSelection: false,
          quality: 0.8,
        });
      } else if (type === 'image') {
        const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Permission required', 'Photo library permission is required');
          return;
        }
        result = await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ImagePicker.MediaTypeOptions.Images,
          allowsMultipleSelection: true,
          quality: 0.8,
        });
      } else {
        result = await DocumentPicker.getDocumentAsync({
          type: ['application/pdf', 'text/plain', 'text/markdown', 'application/json'],
          multiple: true,
        });
      }

      if (!result.canceled && result.assets) {
        const newAttachments: Attachment[] = await Promise.all(
          result.assets.map(async (asset) => {
            const fileInfo = await FileSystem.getInfoAsync(asset.uri);
            const fileExt = asset.name?.split('.').pop()?.toLowerCase() || 'file';
            
            return {
              id: `att_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
              type: fileExt === 'pdf' ? 'pdf' : 
                     ['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(fileExt) ? 'image' : 'file',
              uri: asset.uri,
              name: asset.name || `file_${Date.now()}`,
              size: fileInfo.size || 0,
              mimeType: asset.mimeType || 'application/octet-stream',
            };
          })
        );

        setAttachments(prev => [...prev, ...newAttachments]);
      }
    } catch (error) {
      console.error('Failed to add attachment:', error);
      Alert.alert('Error', 'Failed to add attachment');
    }
  }, []);

  const handleRemoveAttachment = useCallback((attachmentId: string) => {
    setAttachments(prev => prev.filter(att => att.id !== attachmentId));
  }, []);

  const handleToolSelect = useCallback((toolId: string) => {
    // In a real implementation, this would trigger the tool
    // For now, just add a message indicating the tool was used
    setInputText(prev => `${prev}[Tool: ${toolId}] `);
    setShowToolSelector(false);
  }, []);

  const handleLoadMore = useCallback(() => {
    if (hasMoreMessages) {
      loadMoreMessages();
    }
  }, [hasMoreMessages, loadMoreMessages]);

  const renderMessage = useCallback(({ item }: { item: Message }) => {
    const isUser = item.role === 'user';
    const showAvatar = true;
    const avatar = isUser ? '👤' : (selectedPersona?.avatar || '🤖');

    return (
      <View style={styles.messageContainer}>
        {showAvatar && !isUser && (
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{avatar}</Text>
          </View>
        )}
        
        <View style={[styles.messageContent, isUser ? styles.userMessage : styles.assistantMessage]}>
          {item.attachments && item.attachments.length > 0 && (
            <View style={styles.attachmentsContainer}>
              {item.attachments.map((att) => (
                <View key={att.id} style={styles.attachment}>
                  <Text style={styles.attachmentIcon}>{FILE_ICONS[att.type] || '📎'}</Text>
                  <Text style={styles.attachmentName}>{att.name}</Text>
                </View>
              ))}
            </View>
          )}

          {item.codeBlock ? (
            <CodeBlockComponent
              code={item.codeBlock.code}
              language={item.codeBlock.language}
              fileName={item.codeBlock.fileName}
              onCopy={() => {}}
              onDownload={() => {}}
              onSendToDebug={() => {}}
            />
          ) : (
            <ChatBubble
              text={item.content}
              isUser={isUser}
              timestamp={item.timestamp}
              backgroundColor={isUser ? uiSettings.theme.primaryColor : uiSettings.theme.bubbleColor}
              textColor={isUser ? '#fff' : uiSettings.theme.textColor}
              gradientColors={uiSettings.theme.gradientEnabled ? uiSettings.theme.gradientColors : undefined}
              blurIntensity={uiSettings.blur.intensity}
            />
          )}

          {item.toolCalls && item.toolCalls.length > 0 && (
            <View style={styles.toolCallsContainer}>
              {item.toolCalls.map((toolCall) => (
                <View key={toolCall.id} style={styles.toolCall}>
                  <Text style={styles.toolCallName}>{toolCall.name}</Text>
                  <Text style={styles.toolCallArgs}>{JSON.stringify(toolCall.arguments)}</Text>
                </View>
              ))}
            </View>
          )}

          {item.toolResults && item.toolResults.length > 0 && (
            <View style={styles.toolResultsContainer}>
              {item.toolResults.map((result) => (
                <View key={result.id} style={[styles.toolResult, result.isError && styles.toolResultError]}>
                  <Text style={styles.toolResultText}>{result.content}</Text>
                </View>
              ))}
            </View>
          )}
        </View>

        {showAvatar && isUser && (
          <View style={[styles.avatar, styles.userAvatar]}>
            <Text style={styles.avatarText}>👤</Text>
          </View>
        )}
      </View>
    );
  }, [selectedPersona, uiSettings]);

  const renderAttachmentPreview = useCallback((attachment: Attachment) => {
    if (attachment.type === 'image') {
      return (
        <View style={styles.attachmentPreview} key={attachment.id}>
          <Image
            source={{ uri: attachment.uri }}
            style={styles.attachmentImage}
            resizeMode="cover"
          />
          <TouchableOpacity
            style={styles.removeAttachmentButton}
            onPress={() => handleRemoveAttachment(attachment.id)}
          >
            <Ionicons name="close-circle" size={20} color="white" />
          </TouchableOpacity>
          <Text style={styles.attachmentPreviewName}>{attachment.name}</Text>
        </View>
      );
    }

    return (
      <View style={styles.attachmentPreview} key={attachment.id}>
        <Text style={styles.attachmentPreviewIcon}>{FILE_ICONS[attachment.type] || '📎'}</Text>
        <Text style={styles.attachmentPreviewName}>{attachment.name}</Text>
        <TouchableOpacity
          style={styles.removeAttachmentButton}
          onPress={() => handleRemoveAttachment(attachment.id)}
        >
          <Ionicons name="close-circle" size={20} color="white" />
        </TouchableOpacity>
      </View>
    );
  }, [handleRemoveAttachment]);

  const getInputContainerStyle = useCallback(() => {
    return {
      ...styles.inputContainer,
      backgroundColor: uiSettings.theme.surface,
      borderColor: uiSettings.theme.edge.color,
      borderWidth: uiSettings.theme.edge.thickness,
      opacity: uiSettings.transparency,
    };
  }, [uiSettings]);

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoidingView}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 80 : 0}
      >
        <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
          <View style={styles.content}>
            {/* Header */}
            <View style={styles.header}>
              <View style={styles.headerLeft}>
                <Text style={[styles.headerTitle, { color: uiSettings.theme.textColor }]}>
                  {currentSession?.name || 'New Chat'}
                </Text>
                {currentSession?.modelId && (
                  <View style={styles.modelBadge}>
                    <Text style={styles.modelBadgeText}>
                      {getModel(currentSession.modelId)?.name || currentSession.modelId}
                    </Text>
                  </View>
                )}
              </View>
              <View style={styles.headerRight}>
                {enabledTools.length > 0 && (
                  <TouchableOpacity
                    style={styles.toolButton}
                    onPress={() => setShowToolSelector(!showToolSelector)}
                  >
                    <Ionicons name="apps" size={24} color={uiSettings.theme.textColor} />
                  </TouchableOpacity>
                )}
              </View>
            </View>

            {/* Messages */}
            <View style={styles.messagesContainer}>
              {messages.length === 0 ? (
                <View style={styles.emptyState}>
                  <Text style={[styles.emptyStateText, { color: uiSettings.theme.textSecondary }]}>
                    Start a conversation with LoAI
                  </Text>
                  <Text style={[styles.emptyStateSubtext, { color: uiSettings.theme.textSecondary }]}>
                    {selectedPersona?.description || 'Ask me anything!'}
                  </Text>
                </View>
              ) : (
                <FlatList
                  ref={flatListRef}
                  data={messages.slice(0, visibleMessageCount)}
                  renderItem={renderMessage}
                  keyExtractor={(item) => item.id}
                  contentContainerStyle={styles.messagesList}
                  onEndReached={handleLoadMore}
                  onEndReachedThreshold={0.5}
                  ListFooterComponent={hasMoreMessages ? (
                    <View style={styles.loadMoreContainer}>
                      <ActivityIndicator color={uiSettings.theme.primaryColor} />
                      <Text style={[styles.loadMoreText, { color: uiSettings.theme.textSecondary }]}>
                        Load more...
                      </Text>
                    </View>
                  ) : null}
                  inverted
                />
              )}
            </View>

            {/* Tool Selector */}
            {showToolSelector && (
              <ToolSelector
                tools={enabledTools}
                onSelect={handleToolSelect}
                onClose={() => setShowToolSelector(false)}
                style={styles.toolSelector}
              />
            )}

            {/* Input */}
            <View style={getInputContainerStyle()}>
              {/* Attachment Previews */}
              {attachments.length > 0 && (
                <ScrollView
                  horizontal
                  showsHorizontalScrollIndicator={false}
                  style={styles.attachmentsPreview}
                >
                  {attachments.map(renderAttachmentPreview)}
                </ScrollView>
              )}

              <View style={styles.inputRow}>
                <TouchableOpacity
                  style={styles.attachmentButton}
                  onPress={() => setShowToolSelector(!showToolSelector)}
                >
                  <Ionicons name="apps" size={24} color={uiSettings.theme.textColor} />
                </TouchableOpacity>

                <TextInput
                  style={[styles.input, { color: uiSettings.theme.textColor }]}
                  value={inputText}
                  onChangeText={setInputText}
                  placeholder="Type a message..."
                  placeholderTextColor={uiSettings.theme.textSecondary}
                  multiline
                  blurOnSubmit={false}
                  onSubmitEditing={handleSend}
                />

                <View style={styles.inputActions}>
                  {inputText.trim() === '' && attachments.length === 0 ? (
                    <>
                      <TouchableOpacity
                        style={styles.actionButton}
                        onPress={() => handleAddAttachment('camera')}
                      >
                        <Ionicons name="camera" size={22} color={uiSettings.theme.textColor} />
                      </TouchableOpacity>
                      <TouchableOpacity
                        style={styles.actionButton}
                        onPress={() => handleAddAttachment('image')}
                      >
                        <Ionicons name="image" size={22} color={uiSettings.theme.textColor} />
                      </TouchableOpacity>
                      <TouchableOpacity
                        style={styles.actionButton}
                        onPress={() => handleAddAttachment('document')}
                      >
                        <Ionicons name="document" size={22} color={uiSettings.theme.textColor} />
                      </TouchableOpacity>
                    </>
                  ) : (
                    <TouchableOpacity
                      style={[styles.sendButton, { backgroundColor: uiSettings.theme.primaryColor }]}
                      onPress={handleSend}
                      disabled={isSending || isLoading}
                    >
                      {isSending || isLoading ? (
                        <ActivityIndicator color="white" size={20} />
                      ) : (
                        <Ionicons name="send" size={20} color="white" />
                      )}
                    </TouchableOpacity>
                  )}
                </View>
              </View>
            </View>
          </View>
        </TouchableWithoutFeedback>
      </KeyboardAvoidingView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  content: {
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
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginRight: 8,
  },
  modelBadge: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  modelBadgeText: {
    fontSize: 12,
    color: '#fff',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  toolButton: {
    padding: 8,
  },
  messagesContainer: {
    flex: 1,
    paddingHorizontal: 16,
  },
  messagesList: {
    paddingTop: 16,
    paddingBottom: 16,
  },
  messageContainer: {
    flexDirection: 'row',
    marginBottom: 16,
    alignItems: 'flex-start',
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(108, 92, 231, 0.3)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 8,
  },
  userAvatar: {
    marginRight: 0,
    marginLeft: 8,
  },
  avatarText: {
    fontSize: 18,
  },
  messageContent: {
    flex: 1,
    maxWidth: '80%',
  },
  userMessage: {
    alignItems: 'flex-end',
  },
  assistantMessage: {
    alignItems: 'flex-start',
  },
  attachmentsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 8,
  },
  attachment: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    padding: 8,
    borderRadius: 8,
    marginRight: 8,
    marginBottom: 8,
  },
  attachmentIcon: {
    fontSize: 16,
    marginRight: 4,
  },
  attachmentName: {
    fontSize: 14,
    color: '#fff',
    maxWidth: 150,
  },
  toolCallsContainer: {
    marginTop: 8,
    backgroundColor: 'rgba(0, 128, 255, 0.1)',
    padding: 8,
    borderRadius: 8,
  },
  toolCall: {
    marginBottom: 4,
  },
  toolCallName: {
    fontWeight: '600',
    color: '#0080ff',
    marginBottom: 2,
  },
  toolCallArgs: {
    fontSize: 12,
    color: '#888',
  },
  toolResultsContainer: {
    marginTop: 8,
  },
  toolResult: {
    backgroundColor: 'rgba(0, 255, 0, 0.1)',
    padding: 8,
    borderRadius: 8,
    marginBottom: 4,
  },
  toolResultError: {
    backgroundColor: 'rgba(255, 0, 0, 0.1)',
  },
  toolResultText: {
    fontSize: 14,
    color: '#fff',
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyStateText: {
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 8,
  },
  emptyStateSubtext: {
    fontSize: 14,
    textAlign: 'center',
  },
  inputContainer: {
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.1)',
  },
  attachmentsPreview: {
    marginBottom: 8,
    maxHeight: 80,
  },
  attachmentPreview: {
    position: 'relative',
    marginRight: 8,
  },
  attachmentImage: {
    width: 60,
    height: 60,
    borderRadius: 8,
  },
  attachmentPreviewIcon: {
    fontSize: 40,
  },
  attachmentPreviewName: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    color: 'white',
    fontSize: 10,
    padding: 2,
    borderBottomLeftRadius: 8,
    borderBottomRightRadius: 8,
  },
  removeAttachmentButton: {
    position: 'absolute',
    top: 0,
    right: 0,
    backgroundColor: 'rgba(255, 0, 0, 0.5)',
    borderRadius: 10,
    width: 20,
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderRadius: 24,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  attachmentButton: {
    padding: 8,
  },
  input: {
    flex: 1,
    fontSize: 16,
    paddingVertical: 8,
    paddingHorizontal: 8,
    maxHeight: 120,
  },
  inputActions: {
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: 8,
  },
  actionButton: {
    padding: 8,
    marginLeft: 4,
  },
  sendButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 8,
  },
  loadMoreContainer: {
    alignItems: 'center',
    padding: 16,
  },
  loadMoreText: {
    marginTop: 8,
    fontSize: 14,
  },
  toolSelector: {
    position: 'absolute',
    bottom: 100,
    left: 16,
    right: 16,
    zIndex: 1000,
  },
});

export default ChatScreen;
