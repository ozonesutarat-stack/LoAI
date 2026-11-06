import 'package:flutter/material.dart';
import 'package:loai/models/chat_message.dart';
import 'package:loai/providers/theme_provider.dart';
import 'package:loai/widgets/code_block.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeProvider themeProvider;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onToolUse;

  const ChatBubble({
    super.key,
    required this.message,
    required this.themeProvider,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onToolUse,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isBot = message.sender == MessageSender.bot;
    final isSystem = message.sender == MessageSender.system;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: _buildMessageContent(context),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isBot = message.sender == MessageSender.bot;
    final isSystem = message.sender == MessageSender.system;
    
    final decoration = themeProvider.getChatBubbleDecoration(
      message.sender,
      Theme.of(context).brightness == Brightness.dark,
    );
    
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Message bubble
        Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildMessageBody(context),
        ),
        
        // Timestamp and actions
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 8, left: 8),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              if (message.sender != MessageSender.system)
                _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBody(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isCode = message.type == MessageType.code;
    final isToolResult = message.type == MessageType.toolResult;
    final isImage = message.type == MessageType.image;
    final isFile = message.type == MessageType.file;
    
    if (isCode) {
      return CodeBlockWidget(
        code: message.content,
        language: message.codeLanguage ?? 'text',
        fileName: message.fileName,
        onCopy: onCopy,
        onDownload: () => _downloadCode(message.content, message.fileName),
        onDebug: () => onToolUse?.call('Co-debug'),
      );
    }
    
    if (isToolResult) {
      return _buildToolResult(context);
    }
    
    if (isImage) {
      return _buildImageMessage();
    }
    
    if (isFile) {
      return _buildFileMessage();
    }
    
    // Regular text message
    return SelectableText(
      message.content,
      style: const TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget _buildToolResult(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.toolName != null)
            Text(
              '🔧 ${message.toolName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          const SizedBox(height: 8),
          SelectableText(
            message.content,
            style: const TextStyle(fontSize: 14),
          ),
          if (message.toolData != null && message.toolData!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Data: ${message.toolData}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.fileName != null)
          Text(
            '📷 ${message.fileName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 64, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  message.fileName ?? 'Image',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(message.fileType),
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  message.fileType ?? 'Unknown type',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: onCopy,
            tooltip: 'Copy',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (isUser && onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: onEdit,
            tooltip: 'Edit',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: onDelete,
            tooltip: 'Delete',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.grid_view;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _downloadCode(String code, String? fileName) {
    // TODO: Implement code download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code download will be implemented soon')),
    );
  }
}
