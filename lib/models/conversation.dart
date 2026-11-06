import 'package:uuid/uuid.dart';
import 'chat_message.dart';

class Conversation {
  final String id;
  final String title;
  final String? description;
  final String modelId;
  final String? personaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> messageIds;
  final bool isPinned;
  final bool isArchived;
  final String? projectId;
  final Map<String, dynamic> metadata;
  
  Conversation({
    String? id,
    required this.title,
    this.description,
    required this.modelId,
    this.personaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? messageIds,
    this.isPinned = false,
    this.isArchived = false,
    this.projectId,
    Map<String, dynamic>? metadata,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       messageIds = messageIds ?? [],
       metadata = metadata ?? {};
  
  // Get last message
  ChatMessage? getLastMessage(List<ChatMessage> messages) {
    if (messageIds.isEmpty) return null;
    final lastMessageId = messageIds.last;
    return messages.firstWhere(
      (msg) => msg.id == lastMessageId,
      orElse: () => ChatMessage(
        conversationId: id,
        sender: MessageSender.system,
        type: MessageType.system,
        content: 'Message not found',
      ),
    );
  }
  
  // Get message count
  int get messageCount => messageIds.length;
  
  // Get token count from all messages
  int get totalTokenCount {
    // This would need to be calculated from actual messages
    return messageIds.length * 100; // Placeholder
  }
  
  // Copy with
  Conversation copyWith({
    String? id,
    String? title,
    String? description,
    String? modelId,
    String? personaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? messageIds,
    bool? isPinned,
    bool? isArchived,
    String? projectId,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      modelId: modelId ?? this.modelId,
      personaId: personaId ?? this.personaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageIds: messageIds ?? this.messageIds,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      projectId: projectId ?? this.projectId,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'modelId': modelId,
      'personaId': personaId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageIds': messageIds,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'projectId': projectId,
      'metadata': metadata,
    };
  }
  
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? 'Untitled Conversation',
      description: map['description'],
      modelId: map['modelId'] ?? '',
      personaId: map['personaId'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      messageIds: List<String>.from(map['messageIds'] ?? []),
      isPinned: map['isPinned'] ?? false,
      isArchived: map['isArchived'] ?? false,
      projectId: map['projectId'],
      metadata: map['metadata'] ?? {},
    );
  }
  
  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, messageCount: $messageCount)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
