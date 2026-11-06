import 'package:flutter/material.dart';
import 'package:loai/models/conversation.dart';
import 'package:loai/models/chat_message.dart';

class ConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final Function(Conversation) onSelect;
  final bool showAll;

  const ConversationList({
    super.key,
    required this.conversations,
    required this.onSelect,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new chat to begin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: conversations.length + (showAll ? 0 : 1),
      itemBuilder: (context, index) {
        if (!showAll && index == conversations.length) {
          return _buildShowMoreButton(context);
        }
        
        final conversation = conversations[index];
        return _buildConversationItem(context, conversation);
      },
    );
  }

  Widget _buildConversationItem(BuildContext context, Conversation conversation) {
    final lastMessage = conversation.getLastMessage([]);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onSelect(conversation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    conversation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conversation.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 4),
              if (lastMessage != null)
                Text(
                  lastMessage.content,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messages: ${conversation.messageCount}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDate(conversation.updatedAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: OutlinedButton(
        onPressed: () {
          // This would typically navigate to a full conversation list
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Show more conversations'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.isAfter(yesterday)) {
      return 'This week';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Conversation item for compact display
class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        foregroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.chat, size: 20),
      ),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Messages: ${conversation.messageCount}',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Text(
        _formatDate(conversation.updatedAt),
        style: TextStyle(color: Colors.grey[500]),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
