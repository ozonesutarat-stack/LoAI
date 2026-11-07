import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useUISettings } from '../context/UISettingsContext';
import CodeBlockComponent from '../components/CodeBlockComponent';

const CoDebugScreen: React.FC = () => {
  const { settings: uiSettings } = useUISettings();
  const [code, setCode] = useState('');
  const [language, setLanguage] = useState('javascript');
  const [output, setOutput] = useState('');
  const [errors, setErrors] = useState<string[]>([]);
  const [isRunning, setIsRunning] = useState(false);
  const [aiChat, setAiChat] = useState<{ role: 'user' | 'ai'; message: string }[]>([]);
  const [aiInput, setAiInput] = useState('');

  const languages = ['javascript', 'python', 'java', 'c', 'cpp', 'go', 'rust', 'swift'];

  const handleRunCode = useCallback(async () => {
    if (!code.trim()) return;

    setIsRunning(true);
    setOutput('');
    setErrors([]);

    // Simulate code execution
    await new Promise(resolve => setTimeout(resolve, 1500));

    // Simulate output
    setOutput(`Code executed successfully!\n\nThis is a simulated output for ${language} code.\nIn a real implementation, this would show the actual execution result.`);

    setIsRunning(false);
  }, [code, language]);

  const handleSendToAI = useCallback(() => {
    if (!aiInput.trim()) return;

    const userMessage = aiInput;
    setAiInput('');
    setAiChat(prev => [...prev, { role: 'user', message: userMessage }]);

    // Simulate AI response
    setTimeout(() => {
      setAiChat(prev => [
        ...prev,
        { role: 'ai', message: `I understand you want to: ${userMessage}. Here's how you can do it...` }
      ]);
    }, 1000);
  }, [aiInput]);

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Code Editor */}
        <View style={[styles.codeSection, { backgroundColor: uiSettings.theme.surface }]}>
          <View style={styles.codeHeader}>
            <Text style={[styles.codeTitle, { color: uiSettings.theme.textColor }]}>
              Code Editor
            </Text>
            <View style={styles.languageSelector}>
              <Text style={[styles.languageText, { color: uiSettings.theme.textColor }]}>
                {language}
              </Text>
              <Ionicons name="chevron-down" size={16} color={uiSettings.theme.textColor} />
            </View>
          </View>

          <TextInput
            style={[styles.codeInput, { color: uiSettings.theme.textColor }]}
            value={code}
            onChangeText={setCode}
            placeholder={`Enter ${language} code here...`}
            placeholderTextColor={uiSettings.theme.textSecondary}
            multiline
            textAlignVertical="top"
            scrollEnabled={false}
          />

          <View style={styles.codeActions}>
            <TouchableOpacity
              style={[styles.actionButton, { backgroundColor: uiSettings.theme.primaryColor }]}
              onPress={handleRunCode}
              disabled={isRunning || !code.trim()}
            >
              {isRunning ? (
                <ActivityIndicator color="white" size={20} />
              ) : (
                <Ionicons name="play" size={20} color="white" />
              )}
              <Text style={styles.actionButtonText}>Run</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.actionButton, { backgroundColor: '#2ed573' }]}
              onPress={() => setCode('')}
              disabled={!code.trim()}
            >
              <Ionicons name="trash" size={20} color="white" />
              <Text style={styles.actionButtonText}>Clear</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Output */}
        <View style={[styles.outputSection, { backgroundColor: uiSettings.theme.surface }]}>
          <Text style={[styles.sectionTitle, { color: uiSettings.theme.textColor }]}>
            Output
          </Text>
          
          {output ? (
            <View style={[styles.outputContainer, { backgroundColor: 'rgba(0, 0, 0, 0.3)' }]}>
              <Text style={[styles.outputText, { color: uiSettings.theme.textColor }]}>
                {output}
              </Text>
            </View>
          ) : (
            <View style={styles.emptyOutput}>
              <Text style={[styles.emptyOutputText, { color: uiSettings.theme.textSecondary }]}>
                Run code to see output
              </Text>
            </View>
          )}

          {errors.length > 0 && (
            <View style={styles.errorsContainer}>
              <Text style={[styles.errorsTitle, { color: '#ff4757' }]}>Errors:</Text>
              {errors.map((error, index) => (
                <Text key={index} style={[styles.errorText, { color: '#ff4757' }]}>
                  {error}
                </Text>
              ))}
            </View>
          )}
        </View>

        {/* AI Chat */}
        <View style={[styles.aiSection, { backgroundColor: uiSettings.theme.surface }]}>
          <Text style={[styles.sectionTitle, { color: uiSettings.theme.textColor }]}>
            AI Chat
          </Text>
          
          <ScrollView style={styles.aiChatContainer} nestedScrollEnabled>
            {aiChat.length === 0 ? (
              <View style={styles.emptyChat}>
                <Text style={[styles.emptyChatText, { color: uiSettings.theme.textSecondary }]}>
                  Ask AI questions about your code
                </Text>
              </View>
            ) : (
              aiChat.map((msg, index) => (
                <View
                  key={index}
                  style={[
                    styles.aiMessage,
                    msg.role === 'user' ? styles.userMessage : styles.aiMessageBubble,
                  ]}
                >
                  <Text
                    style={[
                      styles.aiMessageText,
                      msg.role === 'user' ? { color: uiSettings.theme.textColor } : { color: '#fff' },
                    ]}
                  >
                    {msg.message}
                  </Text>
                </View>
              ))
            )}
          </ScrollView>

          <View style={styles.aiInputContainer}>
            <TextInput
              style={[styles.aiInput, { color: uiSettings.theme.textColor }]}
              value={aiInput}
              onChangeText={setAiInput}
              placeholder="Ask AI about your code..."
              placeholderTextColor={uiSettings.theme.textSecondary}
              multiline
            />
            <TouchableOpacity
              style={[styles.sendButton, { backgroundColor: uiSettings.theme.primaryColor }]}
              onPress={handleSendToAI}
              disabled={!aiInput.trim()}
            >
              <Ionicons name="send" size={20} color="white" />
            </TouchableOpacity>
          </View>
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
    paddingBottom: 24,
  },
  codeSection: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  codeHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  codeTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  languageSelector: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  languageText: {
    fontSize: 14,
    marginRight: 4,
  },
  codeInput: {
    fontSize: 14,
    minHeight: 200,
    padding: 12,
    borderRadius: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
    fontFamily: 'monospace',
    lineHeight: 20,
  },
  codeActions: {
    flexDirection: 'row',
    marginTop: 12,
    gap: 8,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  actionButtonText: {
    color: 'white',
    fontSize: 14,
    marginLeft: 4,
    fontWeight: '600',
  },
  outputSection: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  outputContainer: {
    borderRadius: 8,
    padding: 12,
    minHeight: 100,
  },
  outputText: {
    fontSize: 14,
    fontFamily: 'monospace',
    lineHeight: 20,
    whiteSpace: 'pre-wrap',
  },
  emptyOutput: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 100,
  },
  emptyOutputText: {
    fontSize: 14,
  },
  errorsContainer: {
    marginTop: 12,
    padding: 12,
    backgroundColor: 'rgba(255, 0, 0, 0.1)',
    borderRadius: 8,
  },
  errorsTitle: {
    fontWeight: '600',
    marginBottom: 4,
  },
  errorText: {
    fontSize: 14,
  },
  aiSection: {
    borderRadius: 12,
    padding: 16,
  },
  aiChatContainer: {
    maxHeight: 200,
    marginBottom: 12,
  },
  emptyChat: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 200,
  },
  emptyChatText: {
    fontSize: 14,
  },
  aiMessage: {
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
    maxWidth: '80%',
  },
  userMessage: {
    alignSelf: 'flex-end',
    backgroundColor: 'rgba(108, 92, 231, 0.3)',
  },
  aiMessageBubble: {
    alignSelf: 'flex-start',
    backgroundColor: 'rgba(108, 92, 231, 0.5)',
  },
  aiMessageText: {
    fontSize: 14,
    lineHeight: 20,
  },
  aiInputContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
    borderRadius: 24,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  aiInput: {
    flex: 1,
    fontSize: 14,
    paddingVertical: 8,
    maxHeight: 100,
  },
  sendButton: {
    padding: 8,
    borderRadius: 20,
    marginLeft: 8,
  },
});

export default CoDebugScreen;
