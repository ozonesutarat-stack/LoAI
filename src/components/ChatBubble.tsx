import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

interface ChatBubbleProps {
  text: string;
  isUser: boolean;
  timestamp: Date;
  backgroundColor?: string;
  textColor?: string;
  gradientColors?: string[];
  blurIntensity?: number;
}

const ChatBubble: React.FC<ChatBubbleProps> = ({
  text,
  isUser,
  timestamp,
  backgroundColor = '#6c5ce7',
  textColor = '#fff',
  gradientColors,
  blurIntensity = 0,
}) => {
  const formatTime = (date: Date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <View style={[styles.container, isUser ? styles.userContainer : styles.assistantContainer]}>
      {gradientColors && gradientColors.length > 0 ? (
        <LinearGradient
          colors={gradientColors}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.bubble, { borderRadius: isUser ? 18 : 18 }]}
        >
          <Text style={[styles.text, { color: textColor }]}>{text}</Text>
          <Text style={[styles.time, { color: textColor }]}>{formatTime(timestamp)}</Text>
        </LinearGradient>
      ) : (
        <View
          style={[
            styles.bubble,
            {
              backgroundColor,
              borderRadius: isUser ? 18 : 18,
            },
          ]}
        >
          <Text style={[styles.text, { color: textColor }]}>{text}</Text>
          <Text style={[styles.time, { color: textColor }]}>{formatTime(timestamp)}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    maxWidth: '100%',
  },
  userContainer: {
    alignItems: 'flex-end',
  },
  assistantContainer: {
    alignItems: 'flex-start',
  },
  bubble: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    maxWidth: '100%',
  },
  text: {
    fontSize: 16,
    lineHeight: 22,
  },
  time: {
    fontSize: 10,
    marginTop: 4,
    opacity: 0.7,
  },
});

export default ChatBubble;
