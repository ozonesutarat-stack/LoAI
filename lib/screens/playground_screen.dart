import 'package:flutter/material.dart';
import 'package:loai/screens/co_debug_screen.dart';
import 'package:loai/screens/translator_screen.dart';
import 'package:loai/screens/document_reader_screen.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.code),
              text: 'Co-debug',
            ),
            Tab(
              icon: Icon(Icons.translate),
              text: 'Translator',
            ),
            Tab(
              icon: Icon(Icons.description),
              text: 'Document Reader',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CoDebugScreen(),
          TranslatorScreen(),
          DocumentReaderScreen(),
        ],
      ),
    );
  }
}

// Main playground options screen (alternative)
class PlaygroundOptionsScreen extends StatelessWidget {
  const PlaygroundOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlaygroundCard(
              context,
              'Co-debug',
              Icons.code,
              'Test and debug code with AI assistance',
              Colors.blue,
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CoDebugScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPlaygroundCard(
              context,
              'Smart Translator',
              Icons.translate,
              'Translate text with context and examples',
              Colors.green,
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TranslatorScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPlaygroundCard(
              context,
              'Document Reader',
              Icons.description,
              'Read and summarize documents',
              Colors.purple,
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DocumentReaderScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaygroundCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
