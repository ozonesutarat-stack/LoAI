import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:loai/models/chat_message.dart';
import 'package:loai/models/conversation.dart';
import 'package:loai/models/ai_model.dart';
import 'package:loai/models/persona.dart';
import 'package:loai/models/tool.dart';

class ChatProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String _currentInput = '';
  List<Tool> _availableTools = [];
  Tool? _selectedTool;
  String? _currentModelId;
  String? _currentPersonaId;
  
  // Getters
  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String get currentInput => _currentInput;
  List<Tool> get availableTools => _availableTools;
  Tool? get selectedTool => _selectedTool;
  String? get currentModelId => _currentModelId;
  String? get currentPersonaId => _currentPersonaId;
  
  // Get recent conversations (last 3)
  List<Conversation> get recentConversations {
    final recent = _conversations
      .where((c) => !c.isArchived)
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return recent.take(3).toList();
  }
  
  // Get all conversations except recent 3
  List<Conversation> get olderConversations {
    final all = _conversations
      .where((c) => !c.isArchived)
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all.length > 3 ? all.sublist(3) : [];
  }
  
  // Get pinned conversations
  List<Conversation> get pinnedConversations {
    return _conversations
      .where((c) => c.isPinned && !c.isArchived)
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  // Get archived conversations
  List<Conversation> get archivedConversations {
    return _conversations
      .where((c) => c.isArchived)
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  ChatProvider() {
    _availableTools = Tool.getPresetTools();
  }
  
  // Initialize with existing data
  void initialize({
    List<Conversation>? conversations,
    List<ChatMessage>? messages,
    String? currentConversationId,
  }) {
    _conversations = conversations ?? [];
    _messages = messages ?? [];
    
    if (currentConversationId != null) {
      _currentConversation = _conversations.firstWhere(
        (c) => c.id == currentConversationId,
        orElse: () => null,
      );
    }
    
    notifyListeners();
  }
  
  // Create new conversation
  Future<Conversation> createConversation({
    String? title,
    String? modelId,
    String? personaId,
  }) async {
    final conversation = Conversation(
      title: title ?? 'New Chat ${_conversations.length + 1}',
      modelId: modelId ?? '',
      personaId: personaId,
    );
    
    _conversations.add(conversation);
    _currentConversation = conversation;
    _currentModelId = modelId;
    _currentPersonaId = personaId;
    
    notifyListeners();
    return conversation;
  }
  
  // Switch to existing conversation
  void switchConversation(String conversationId) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => null,
    );
    
    if (conversation != null) {
      _currentConversation = conversation;
      _currentModelId = conversation.modelId;
      _currentPersonaId = conversation.personaId;
      notifyListeners();
    }
  }
  
  // Update conversation
  void updateConversation(Conversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = conversation;
      if (_currentConversation?.id == conversation.id) {
        _currentConversation = conversation;
      }
      notifyListeners();
    }
  }
  
  // Delete conversation
  void deleteConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    
    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
      _messages.clear();
    }
    
    notifyListeners();
  }
  
  // Archive conversation
  void archiveConversation(String conversationId, bool archive) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => null,
    );
    
    if (conversation != null) {
      final updated = conversation.copyWith(isArchived: archive);
      _conversations[_conversations.indexOf(conversation)] = updated;
      notifyListeners();
    }
  }
  
  // Pin conversation
  void pinConversation(String conversationId, bool pin) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => null,
    );
    
    if (conversation != null) {
      final updated = conversation.copyWith(isPinned: pin);
      _conversations[_conversations.indexOf(conversation)] = updated;
      notifyListeners();
    }
  }
  
  // Send message
  Future<ChatMessage> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? codeLanguage,
    String? filePath,
    String? fileName,
    String? fileType,
  }) async {
    if (_currentConversation == null) {
      await createConversation();
    }
    
    final message = ChatMessage(
      conversationId: _currentConversation!.id,
      sender: MessageSender.user,
      type: type,
      content: content,
      codeLanguage: codeLanguage,
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
    );
    
    _messages.add(message);
    _currentConversation = _currentConversation!.copyWith(
      messageIds: [..._currentConversation!.messageIds, message.id],
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
    return message;
  }
  
  // Receive message (from AI)
  Future<ChatMessage> receiveMessage({
    required String content,
    MessageType type = MessageType.text,
    String? codeLanguage,
    String? toolName,
    Map<String, dynamic>? toolData,
    String? modelUsed,
    List<String>? references,
  }) async {
    if (_currentConversation == null) {
      await createConversation();
    }
    
    final message = ChatMessage(
      conversationId: _currentConversation!.id,
      sender: MessageSender.bot,
      type: type,
      content: content,
      codeLanguage: codeLanguage,
      toolName: toolName,
      toolData: toolData,
      modelUsed: modelUsed,
      references: references,
    );
    
    _messages.add(message);
    _currentConversation = _currentConversation!.copyWith(
      messageIds: [..._currentConversation!.messageIds, message.id],
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
    return message;
  }
  
  // Update message (for streaming)
  void updateLastBotMessage(String content) {
    if (_messages.isEmpty) return;
    
    final lastMessage = _messages.last;
    if (lastMessage.sender == MessageSender.bot) {
      final index = _messages.length - 1;
      _messages[index] = lastMessage.copyWith(content: content);
      notifyListeners();
    }
  }
  
  // Edit message
  void editMessage(String messageId, String newContent) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        content: newContent,
        isEdited: true,
      );
      notifyListeners();
    }
  }
  
  // Delete message
  void deleteMessage(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isDeleted: true);
      notifyListeners();
    }
  }
  
  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set current input
  void setCurrentInput(String input) {
    _currentInput = input;
    notifyListeners();
  }
  
  // Select tool
  void selectTool(Tool? tool) {
    _selectedTool = tool;
    notifyListeners();
  }
  
  // Set current model
  void setCurrentModel(String? modelId) {
    _currentModelId = modelId;
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.copyWith(modelId: modelId);
    }
    notifyListeners();
  }
  
  // Set current persona
  void setCurrentPersona(String? personaId) {
    _currentPersonaId = personaId;
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.copyWith(personaId: personaId);
    }
    notifyListeners();
  }
  
  // Use tool
  Future<ToolResult> useTool({
    required Tool tool,
    required String input,
  }) async {
    setLoading(true);
    
    try {
      // Simulate tool execution
      await Future.delayed(const Duration(seconds: 1));
      
      final result = ToolResult(
        toolId: tool.id,
        toolName: tool.name,
        toolType: tool.type,
        input: input,
        output: '_Tool result for: $input_',
        data: {'input': input, 'processed': true},
        status: ToolStatus.completed,
      );
      
      // Send tool result as message
      await receiveMessage(
        content: '[Tool: ${tool.name}]\n${result.output}',
        type: MessageType.toolResult,
        toolName: tool.name,
        toolData: result.data,
      );
      
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      return ToolResult(
        toolId: tool.id,
        toolName: tool.name,
        toolType: tool.type,
        input: input,
        output: 'Error: ${e.toString()}',
        status: ToolStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Get messages for current conversation
  List<ChatMessage> getCurrentConversationMessages() {
    if (_currentConversation == null) return [];
    
    return _messages
      .where((m) => m.conversationId == _currentConversation!.id && !m.isDeleted)
      .toList();
  }
  
  // Get conversation by ID
  Conversation? getConversationById(String id) {
    return _conversations.firstWhere(
      (c) => c.id == id,
      orElse: () => null,
    );
  }
  
  // Get messages by conversation ID
  List<ChatMessage> getMessagesByConversationId(String conversationId) {
    return _messages
      .where((m) => m.conversationId == conversationId && !m.isDeleted)
      .toList();
  }
  
  // Clear current conversation messages
  void clearCurrentConversationMessages() {
    if (_currentConversation != null) {
      _messages.removeWhere((m) => m.conversationId == _currentConversation!.id);
      _currentConversation = _currentConversation!.copyWith(messageIds: []);
      notifyListeners();
    }
  }
  
  // Search conversations
  List<Conversation> searchConversations(String query) {
    return _conversations
      .where((c) => 
        c.title.toLowerCase().contains(query.toLowerCase()) ||
        (c.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      )
      .toList();
  }
  
  // Search messages
  List<ChatMessage> searchMessages(String query) {
    return _messages
      .where((m) => m.content.toLowerCase().contains(query.toLowerCase()))
      .toList();
  }
}
