import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/chat_provider.dart';
import 'package:loai/providers/theme_provider.dart';
import 'package:loai/providers/model_provider.dart';
import 'package:loai/screens/chat_screen.dart';
import 'package:loai/screens/projects_screen.dart';
import 'package:loai/screens/playground_screen.dart';
import 'package:loai/screens/settings_screen.dart';
import 'package:loai/screens/model_manager_screen.dart';
import 'package:loai/screens/persona_manager_screen.dart';
import 'package:loai/screens/tool_manager_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    
    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryColor,
                  themeProvider.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'LoAI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chatProvider.currentConversation?.title ?? 'No active chat',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.chat_bubble,
                  'New Chat',
                  () {
                    chatProvider.createConversation();
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.history,
                  'Chat History',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChatHistoryScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  Icons.folder,
                  'Projects',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProjectsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.people,
                  'Personas',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PersonaManagerScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  Icons.science,
                  'Playground',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlaygroundScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.extension,
                  'Model Manager',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ModelManagerScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.build,
                  'Tool Manager',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ToolManagerScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context,
                  Icons.settings,
                  'Settings',
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.info_outline,
                  'About LoAI',
                  () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Theme toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode'),
                Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For help and support, please visit:'),
            SizedBox(height: 8),
            Text('• Documentation: https://loai.example.com/docs'),
            SizedBox(height: 4),
            Text('• Community: https://loai.example.com/community'),
            SizedBox(height: 4),
            Text('• Issues: https://loai.example.com/issues'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About LoAI'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LoAI - Local AI Assistant'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 4),
            Text('A comprehensive local AI assistant with chat, vision, and tool support.'),
            SizedBox(height: 8),
            Text('Features:'),
            SizedBox(height: 4),
            Text('• Chat with local AI models'),
            Text('• Vision support for images and documents'),
            Text('• Tool support (web search, knowledge base, etc.)'),
            Text('• Speech-to-text and text-to-speech'),
            Text('• Customizable UI and settings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: ListView.builder(
        itemCount: chatProvider.conversations.length,
        itemBuilder: (context, index) {
          final conversation = chatProvider.conversations[index];
          return ListTile(
            leading: const Icon(Icons.chat),
            title: Text(conversation.title),
            subtitle: Text('${conversation.messageCount} messages'),
            trailing: Text(conversation.updatedAt.toString().split(' ')[0]),
            onTap: () {
              chatProvider.switchConversation(conversation.id);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
