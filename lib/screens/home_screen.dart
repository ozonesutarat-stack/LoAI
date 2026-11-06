import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loai/providers/chat_provider.dart';
import 'package:loai/providers/theme_provider.dart';
import 'package:loai/screens/chat_screen.dart';
import 'package:loai/screens/projects_screen.dart';
import 'package:loai/screens/playground_screen.dart';
import 'package:loai/screens/settings_screen.dart';
import 'package:loai/widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const ChatScreen(),
    const ProjectsScreen(),
    const PlaygroundScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      activeIcon: Icon(Icons.chat_bubble),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_outlined),
      activeIcon: Icon(Icons.folder),
      label: 'Projects',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.science_outlined),
      activeIcon: Icon(Icons.science),
      label: 'Playground',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('LoAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewChat(chatProvider),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: AppSearchDelegate(),
    );
  }

  void _createNewChat(ChatProvider chatProvider) {
    chatProvider.createConversation();
    setState(() => _currentIndex = 0);
  }
}

class AppSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(child: Text('Search results will appear here'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final conversations = chatProvider.searchConversations(query);
    
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ListTile(
          leading: const Icon(Icons.chat),
          title: Text(conversation.title),
          subtitle: Text('${conversation.messageCount} messages'),
          onTap: () {
            chatProvider.switchConversation(conversation.id);
            close(context, conversation.id);
          },
        );
      },
    );
  }
}
