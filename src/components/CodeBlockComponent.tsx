import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Clipboard,
  Alert,
  Share,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import SyntaxHighlighter from 'react-native-syntax-highlighter';
import { atomOneDark } from 'react-native-syntax-highlighter/styles';
import { useUISettings } from '../context/UISettingsContext';

interface CodeBlockComponentProps {
  code: string;
  language: string;
  fileName?: string;
  onCopy?: () => void;
  onDownload?: () => void;
  onSendToDebug?: () => void;
}

const CodeBlockComponent: React.FC<CodeBlockComponentProps> = ({
  code,
  language,
  fileName,
  onCopy: externalOnCopy,
  onDownload: externalOnDownload,
  onSendToDebug: externalOnSendToDebug,
}) => {
  const { settings: uiSettings } = useUISettings();
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(async () => {
    try {
      await Clipboard.setStringAsync(code);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
      externalOnCopy?.();
    } catch (error) {
      console.error('Failed to copy code:', error);
      Alert.alert('Error', 'Failed to copy code');
    }
  }, [code, externalOnCopy]);

  const handleDownload = useCallback(async () => {
    try {
      // In a real implementation, this would save the code to a file
      Alert.alert('Download', 'Code download feature coming soon!');
      externalOnDownload?.();
    } catch (error) {
      console.error('Failed to download code:', error);
      Alert.alert('Error', 'Failed to download code');
    }
  }, [externalOnDownload]);

  const handleSendToDebug = useCallback(() => {
    externalOnSendToDebug?.();
  }, [externalOnSendToDebug]);

  const handleShare = useCallback(async () => {
    try {
      await Share.share({
        message: code,
        title: fileName || 'Code',
      });
    } catch (error) {
      console.error('Failed to share code:', error);
    }
  }, [code, fileName]);

  const getLanguage = useCallback(() => {
    // Map common language names to SyntaxHighlighter supported languages
    const langMap: Record<string, string> = {
      'javascript': 'javascript',
      'js': 'javascript',
      'typescript': 'typescript',
      'ts': 'typescript',
      'python': 'python',
      'py': 'python',
      'java': 'java',
      'c': 'c',
      'cpp': 'cpp',
      'csharp': 'csharp',
      'c#': 'csharp',
      'go': 'go',
      'rust': 'rust',
      'rs': 'rust',
      'swift': 'swift',
      'kotlin': 'kotlin',
      'php': 'php',
      'ruby': 'ruby',
      'bash': 'bash',
      'sh': 'bash',
      'sql': 'sql',
      'html': 'html',
      'css': 'css',
      'json': 'json',
      'xml': 'xml',
      'yaml': 'yaml',
      'yml': 'yaml',
      'markdown': 'markdown',
      'md': 'markdown',
    };

    return langMap[language.toLowerCase()] || language.toLowerCase();
  }, [language]);

  return (
    <View
      style={[
        styles.container,
        {
          backgroundColor: uiSettings.theme.surface,
          borderColor: uiSettings.theme.edge.color,
          borderWidth: uiSettings.theme.edge.thickness,
        },
      ]}
    >
      {/* Header with file name and actions */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          {fileName && (
            <View style={[styles.fileNameContainer, { backgroundColor: uiSettings.theme.primaryColor }]}>
              <Text style={styles.fileName}>{fileName}</Text>
            </View>
          )}
          <Text style={[styles.language, { color: uiSettings.theme.textSecondary }]}>
            {language}
          </Text>
        </View>
        
        <View style={styles.headerRight}>
          <TouchableOpacity
            style={styles.actionButton}
            onPress={handleCopy}
            disabled={copied}
          >
            <Ionicons
              name={copied ? 'checkmark' : 'copy-outline'}
              size={18}
              color={copied ? '#2ed573' : uiSettings.theme.textColor}
            />
            <Text style={[styles.actionText, { color: copied ? '#2ed573' : uiSettings.theme.textColor }]}>
              {copied ? 'Copied!' : 'Copy'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.actionButton} onPress={handleDownload}>
            <Ionicons name="download-outline" size={18} color={uiSettings.theme.textColor} />
            <Text style={[styles.actionText, { color: uiSettings.theme.textColor }]}>Download</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.actionButton} onPress={handleSendToDebug}>
            <Ionicons name="code-working-outline" size={18} color={uiSettings.theme.textColor} />
            <Text style={[styles.actionText, { color: uiSettings.theme.textColor }]}>Debug</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.actionButton} onPress={handleShare}>
            <Ionicons name="share-social-outline" size={18} color={uiSettings.theme.textColor} />
            <Text style={[styles.actionText, { color: uiSettings.theme.textColor }]}>Share</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Code */}
      <View style={styles.codeContainer}>
        <SyntaxHighlighter
          language={getLanguage()}
          style={atomOneDark}
          customStyle={styles.code}
          showsVerticalScrollIndicator={false}
          showsHorizontalScrollIndicator={false}
        >
          {code}
        </SyntaxHighlighter>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 8,
    marginVertical: 8,
    overflow: 'hidden',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  fileNameContainer: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 8,
  },
  fileName: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
  language: {
    fontSize: 12,
    fontStyle: 'italic',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 4,
    marginLeft: 8,
    borderRadius: 4,
  },
  actionText: {
    fontSize: 12,
    marginLeft: 4,
  },
  codeContainer: {
    padding: 12,
    maxHeight: 400,
  },
  code: {
    fontSize: 14,
    lineHeight: 20,
    borderRadius: 4,
  },
});

export default CodeBlockComponent;
