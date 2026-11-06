import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/chat_provider.dart';
import 'package:loai/providers/theme_provider.dart';
import 'package:loai/providers/model_provider.dart';
import 'package:loai/models/chat_message.dart';
import 'package:loai/widgets/chat_bubble.dart';
import 'package:loai/widgets/input_bar.dart';
import 'package:loai/widgets/conversation_list.dart';
import 'package:loai/widgets/model_selector.dart';
import 'package:loai/widgets/tool_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showConversationList = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final modelProvider = Provider.of<ModelProvider>(context);
    
    final messages = chatProvider.getCurrentConversationMessages();
    final hasMessages = messages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatProvider.currentConversation?.title ?? 'New Chat',
              style: const TextStyle(fontSize: 16),
            ),
            if (chatProvider.currentModelId != null)
              Text(
                modelProvider.getModelById(chatProvider.currentModelId!)?.name ?? 'No model',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => setState(() => _showConversationList = !_showConversationList),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showChatSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tool bar
          if (chatProvider.availableTools.isNotEmpty)
            ToolBar(tools: chatProvider.availableTools),
          
          // Messages list
          Expanded(
            child: _showConversationList
              ? ConversationList(
                  conversations: chatProvider.recentConversations,
                  onSelect: (conversation) {
                    chatProvider.switchConversation(conversation.id);
                    setState(() => _showConversationList = false);
                  },
                )
              : GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(
                        message: message,
                        themeProvider: themeProvider,
                        onCopy: () => _copyMessage(message.content),
                        onEdit: () => _editMessage(chatProvider, message),
                        onDelete: () => _deleteMessage(chatProvider, message.id),
                        onToolUse: (toolName) => _useTool(chatProvider, toolName, message.content),
                      );
                    },
                  ),
                ),
          ),
          
          // Input bar
          InputBar(
            onSend: (text) => _sendMessage(chatProvider, text),
            onImageSend: (filePath) => _sendImage(chatProvider, filePath),
            onFileSend: (filePath, fileName, fileType) => _sendFile(chatProvider, filePath, fileName, fileType),
            onVoiceInput: () => _startVoiceInput(chatProvider),
            isLoading: chatProvider.isLoading,
            currentInput: chatProvider.currentInput,
            onInputChanged: (text) => chatProvider.setCurrentInput(text),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(ChatProvider chatProvider, String text) {
    if (text.trim().isEmpty) return;
    
    chatProvider.sendMessage(content: text);
    chatProvider.setCurrentInput('');
    _scrollToBottom();
    
    // Simulate AI response
    _simulateAIResponse(chatProvider, text);
  }

  void _sendImage(ChatProvider chatProvider, String filePath) {
    chatProvider.sendMessage(
      content: '[Image: ${filePath.split('/').last}]',
      type: MessageType.image,
      filePath: filePath,
      fileName: filePath.split('/').last,
      fileType: 'image',
    );
    _scrollToBottom();
    
    // Simulate AI response
    _simulateAIResponse(chatProvider, 'What can you tell me about this image?');
  }

  void _sendFile(ChatProvider chatProvider, String filePath, String fileName, String fileType) {
    chatProvider.sendMessage(
      content: '[File: $fileName]',
      type: MessageType.file,
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
    );
    _scrollToBottom();
    
    // Simulate AI response
    _simulateAIResponse(chatProvider, 'What is in this file?');
  }

  void _startVoiceInput(ChatProvider chatProvider) {
    // TODO: Implement voice input
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice input will be implemented soon')),
    );
  }

  void _simulateAIResponse(ChatProvider chatProvider, String userMessage) {
    chatProvider.setLoading(true);
    
    Future.delayed(const Duration(seconds: 1), () {
      final responses = [
        'I understand your question. Here is my response...',
        'That\'s interesting! Let me think about that...',
        'Based on the information, here is what I found...',
        'I can help you with that. Here are some suggestions...',
      ];
      
      final response = responses[(userMessage.length + DateTime.now().millisecondsSinceEpoch) % responses.length];
      
      chatProvider.receiveMessage(content: response);
      chatProvider.setLoading(false);
      _scrollToBottom();
    });
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  void _editMessage(ChatProvider chatProvider, ChatMessage message) {
    // TODO: Implement message editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message editing will be implemented soon')),
    );
  }

  void _deleteMessage(ChatProvider chatProvider, String messageId) {
    chatProvider.deleteMessage(messageId);
  }

  void _useTool(ChatProvider chatProvider, String toolName, String input) {
    final tool = chatProvider.availableTools.firstWhere(
      (t) => t.name == toolName,
      orElse: () => null,
    );
    
    if (tool != null) {
      chatProvider.useTool(tool: tool, input: input);
    }
  }

  void _showChatSettings(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Model selector
            ModelSelector(
              currentModelId: chatProvider.currentModelId,
              models: modelProvider.chatModels,
              onSelected: (modelId) => chatProvider.setCurrentModel(modelId),
            ),
            const SizedBox(height: 16),
            
            // Persona selector
            const Text('Persona:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: chatProvider.currentPersonaId,
              hint: const Text('Select a persona'),
              items: modelProvider.personas.map((persona) {
                return DropdownMenuItem<String>(
                  value: persona.id,
                  child: Text(persona.name),
                );
              }).toList(),
              onChanged: (value) => chatProvider.setCurrentPersona(value),
            ),
            const SizedBox(height: 16),
            
            // Clear chat button
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Clear Chat'),
              onPressed: () => chatProvider.clearCurrentConversationMessages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
