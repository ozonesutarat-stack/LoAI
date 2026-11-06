import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  code,
  image,
  file,
  toolResult,
  system,
  error,
}

enum MessageSender {
  user,
  bot,
  system,
}

class ChatMessage {
  final String id;
  final String conversationId;
  final MessageSender sender;
  final MessageType type;
  final String content;
  final String? codeLanguage;
  final String? filePath;
  final String? fileName;
  final String? fileType;
  final String? toolName;
  final Map<String, dynamic>? toolData;
  final DateTime timestamp;
  final bool isEdited;
  final bool isDeleted;
  final int tokenCount;
  final Duration? processingTime;
  final String? modelUsed;
  final List<String>? references;
  
  ChatMessage({
    String? id,
    required this.conversationId,
    required this.sender,
    required this.type,
    required this.content,
    this.codeLanguage,
    this.filePath,
    this.fileName,
    this.fileType,
    this.toolName,
    this.toolData,
    DateTime? timestamp,
    this.isEdited = false,
    this.isDeleted = false,
    this.tokenCount = 0,
    this.processingTime,
    this.modelUsed,
    this.references,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();
  
  // Copy with method for immutability
  ChatMessage copyWith({
    String? id,
    String? conversationId,
    MessageSender? sender,
    MessageType? type,
    String? content,
    String? codeLanguage,
    String? filePath,
    String? fileName,
    String? fileType,
    String? toolName,
    Map<String, dynamic>? toolData,
    DateTime? timestamp,
    bool? isEdited,
    bool? isDeleted,
    int? tokenCount,
    Duration? processingTime,
    String? modelUsed,
    List<String>? references,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      toolName: toolName ?? this.toolName,
      toolData: toolData ?? this.toolData,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      tokenCount: tokenCount ?? this.tokenCount,
      processingTime: processingTime ?? this.processingTime,
      modelUsed: modelUsed ?? this.modelUsed,
      references: references ?? this.references,
    );
  }
  
  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'sender': sender.index,
      'type': type.index,
      'content': content,
      'codeLanguage': codeLanguage,
      'filePath': filePath,
      'fileName': fileName,
      'fileType': fileType,
      'toolName': toolName,
      'toolData': toolData,
      'timestamp': timestamp.toIso8601String(),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'tokenCount': tokenCount,
      'processingTime': processingTime?.inMilliseconds,
      'modelUsed': modelUsed,
      'references': references,
    };
  }
  
  // Create from map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? const Uuid().v4(),
      conversationId: map['conversationId'] ?? '',
      sender: MessageSender.values[map['sender'] ?? 0],
      type: MessageType.values[map['type'] ?? 0],
      content: map['content'] ?? '',
      codeLanguage: map['codeLanguage'],
      filePath: map['filePath'],
      fileName: map['fileName'],
      fileType: map['fileType'],
      toolName: map['toolName'],
      toolData: map['toolData'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      tokenCount: map['tokenCount'] ?? 0,
      processingTime: map['processingTime'] != null 
          ? Duration(milliseconds: map['processingTime']) 
          : null,
      modelUsed: map['modelUsed'],
      references: List<String>.from(map['references'] ?? []),
    );
  }
  
  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, type: $type, content: ${content.length > 50 ? content.substring(0, 50) + '...' : content})';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

// Code block specific class
class CodeBlock {
  final String code;
  final String language;
  final String? fileName;
  final int lineCount;
  
  CodeBlock({
    required this.code,
    required this.language,
    this.fileName,
    int? lineCount,
  }) : lineCount = lineCount ?? code.split('\n').length;
  
  // Syntax highlighting support
  static const Map<String, String> languageDisplayNames = {
    'python': 'Python',
    'javascript': 'JavaScript',
    'java': 'Java',
    'cpp': 'C++',
    'c': 'C',
    'dart': 'Dart',
    'go': 'Go',
    'rust': 'Rust',
    'php': 'PHP',
    'ruby': 'Ruby',
    'swift': 'Swift',
    'kotlin': 'Kotlin',
    'typescript': 'TypeScript',
    'bash': 'Bash',
    'sql': 'SQL',
    'html': 'HTML',
    'css': 'CSS',
  };
  
  static String getDisplayName(String language) {
    return languageDisplayNames[language.toLowerCase()] ?? language;
  }
  
  // Common file extensions to language mapping
  static String detectLanguageFromExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    const extensionMap = {
      'py': 'python',
      'js': 'javascript',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'dart': 'dart',
      'go': 'go',
      'rs': 'rust',
      'php': 'php',
      'rb': 'ruby',
      'swift': 'swift',
      'kt': 'kotlin',
      'ts': 'typescript',
      'sh': 'bash',
      'bash': 'bash',
      'sql': 'sql',
      'html': 'html',
      'css': 'css',
    };
    return extensionMap[extension] ?? 'text';
  }
}
